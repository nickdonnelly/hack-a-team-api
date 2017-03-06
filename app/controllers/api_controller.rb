class ApiController < ApplicationController

  before_action :fix_headers
	before_action :check_key
  before_action :check_valid_login_ident
  skip_before_action :check_valid_login_ident, only: [:login_token_request]

  def fix_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Request-Method"] = "*"
  end

    def unknown
      render json: {error: "[0a] Unknown API endpoint."}
    end

    def nokey
      render json: {error: "[0b] No API key provided."}
    end

    def nologin
      render json: {error: "[0d] No login credentials provided."}
    end

    def badkey
        render json: {error: "[0c] Invalid API key provided."}
    end

    def badparams(param="")
      if(param != "")
        render json: {error: "[100] Bad parameter for " + param + ". Check types."}
      else
        render json: {error: "[100] Bad parameter. Check types."}
      end
    end

    def login_token_request
      if params[:identifier].nil? or params[:apikey].nil? then
        badparams("identifier or apikey")
      else
        # temp
        render json: params
        # TODO
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
        badparams("groupid")
      end
      gid = params[:groupid].to_i
      @group = Team.find(gid)
      render json: @group
    end

    def edit_group_information
      submitted = {}
      effected_keys = ["id", "team_name", "team_image", "team_link", "video_link", "description", "contact_phone", "contact_email", "challenge_id"]
      params.each do |key, val|
        if(effected_keys.include? key)
          submitted[key] = val
        end
      end
      if submitted["id"].nil? then
        badparams("id") 
      else
        @team = Team.find_by_id(submitted["id"])
        if !(@team.nil?)
          submitted.each do |key, val|
            if key != "id" # dont edit the id's, this will throw an activerecord exception
              @team[key] = val
            end
          end
          @team.save
          render json: submitted
        else
          render json: {error: "[102] Record not found."}
        end
      end
    end

    # Returns a JSON object containing a single user.
    def get_user_by_id
      if params[:uid].nil?
        badparams("uid")
      else
        @u = User.find(params[:uid])
        if @u.nil?
          render json: {erro: "[102] Record not found."}
        else
          render json: @u
        end
      end
    end

    # Returns a JSON object containing a list of users.
    # Input should be a list delimited by commas with no spaces.
    def get_user_by_id_list
      @ulist = []
      if params[:uids].nil?
        badparams("uids")
      else
        params[:uids].split(",").each do |item|
          u = User.find(item)
          if !(u.nil?)
            @ulist << u
          end

        end
        render json: @ulist
      end
    end

    def edit_user_by_id
       # TODO
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

    def check_valid_login_ident
      if params[:login_identifier].nil?
        nologin()
      else
        # TODO: Check validity of login ident
        @user = User.find_by(login_identifier: params[:login_identifier])
        if @user.nil? then
          err = {error: "[900] Bad login identifier. Authentication failed."}
          render json: err
        end
      end
    end

    def key_valid(key) # TODO: implement this
      @k = Key.find_by(:key => key)
      if @k.nil?
        false
      else
        true
      end
    end

    def team_params(params)
      # DO NOT ADD ID TO THIS LIST.
      params.require(:team).permit(:team_name, :team_image, :team_link, :contact_email, :contact_phone, :members, :video_link, :description, :challenge_id)
    end



    
end
