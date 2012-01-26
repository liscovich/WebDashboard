class User < ActiveRecord::Base
  attr_accessor :initial_password, :initial_password_confirmation
  
  validates :username, :presence => true, :uniqueness => true, :format => { :with => /^[a-zA-Z0-9]+$/}, :length => 4..20
  validates :email,    :presence => true, :uniqueness => true, :format => { :with => //}

  validates :initial_password, :presence => true, :confirmation => true
#                             :when=>[:newuser, :newpass],

  has_many :authmethods
  has_many :gameusers
  has_many :games

  class << self
    def auth(user)
      u = where(:username => user['username']).first
      return nil unless u

      return u if u.is_password?(user['password'])
      nil
    end

    def random_string(len)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) {|i| newpass << chars[rand(chars.size-1)] }

      newpass
    end

    def encrypt(pass,salt)
      Digest::SHA1.hexdigest(pass+salt)
    end

    def create_user_with_provider(provider, uid)
      u = User.new
      u.complete = false
      u.save

      am = Authmethod.new
      am.auth_type = provider
      am.auth_id = uid
      am.user_id = u.id
      am.save

      u
    end
  end
  
  def get_name
    self.username || "User #{self.id}"
  end

  def get_gender
    self.gender ? 'male' : 'female'
  end

  def researcher?
    role == 'researcher'
  end

  def is_password?(pass)
    password = self.password[0..39]
    salt     = self.password[40..49]
    return User.encrypt(pass, salt) == password
  end

  def initial_password=(pass)
    @initial_password = pass
    salt            = User.random_string(10)
    self.password   = User.encrypt(self.initial_password, salt) + salt
  end

  def initial_password_confirmation=(conf)
    @initial_password_confirmation = conf
  end

  def get_unpaid_balance
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND gu.state=1 AND g.id=gu.game_id limit 1"
    res.first
  end

  def get_paid_balance
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=2 OR gu.state=4) AND g.id=gu.game_id limit 1"
    res.first
  end

  def get_rejected_balance
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=3) AND g.id=gu.game_id limit 1"
    res.first
  end

  def get_total_earned
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=2 OR gu.state=4) AND g.id=gu.game_id limit 1"
    res.first
#    joins().select("SUM(g.exchange_rate*gu.final_score) AS earned").first
  end
end
