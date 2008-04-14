class Order < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :street
  validates_presence_of :city
end
