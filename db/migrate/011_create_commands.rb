class CreateCommands < ActiveRecord::Migration
  def self.up
    create_table :commands do |t|
      t.column :user_id, :integer
      t.column :text, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :commands
  end
end
