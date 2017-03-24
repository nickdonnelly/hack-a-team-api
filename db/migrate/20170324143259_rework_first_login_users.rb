class ReworkFirstLoginUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :first_login
    add_column :users, :first_login, :boolean, default: true
  end
end
