namespace :apikeys do
  desc "TODO"
  task issue_key: :environment do
  	@key = Key.new
  	@key.key = SecureRandom.hex #built into ruby
  	@key.privilege_level = 1
  	@key.save!
  	puts "Key created with privilege level 1: " + @key.key
  end

  desc "TODO"
  task revoke_key: :environment do
  	puts "Not implemented!"
  end

end
`