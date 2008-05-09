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
  
  ### TODO: IMPLEMENT ME AS MIXIN
  def rank
    @rank ||= calculate_rank
  end
  
  def calculate_rank
    rank = 1
    self.class.ranked_users.each do |user|
      return rank if user == self
      rank += 1
    end
  end
  
  def self.each
    self.find(:all).each yield
  end
  
  def self.ranked_users
    @@ranked_users ||= self.calculate_ranks
  end
  
  def self.calculate_ranks
    Team.find(:all).sort do |user, user2|
      user.score <=> user2.score
    end.reverse
  end
  ### END
end
