class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :team_name
      t.string :team_img
      t.string :team_link
      t.string :video_link
      t.text   :description
      t.string :contact_phone
      t.string :challenge_id
      t.text :members # will be serialized with rails from array into text and back.
      
      t.timestamps
    end
  end
end
