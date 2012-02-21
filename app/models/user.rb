class User < ActiveRecord::Base
  ROLES   = %W(player researcher)
  GENDERS = %W(male female)

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :username, :gender, :location, :institution, :telephone

  with_options :presence => true, :if => lambda{|u| u.authentications.blank? } do |a|
    a.validates :role,     :inclusion => ROLES
    a.validates :gender,   :inclusion => GENDERS
    a.validates :username, :uniqueness => true
  end

  has_many :authentications
  has_many :gameusers
  has_many :games
  has_many :experiments, :foreign_key => :creator_id

  scope :player,     where(:role   => 'player')
  scope :researcher, where(:role   => 'researcher')
  scope :male,       where(:gender => 'male')
  scope :female,     where(:gender => 'female')

  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank? and omniauth['user_info']
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def apply_mturk(mturk_hash)
    authentications.mturk.build(:uid => mturk_hash[:mturk_id])
  end

  def update_tracked_fields!(request)
    super(request) unless admin?
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
