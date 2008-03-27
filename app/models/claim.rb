class Claim < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :spot
  
  belongs_to :user
  belongs_to :spot
  
  def crossed_claim
    self.spot.first_claim_before self
  end
  
  def crossed_by_claim
    self.spot.first_claim_after self
  end
end
