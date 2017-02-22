class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :full_name # do first and last in same field
      t.string :email
      t.text :description 
      t.string :profile_image
      t.string :login_identifier
      t.integer :team_id

      t.timestamps
    end
  end
end
