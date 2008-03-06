class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.column :description, :string
      t.column :points, :integer
      t.column :user_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
