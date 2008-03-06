class Score < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :points
  
  belongs_to :user
end
