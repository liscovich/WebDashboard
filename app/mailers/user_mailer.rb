class UserMailer < BaseMailer
  default :host => DOMAINS[:user_home]
  
  def game_created(game, user)
    @game = game
    @user = user

    mail :to => user.email, :subject => "New game created"
  end
end
