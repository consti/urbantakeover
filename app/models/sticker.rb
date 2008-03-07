class Sticker < ActiveRecord::Base
  #not used anywhere
  validates_presence_of :code
  belongs_to :user
  belongs_to :claim
end
