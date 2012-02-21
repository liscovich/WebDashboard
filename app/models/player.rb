class Player < User
  default_values :role => 'player'

  # Include default devise modules. Others available are: https://github.com/plataformatec/devise
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :authentication_keys => [:username]
end
