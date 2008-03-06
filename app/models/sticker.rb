class Sticker < ActiveRecord::Base
  belongs_to :creator, :foreign_key => :user_id, :class_name => "User"
  belongs_to :claim
  
  before_create :generate_code

  validates_presence_of :code
  validates_uniqueness_of :code
  
  def generate_code
    n = []
    3.times do |i|
      n << "%04d" % (1+rand(1000))
    end

    self.code = n.join("-")

    generate_code if Sticker.find_by_code self.code
  end
end
