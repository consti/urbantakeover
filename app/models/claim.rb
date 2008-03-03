class Claim < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :spot
  
  belongs_to :user
  belongs_to :spot
end
