class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.column :name, :string
      t.column :colour, :string
      t.timestamps
    end
    
    add_column :users, :team_id, :integer
  end

  def self.down
    drop_table :teams
    remove_column :users, :team_id
  end
end
