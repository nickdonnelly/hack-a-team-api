class ApiController < ApplicationController

  protect_from_forgery with: :null_session
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

    # Not necessarily correct
    def login_token_request
      if params[:login_identifier].nil? or params[:apikey].nil? then
        badparams("identifier or apikey")
      else
        u = User.find_by(login_identifier: params[:login_identifier])
        if u.nil? 
          render json: {error: "[900] Bad login identifier. Authentication failed."}
        else
          render json: u
        end
      end
    end

    def get_group_list
      @offset = -1
      @limit = -1
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
      else
        gid = params[:groupid].to_i
        @group = Team.find(gid)
        render json: @group
      end
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
          render json: {error: "[102] Record not found."}
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
       submitted = {}
      effected_keys = ["id", "email", "description", "profile_image", "social_facebook", "social_linkedin", "social_twitter", "first_name", "last_name", "phone"]
      params.each do |key, val|
        if(effected_keys.include? key)
          submitted[key] = val
        end
      end
      if submitted["id"].nil? then
        badparams("id") 
      else
        @user = User.find_by_id(submitted["id"])
        if !(@user.nil?)
          submitted.each do |key, val|
            if key != "id" # dont edit the id's, this will throw an activerecord exception
              @user[key] = val
            end
          end
          @user.save
          render json: submitted
        else
          render json: {error: "[102] Record not found."}
        end
      end

    end

    def register_new_user
      # required_params = ["first_name", "last_name", "email", "phone"]
      if params["first_name"].nil? or params["last_name"].nil? or params["email"].nil? or params["phone"].nil? 
        badparams()
      else
        new_user = User.new
        new_user.first_name = params["first_name"]
        new_user.last_name = params["last_name"]
        new_user.phone = params["phone"]
        new_user.email = params["email"]
        new_user.login_identifier = SecureRandom.hex
        if new_user.save
          render json: {login_identifier: u.login_identifier, user_id: u.id}
        else
          render json: {error: "[901] Record save failed. Verify parameters are correct."}
        end
      end
    end


    def create_team
      # required_params = ["team_name", "contact_email", "team_img"]
      if params["team_name"].nil? or params["contact_email"].nil? or params["team_img"].nil? 
        badparams()
      else
        creator_user = User.find_by(login_identifier: params[:login_identifier])
        new_team = Team.new
        new_team.team_name = params["team_name"]
        new_team.contact_email = params["contact_email"]
        new_team.team_img = params["team_img"]
        new_team.creator = creator_user.id
        new_team.members = [creator_user.id]
        new_team.invite_link = SecureRandom.hex
        if new_team.save
          render json: {team_id: new_team.id, invite_link: new_team.invite_link}
        else
          render json: {error: "[901] Record save failed. Verify parameters are correct."}
        end

      end
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

    def user_params(params)
      params.require(:user).permit(:first_name, :last_name, :phone, :team_id, :email, :description, :profile_image, :social_facebook, :social_linked, :social_twitter, :first_login)
    end



    
end
