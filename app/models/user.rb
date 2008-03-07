require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  has_many :claims, :order => "created_at desc"
  has_many :stickers
  has_many :scores, :order => "created_at desc"
  has_and_belongs_to_many :friends, :class_name => 'User', :join_table => 'user_friend', :association_foreign_key => 'user_id', :foreign_key => 'friend_id'
  has_and_belongs_to_many :friends_of, :class_name => 'User', :join_table => 'user_friend', :association_foreign_key => 'friend_id', :foreign_key => 'user_id'
  
  
  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_uniqueness_of   :email, :case_sensitive => false, :if => Proc.new { |user| user.email != nil }
  validates_uniqueness_of   :twittername, :if => Proc.new { |user| user.twittername != nil }
  
  before_save :encrypt_password
  before_validation :random_color_if_not_set
  before_create :initial_score_before
  after_create :initial_score_after
  
  def friend_of? user
    self.friends_of.each do |friend|
      return true if friend == user
    end
    return false
  end
  
#  def self.find_florian
#    self.find_by_login 'oneup'
#  end
#  
#  def after_create
#    flo = User.find_florian
#    return unless flo
#    self.friends = [flo]
#    self.save
#    flo.friends << self
#    flo.save
#  end
  
  
  def random_color_if_not_set
    self.colour_1 = "#%06x" % rand(0xffffff)
  end
  
  def initial_score_before
    self.scores_seen_until = Time.now
  end
  
  def initial_score_after
    self.score 5, "signed up"
  end

  def score(points, description)
    self.scores.create :points => points, :description => description
  end
  
  def total_score
    self.scores.inject(0) {|n, s| n += s.points} 
  end

  def can_claim? spot
    return spot.current_owner != self
  end
  
  def can_edit_spots?
    is_admin?
  end
  
  def claim spot
    if self.can_claim? spot
      my_claim = Claim.create :user => self, :spot => spot
      self.score 10, "claimed #{spot.name}"
      
      if my_claim.crossed_claim
        my_claim.crossed_claim.user.score 2, "crossed by #{self.login} at #{spot.name}"
      end
    end
  end
  
  def owned_spots
    self.claims.collect do |claim|
      claim.spot if claim.spot.current_owner == self
    end.compact.uniq
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
