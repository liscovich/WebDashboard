class User
  attr_accessor :initial_password, :initial_password_confirmation

  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :complete, Boolean
  property :username, String
  property :email, String
  property :password, String

  property :age, Integer
  property :location, String
  property :bio, Text
  property :gender, Boolean

  property :institution, String
  property :telephone, String

  property :role, Enum[:player, :researcher, :admin], :default=>:player
    
  validates_presence_of       :username,          
                              :when=>[:newuser],
                              :message=>"You must enter a username!"

  validates_uniqueness_of     :username,          
                              :when=>[:newuser],
                              :message=>"This username is already taken!"

  validates_format_of         :username, :with=> /^[a-zA-Z0-9]+$/, 
                              :when=>[:newuser],
                              :message=>"Your username must be alphanumeric!"

  validates_length_of         :username, :within=>(4..20),
                              :when=>[:newuser],
                              :message=>"Your username must be greater than 3 characters and less than 20 characters."
 
  validates_presence_of       :email,             
                              :when=>[:newuser],
                              :message=>"You must enter an email!"

  validates_uniqueness_of     :email,             
                              :when=>[:newuser],
                              :message=>"Your email was already taken!"

  validates_format_of        :email, :as=>:email_address, 
                             :when=>[:newuser],
                             :message=>"This doesn't look like an email address!"
  
  validates_presence_of      :initial_password,  
                             :when=>[:newuser, :newpass],
                             :message=>"You must enter a password!"

  validates_confirmation_of :initial_password,
                            :when=>[:newuser, :newpass],
                            :message=>"You must type the same password again!"
  
  def get_name
    self.username || "User #{self.id}"
  end

  def get_gender
    self.gender ? 'male' : 'female'
  end

  def self.auth(user)
    u = first(:username=>user['username'])
    return nil if u.nil?  
    return u if u.is_password?(user['password'])
    nil
  end
  
  def is_password?(pass)
    password = self.password[0..39]
    salt     = self.password[40..49]
    return User.encrypt(pass, salt) == password
  end
  
  def initial_password=(pass)
    @initial_password = pass
    salt            = User.random_string(10)
    self.password   = User.encrypt(self.initial_password, salt)+salt
  end
  
  def initial_password_confirmation=(conf)  
    @initial_password_confirmation = conf
  end

  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
  def self.encrypt(pass,salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def sign_in!(session)
    session[:id] = self.id
    session[:username] = self.username
    session[:role] = self.role.to_s
  end

  def self.create_user_with_provider(provider, uid)
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

  def get_unpaid_balance
    res = DataMapper.repository(:default).adapter.query "SELECT SUM(g.exchange_rate*gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND gu.state=1 AND g.id=gu.game_id"
    res.first
  end

  def get_paid_balance
    res = DataMapper.repository(:default).adapter.query "SELECT SUM(g.exchange_rate*gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=2 OR gu.state=4) AND g.id=gu.game_id"
    res.first
  end

  def get_rejected_balance
    res = DataMapper.repository(:default).adapter.query "SELECT SUM(g.exchange_rate*gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=3) AND g.id=gu.game_id"
    res.first
  end

  def get_total_earned
    res = DataMapper.repository(:default).adapter.query "SELECT SUM(g.exchange_rate*gu.final_score) AS earned FROM games g, gameusers gu WHERE gu.user_id=#{self.id} AND (gu.state=2 OR gu.state=4) AND g.id=gu.game_id"
    res.first
  end



  has n, :authmethods
  has n, :gameusers
  has n, :games
end