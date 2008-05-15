class Team < ActiveRecord::Base
  has_many :users
  validates_presence_of :name
  validates_presence_of :colour
  
  before_validation :generate_colour_if_needed
  
  def spots
    # PERFORMANCE: super slow method here!
    spots = []
    self.users.each do |user|
      spots += user.spots
    end
    
    spots.uniq
  end
  
  def self.each
    self.find(:all).each yield
  end  
  
  def generate_colour_if_needed
    self.colour = "#%06x" % rand(0xffffff) if not self.colour or self.colour.empty?
  end
  
  def score
    self.users.inject(0) {|n, u| n += u.score }
  end

  def rank
    @rank ||= Score.rank_for(self)
  end  
end
