class CreateKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :keys do |t|
      t.string  :key
      t.integer :privilege_level # 0 = read, 1 = read/write
      t.timestamps
    end
  end
end
