class CreateClaims < ActiveRecord::Migration
  def self.up
    create_table :claims do |t|
      t.column :user_id, :integer
      t.column :spot_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :claims
  end
end
