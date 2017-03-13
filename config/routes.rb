Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'api#unknown'

  scope '/api' do
    scope '/v1' do
      # Endpoints start here.
      get '/getGroupList' => 'api#get_group_list'
      get '/getGroupById' => 'api#get_group_by_id'
      # DONT FORGET TO CHANGE THE BELOW TO POST INSTEAD OF GET
      post '/editGroupById' => 'api#edit_group_information'
      get '/getUserById' => 'api#get_user_by_id'
      get '/getUsersByIds' => 'api#get_user_by_id_list'
      post '/editUser' => 'api#edit_user_by_id'
      post '/registerNewUser' => 'api#register_new_user'
      post '/createTeam' => 'api#create_team'

      get '/getChallenges' => 'api#get_challenges'
      get '/getChallengeById' => 'api#get_single_challenge'
      post '/requestLoginToken' => 'api#login_token_request'
    end
  end
end
