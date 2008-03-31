class Team < ActiveRecord::Base
  has_many :users
  validates_presence_of :name
  validates_presence_of :colour
  
  before_validation :generate_colour_if_needed
  
  def generate_colour_if_needed
    self.colour = "#%06x" % rand(0xffffff) if not self.colour or self.colour.empty?
  end
  
  def score
    self.users.inject(0) {|n, u| n += u.score }
  end
  
  def rank
    0
  end
end
