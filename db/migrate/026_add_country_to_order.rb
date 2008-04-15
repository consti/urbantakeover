class AddCountryToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :country, :string
    add_column :orders, :email, :string
  end

  def self.down
    remove_column :orders, :country
    remove_column :orders, :email
  end
end
