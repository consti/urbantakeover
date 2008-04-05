class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.column :name, :string
      t.column :street, :string
      t.column :city, :string
      t.column :text, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
