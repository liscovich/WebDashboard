class User < ActiveRecord::Base
  ROLES   = %W(player researcher)
  GENDERS = %W(male female)
  
  # Include default devise modules. Others available are: https://github.com/plataformatec/devise
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :username, :gender

  validates :role,   :presence => true, :inclusion => ROLES
  validates :gender, :presence => true, :inclusion => GENDERS

  has_many :authentications
  has_many :gameusers
  has_many :games

  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def apply_mturk(mturk_hash)
    authentications.build(:provider => Authentication::METHODS[:mturk], :uid => mturk_hash[:mturk_id])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
  
  def get_name
    self.username || "User #{self.id}"
  end

  def authmethods_left
    @authmethods_left ||= authentications.authmethods_left
  end

  def researcher?
    role == 'researcher'
  end

  #TODO rewrite with Arel
  def unpaid_balance
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND gu.state=1 AND g.id=gu.game_id limit 1"
    res.first.earned || 0
  end

  def paid_balance
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=2 OR gu.state=4) AND g.id=gu.game_id limit 1"
    res.first.earned || 0
  end

  def rejected_balance
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=3) AND g.id=gu.game_id limit 1"
    res.first.earned || 0
  end

  def total_earned
    res = User.find_by_sql "SELECT SUM(g.exchange_rate * gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=2 OR gu.state=4) AND g.id=gu.game_id limit 1"
    res.first.earned || 0
#    joins().select("SUM(g.exchange_rate*gu.final_score) AS earned").first
  end
end
