class CreateQuests < ActiveRecord::Migration
  def self.up
    create_table :quests do |t|
      t.column :name, :string
      t.column :text, :text
      t.column :spot_id, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :quests
  end
end
