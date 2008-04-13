class OrderAddDone < ActiveRecord::Migration
  def self.up
    add_column :orders, :is_done, :boolean, :default => false
    add_column :orders, :confirmation_note, :text
    Order.find(:all).each do |order|
      order.is_done = false
    end
  end

  def self.down
    remove_column :orders, :is_done
    remove_column :orders, :confirmation_note
  end
end
