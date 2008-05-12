class Score < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :points
  
  belongs_to :user

  def before_create
    @old_rank = Score.rank_for(self.user)
  end
  
  def after_create
    Score.recalculate_ranks(self.user.class)
    new_rank = Score.rank_for(self.user)

    return if new_rank == @old_rank or self.points == 0
  
    if new_rank > @old_rank
      self.user.notify_all "yay, ranked +#{new_rank-@old_rank} up. now \##{new_rank} with #{user.score} points."
    else
      self.user.notify_all "fck! ranked -#{new_rank-@old_rank} down. now \##{new_rank} with #{user.score} points."
    end
  end
  
  
  @@rankings = {}
  
  def self.rank_for object
    rank = 1
    @@rankings[object.class] || self.recalculate_ranks(object.class)
    @@rankings[object.class].each do |object2|
      return rank if object == object2
      rank += 1
    end
  end
  
  def self.recalculate_ranks klass
    @@rankings[klass] = klass.find(:all).sort do |o, o2|
      o.score <=> o2.score
    end.reverse
  end
end
