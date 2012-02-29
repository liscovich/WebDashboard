class Researcher < User
  default_values :role => 'researcher'

  # Include default devise modules. Others available are: https://github.com/plataformatec/devise
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :authentication_keys => [:username]

  scope :except_me, lambda{|user| where(["id != ?", user.id]) }

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def email_required?
    authentications.blank?
  end
end
