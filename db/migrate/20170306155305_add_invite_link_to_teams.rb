class AddInviteLinkToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :invite_link, :string
  end
end
