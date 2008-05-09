class Score < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :points
  
  belongs_to :user

  def before_create
    @old_user_rank = Score.rank_for(self.user)
  end
  
  def after_create
    Score.recalculate_ranks
    new_rank = Score.rank_for(self.user)
    
    return if new_rank == @old_rank
    
    if new_rank > @old_user_rank
      self.user.notify_all "yay, ranked +#{new_rank-@old_rank} up to \##{new_rank} with #{user.points} pts."
    else
      self.user.notify_all "fck! ranked -#{new_rank-@old_rank} down to \##{new_rank} with #{user.points} pts."
    end
  end
  
  
  @@rankings = {}
  
  def self.rank_for object
    rank = 1
    @@rankings[object.class] ||= self.recalculate_ranks(object.class)
    @@rankings[object.class].each do |object2|
      return rank if object == object2
      rank += 1
    end
  end
  
  def self.ranked_users
    @@ranked_users ||= self.calculate_ranks
  end
  
  def self.recalculate_ranks klass
    klass.find(:all).sort do |o, o2|
      o.score <=> o2.score
    end.reverse
  end
  
end
