class ResearcherMailer < BaseMailer
  default :host => DOMAINS[:researcher_home]

  def experiment_created(experiment, user)
    @experiment = experiment
    @user = user
    
    mail :to => user.email, :subject => "New experiment created"
  end

  def experiment_updated(experiment, user)
    @experiment = experiment
    @user = user

    mail :to => user.email, :subject => "Experiment updated"
  end

  def game_created(game, experiment, user)
    @experiment = experiment
    @game = game
    @user = user

    mail :to => user.email, :subject => "New game created"
  end
end
