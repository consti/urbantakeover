require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_protected :is_admin
  attr_protected :twitter_friend_with
  

  has_many :claims, :order => "created_at desc", :dependent => :destroy
  has_many :scores, :order => "created_at desc", :dependent => :destroy
  has_and_belongs_to_many :friends, :class_name => 'User', :join_table => 'user_friend', :association_foreign_key => 'user_id', :foreign_key => 'friend_id'
  has_and_belongs_to_many :friends_of, :class_name => 'User', :join_table => 'user_friend', :association_foreign_key => 'friend_id', :foreign_key => 'user_id'
  belongs_to :team
  belongs_to :city
  
  
  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 3..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 1..32
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_uniqueness_of   :email, :case_sensitive => false, :if => Proc.new { |user| not user.email.empty? }
  validates_format_of :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i, :if => Proc.new { |user| not user.email.empty?}
  validates_uniqueness_of   :twittername, :if => Proc.new { |user| not user.twittername.empty? }
  validate :colour_is_somewhat_visible
  
  before_save :encrypt_password
  before_save :update_twitter_friend
  before_validation :random_color_if_not_set
  before_validation :set_city
  before_validation :clean_notify_fields
  before_create :initial_score_before
  after_create :initial_score_after
  after_create :add_initial_friend
  
  after_save :save_team
  
  def self.generate_password
    password = "%04d" % (1+rand(9999))
  end

  def self.each
    self.find(:all).each yield
  end  

  def rank
    @rank ||= Score.rank_for(self)
  end
  
  def add_initial_friend
    developers = User.find :all, :conditions => ["login in (?)", ["oneup", "consti", "stereotype", "sushimako"]]
    return if developers.empty?

    developers.each do |developer|
      self.friends << developer
      developer.friends << self
      developer.save
    end

    self.save
  end
  
  def self.find_all_by_name name
    self.find_all_by_login name
  end
  
  def self.find_by_name name
    u = self.find_by_login(name)
    return self.find_by_email(name) unless u
    u
  end

  def save_team
    team.save if team
  end

  def colour_3= value
    team.colour = value if team
  end
  
  def colour_3
    team.colour if team
  end

  def clean_notify_fields
    twittername.strip! unless twittername.empty?
    email.strip! unless email.empty?
  end

  def before_destroy
    raise "not allowed to destroy users!"
  end

  def set_city
    self.city = City.find_by_name "Wien" # HACKETY HACK
  end

  def colour_is_somewhat_visible
    if self.colour_1 == self.colour_2
      self.errors.add "Colour 1 and 2 can't be the same. Other players won't be able to read your name, kbai?!"
    end
  end
  
  def spots
    # super not performant
    @spots ||= load_spots
  end
  
  def load_spots
      spots = []
      self.claims.each do |claim|
        spots << claim.spot if claim.spot.current_owner == self
      end
      spots.uniq
  end
  
#  validate :leetness_of_password
#  
#  def leetnes_of_password
#    # we also allow/generate only 3key passwords. but if we force a lot of non alphanumerical characters in, i hope i make htem hard to crack. but easy to type on cellphones.
#    # this also creates a minigame for our uses to guess 1337 passwords (or the identifiers that give a higher leet score)
#    leet_factor = 0
#    %w(! " § $ € « @ % & / = ? ß ` ´ * + ' # , ; . : - _ < > ^ ° # ').each do |leet_character|
#      leet_factor += 1 if self.password.include? leet_character
#    end
#    
#    errors.add "password not 1337 enough, please use special characters, like @ in your password."  if leet_factor > 1
#  end
  
  def friend_of? user
    self.friends_of.each do |friend|
      return true if friend == user
    end
    return false
  end

  def name
    self.login || self.twittername # i think twittername is never called, but i don't know if it works the other way round if twittername is nil and not "", but is twittername nil or "". dunno. ask rails. try in script/console or ask ruby in irb. :P
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
    self.colour_1 = "#%06x" % rand(0xffffff) if not self.colour_1 or self.colour_1.empty?
  end
  
  def initial_score_before
    self.scores_seen_until = Time.now
  end
  
  def initial_score_after
    self.score 50, "signed up"
  end

  def score!(points, description)
    self.scores.create :points => points, :description => description

    if points > 0
      message = "bam! #{description}, got #{points} points!"
    elsif points < 0
      message = "fck! #{description}, lost #{points.abs} points!"
    else
      message = description
    end

    self.notify_all message
  end
  
  def score points=nil, description=nil
    return score!(points, description) unless points.nil?
    self.scores.inject(0) {|n, s| n += s.points} 
  end

  def can_claim? spot
    return spot.current_owner != self
  end

  def can_edit_spots?
    is_admin?
  end
  
  def notify_all message
    # don't call this function "notify". it will wreak havoc and send all kind of strange "before_save", "after_save" messages. ruby built in function names & message passing system gone wild ^_^
    if should_twitter?
      notify_twitter(message)
    elsif should_mail? # if i'm notified via sms, i don't want a mail aswell (especially since some users get twitter notify mails)
      notify_mail(message) 
    end
    message
  end
  
  def should_twitter?
    (not twittername.empty?) and is_notify_mail_on? and ENV["RAILS_ENV"] == 'production' 
  end
  
  def should_mail?
    (not email.empty?) and is_notify_mail_on? and ENV["RAILS_ENV"] == 'production' 
  end
  
  def is_notify_mail_on?
    # soon to be turned into a database field @hacketyhack
    true
  end

  def is_notify_twitter_on?
    # soon to be turned into a database field @hacketyhack 
    true
  end
  
  def notify_mail message
    begin # maybe this try except is not needed
      NotifyMailer.deliver_message(self, message)
    rescue => e
      logger.error(e)
      #TODO: MAIL US
    end
  end

  def notify_twitter message
    begin
      #TODO: probably very stupid, should be done differently. code copied from http://snippets.dzone.com/posts/show/3714 (for rest see environment.rb)
      TWITTER.d(self.twittername, message) if should_twitter?
    rescue Exception => e        
      RAILS_DEFAULT_LOGGER.error("Twitter error while sending to #{self.twittername}. Message: #{message}. Exception: #{e.to_s}.")
    end
  end
    
  def claim spot
    return nil unless self.can_claim? spot

    my_claim = Claim.create :user => self, :spot => spot
    
    points = 100
    if my_claim.crossed_claim
      my_claim.crossed_claim.user.score -20, "fck! crossed by #{self.name} at #{spot.name}"
      self.score points, "crossed #{my_claim.crossed_claim.user.name} @ #{spot.name}"
    else
      self.score points, "claimed #{spot.name}"
    end
    
    my_claim
  end
  
  def owned_spots
    self.claims.collect do |claim|
      claim.spot if claim.spot.current_owner == self
    end.compact.uniq
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) || find_by_email(login)
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
  
  def claims_for_last_days_grouped_by_day days_count
    # this is totally not 100% correct and probably slow, but 1up doesn't mind as long as it gets the point across
    now = Time.new
    check_day = now - days_count.days
    
    claims = []
    while check_day <= now
      claims << self.claims.find(:all, :conditions => ["created_at >= ? and created_at < ?", check_day, check_day+1.days])
      check_day += 1.days
    end
    
    claims
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
    
    def update_twitter_friend
      if self.twitter_friend_with != self.twittername:
        begin
          TWITTER.create_friendship self.twittername if should_twitter? 
        rescue Exception => e
          RAILS_DEFAULT_LOGGER.error("Twitter error while creating_friendship with #{self.twittername}. Exception: #{e.to_s}.")
        end
        self.twitter_friend_with = self.twittername
      end
    end
end
