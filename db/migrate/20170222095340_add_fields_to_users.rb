class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change

  	add_column :users, :social_facebook, :string
  	add_column :users, :social_linkedin, :string
  	add_column :users, :social_twitter, :string

  	remove_column :users, :full_name, :string
  	add_column :users, :first_name, :string
  	add_column :users, :last_name, :string
  	add_column :users, :phone, :string
  	add_column :users, :first_login, :timestamp

  end
end
