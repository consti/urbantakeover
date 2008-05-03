class CreateStickers < ActiveRecord::Migration
  def self.up
    create_table :stickers do |t|
      t.column :code, :string
      t.column :user_id, :integer
      t.column :claim_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :stickers
  end
end
