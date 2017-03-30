class ApiController < ApplicationController

  protect_from_forgery with: :null_session
  before_action :fix_headers # changes http headers to ignore the origin, prevents source request errors.
	before_action :check_key # checks api key
  before_action :check_valid_login_ident # checks login_identifier
  skip_before_action :check_valid_login_ident, only: [:get_single_challenge, :get_challenges, :login_token_request] # skips login_identifier check for the token request action and actions that shouldn't require authentication to use (no database changes).

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

  # Email + passcode to authenticate, return login_identifier after reset
  def login_token_request
    if not params[:email].nil? and not params[:passcode].nil?
      @u = User.find_by(email: params[:email], passcode: params[:passcode])

      if @u.nil?
        render json: {error: "[102] Record not found"}
      else
        @u.login_identifier = SecureRandom.hex # reset the identifier on each login
        render json: @u
        if @u.first_login.nil? or @u.first_login == true
          @u.first_login = false
        end
        @u.save(validate: false)
      end

    else
      badparams("email or passcode")
    end
  end

  def get_challenges
    render json: Challenge.all
  end

  def get_single_challenge
    if params[:id].nil?
      badparams("id")
    else
      @c = Challenge.find_by(:id => params[:id])
      render json: @c
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
    effected_keys = ["id", "team_name", "team_img", "team_link", "video_link", "description", "contact_phone", "contact_email", "challenge_id"]
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

  def delete_user
    @u = User.find_by(id: params["userid"].to_i)

    if @u.nil?
      badparams("login_identifier or userid")
    else
      if(params["login_identifier"] == @u.login_identifier)
        t = Team.find_by(@u.teamid)
        if !(t.nil?)
          t.members = t.members - [@u.id] # remove user from the team they belong to
          if t.members.length == 0
            Team.destroy(t.id)
          else
            t.save(validate: false)
          end
        end
        User.destroy(@u.id) # Force delete item
        render json: {success: "User was deleted."}
      else
        render json: {error: "[999] Not authorized!"}
      end
    end

  end

  def leave_team
    if params["teamid"].nil?
      badparams("teamid")
    else
      @u = User.find_by(login_identifier: params["login_identifier"])
      @t = Team.find_by(id: params["teamid"])
      if @t.members.include? @u.id
        @t.members = @t.members - [@u.id]
        @u.teamid = nil
        @u.save(validate: false)
        if @t.members.length == 0
          Team.destroy(@t.id) # Deletes teams that have no members.
          render json: {success: "Team deleted."}
        else
          send_cm_message({
            data: {"left": @u.first_name + " " + @u.last_name + " left your team."},
            to: '/topics/' + t.id
          })
          @t.save(validate: false)
          render json: @t
        end
      else
        badparams("teamid") #They arent in the team
      end
    end
  end

  def set_user_device_token
    if params["device_token"].nil?
      badparams("device_token")
    else
      @u = User.find_by(login_identifier: params["login_identifier"])
      if @u.nil?
        render json: {error: "[102] Record not found."}
      else
        @u.device_token = params["device_token"]
        @u.save(validate: false)
        render json: @u
      end
    end
  end

  # Returns a JSON object containing a single user.
  def get_user_by_id
    if params[:uid].nil?
      badparams("uid")
    else
      @u = User.find_by_id(params[:uid])
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

  def send_cm_message(data)
    
    wapi_key = "AIzaSyCzo1hwNBGT5wA6ty_nKaq_zOmEqsgh6rk" # Firebase API Key.
    uri = URI.parse("https://fcm.googleapis.com/fcm/send")

    http = Net::HTTP.new(uri.host)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {"Content-Type" => "application/json",
    "Authorization" => "key="+wapi_key})
    request.body = data.to_json

    response = http.request(request)
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
        if @user.login_identifier == params[:login_identifier]
          submitted.each do |key, val|
            if key != "id" # dont edit the id's, this will throw an activerecord exception
              @user[key] = val
            end
          end
          @user.save
          render json: submitted
        else
          render json: {error: "[103] Login identifiers don't match!"}
        end
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
    if params["team_name"].nil?
      badparams("team_name")
    elsif params["contact_email"].nil?
      badparams("contact_email")
    elsif params["team_img"].nil?
      badparams("team_img")
    elsif params["challenge_id"].nil?
      badparams("challenge_id")
    else
      creator_user = User.find_by(login_identifier: params[:login_identifier])
      new_team = Team.new
      new_team.team_name = params["team_name"]
      new_team.contact_email = params["contact_email"]
      new_team.team_img = params["team_img"]
      new_team.creator = creator_user.id
      new_team.members = [creator_user.id]
      new_team.invite_link = SecureRandom.hex
      new_team.team_link = ""
      new_team.video_link = ""
      new_team.description = ""
      new_team.contact_phone = ""
      new_team.challenge_id = params["challenge_id"]
      
      if new_team.save
        creator_user.teamid = new_team.id
        creator_user.save(validate: false)
        render json: new_team
      else
        render json: {error: "[901] Record save failed. Verify parameters are correct."}
      end

    end
  end

  def join_team
    if params["invite_link"].nil? or params["userid"].nil? then
      badparams("userid or invite_link")
    else
      t = Team.find_by(invite_link: params["invite_link"])
      if t.nil?
        render json: {error: "[102] Record not found."}
      else
        u = User.find_by(id: params["userid"])
        if u.login_identifier != params["login_identifier"]
          render json: {error: "[999] Not authorized!"}
        else
          t.members << params["userid"].to_i
          u.teamid = t.id
          u.save(validate: false)
          t.save(validate: false)
          send_cm_message({
            data: {"joined": u.first_name + " " + u.last_name + " joined your team!"},
            to: '/topics/' + t.id
          })
          render json: t
        end
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
        render json: {error: "[900] Bad login identifier. Authentication failed."}
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
    params.require(:user).permit(:first_name, :last_name, :phone, :team_id, :teamid, :email, :description, :profile_image, :social_facebook, :social_linked, :social_twitter, :first_login)
  end



    
end
