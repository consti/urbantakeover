class Quest < ActiveRecord::Base
  validates_presence_of :name #, :string
  validates_presence_of :text #, :text
  validates_presence_of :spot_id
  
  belongs_to :spot
end
