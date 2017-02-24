class ApiController < ApplicationController

	before_action :check_key

    def unknown
        render json: "[0a] Unknown API endpoint."
    end

    def nokey
        render json: "[0b] No API key provided."
    end

    def badkey
        render json: "[0c] Invalid API key provided."
    end

    def badparams(param="")
      if(param != "")
        render json: "[100] Bad parameter for " + param + ". Check types."
      else
        render json: "[100] Bad parameter. Check types."
      end
    end

    def get_group_list
      # key checks are implicit.
      @challengeid = -1
      @offset = -1
      @limit = -1
      (!params[:challengeid].nil?) ? @challengeid = params[:challengeid].to_i : @challengeid = -1
      (!params[:offset].nil?) ? @offset = params[:offset].to_i : @offset = -1
      (!params[:limit].nil?) ? @limit = params[:limit].to_i : @limit = 9999999999
      
      if @offset == -1
        @groups = Team.take(@limit)
      else
        @groups = Team.offset(@offset).take(@limit)
      end
      
      render json: @groups 
    end


    def get_group_by_id
      if params[:groupid].nil?
        badparams(groupid)
      end
      gid = params[:groupid].to_i
      @group = Team.find(gid)
      render json: @group
    end

    private

    def check_key
      if params[:apikey].nil?
    	nokey()
      elsif !key_valid(params[:apikey])
    	badkey()
      end
      true # the key is valid.
    end

    def key_valid(key) # TODO: implement this
      true
    end
    
end
