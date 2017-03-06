namespace :database_init do
  names = ["Adella", "Leon", "Marcelene", "Florentina", "Nelle","Mittie", "Germaine","Kurt","Jalisa","Delpha"]



  task create_dummy_users: :environment do
    prng = Random.new
    for i in 1..20 do
      u = User.new
      u.first_name = names.sample
      u.last_name = names.sample
      u.email = "test@example.com"
      u.login_identifier = SecureRandom.hex
      u.phone = "123123123"
      u.team_id = prng.rand(1..50)
      u.social_facebook = u.first_name + "_" + u.last_name
      u.social_twitter = u.first_name + "_" + u.last_name
      u.social_linkedin = u.first_name + "_" + u.last_name
      u.description = "Filler description text. Lorem ipsum dolor sit amet consectitur bla bla bla." + SecureRandom.hex
      u.save!

    end
  end


  task create_dummy_teams: :environment do
    prng = Random.new
    for i in 1..20 do
      t = Team.new
      t.team_img = "http://awesometeam.com/img.jpeg"
      t.team_name = names.sample
      t.team_link = "http://awesometeam.com"
      t.video_link = "http://youtube.com/"
      t.description = "Filler description text. Lorem ipsum dolor sit amet consectitur bla"
      t.contact_phone = "123123123"
      t.challenge_id = prng.rand(1..3)
      t.contact_email = "team_email@example.com"
      t.creator = prng.rand(1..(User.count))
      t.members = []
      for j in 1..5 do
        t.members << prng.rand(1..(User.count))
      end
      t.save
    end

  end


end
