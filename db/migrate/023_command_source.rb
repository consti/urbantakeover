class CommandSource < ActiveRecord::Migration
  def self.up
    add_column :commands, :source, :string
    
    Command.find(:all).each do |c|
      c.source = "twitter"
      c.save
    end
  end

  def self.down
    remove_column :commands, :source
  end
end
