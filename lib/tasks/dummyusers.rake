namespace :database_init do
  names = ["Adella", "Leon", "Marcelene", "Florentina", "Nelle","Mittie", "Germaine","Kurt","Jalisa","Delpha"]


  desc "TODO"
  task create_dummy_users: :environment do
    prng = Random.new
    for i in 1..20 do
      u = User.new
      u.first_name = names.sample
      u.last_name = names.sample
      u.email = "test@example.com"
      u.login_identifier = SecureRandom.hex
      u.phone = "123123123"
      u.team_id = prng.rand(1..20)
      u.social_facebook = u.first_name + "_" + u.last_name
      u.social_twitter = u.first_name + "_" + u.last_name
      u.social_linkedin = u.first_name + "_" + u.last_name
      u.description = "Filler description text. Lorem ipsum dolor sit amet consectitur bla bla bla." + SecureRandom.hex
      u.save!

    end
  end

  desc "TODO"
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
      t.invite_link = SecureRandom.hex.truncate(8)
      t.challenge_id = prng.rand(1..3)
      t.contact_email = "team_email@example.com"
      t.creator = prng.rand(User.sample.id)
      t.members = []
      for j in 1..5 do
        t.members << prng.rand(User.sample.id)
      end
      t.save
    end
  end

  desc "TODO"
  task randomize_passcodes: :environment do
    prng = Random.new
    User.all.each do |u|
      u.passcode = prng.rand(10000..99999).to_s # 5 digits
      u.save(validate: false)
    end
  end


  end


end
