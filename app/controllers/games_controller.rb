class GamesController < ApplicationController
  respond_to :json, :only => [:template, :state]

  before_filter :find_experiment,     :only   => [:new, :create]
  before_filter :researcher_required, :only   => [:mturk, :new, :create, :dashboard]
  before_filter :find_game,           :except => [:new, :create, :delete_all, :frame]

  helper_method :unity_player_url

  def delete_all
    Game.transaction do
      [Game, Gameuser, Event].each &:destroy_all
    end
    WindowsServer.delete_all_instances

    redirect_to root_path, :notice => "Deleted all games!"
  end

  def frame
    render :layout => false
  end

  #callback from amazon
  def mturk
    unless current_user.authentications.mturk.exists?(:uid => params[:workerId])
      current_user.apply_mturk(:mturk_id => params[:workerId])
    end

    # vars for game
    session[:current_game] = {:worker_id => params[:workerId], :hit_id => params[:hitId], :assignment_id => params[:assignmentId]}

    redirect_to @game
  end

  def state
    respond_with([@game.state, @game.state_name])
  end

  def show
    unless signed_in?
      redirect_to new_user_session_path, :error => "You need to be logged in or coming from Amazon in order to play!"
    end

    @hide_header = true
    @no_default_side_bar = true
    @hide_navigation = true

    @hit = RTurk::Hit.find(params[:hitId]) if params[:hitId]

    @current_game = session[:current_game]

    @hiddens = {
      :userid    => current_user.id,
      :gameid    => @game.id,
      :isamazon  => (@current_game and @current_game[:worker_id] ? 1 : 0),
      :webplayer => unity_player_url
    }
  end

  def new
    @hero_unit_title = "Create Game"
    @games = Game.all
    @game  = @experiment.games.build
  end

  def create
    @game = @experiment.games.build(params[:game])
    @game.user = current_user

    if @game.save
      @game.post_mturk!(URI::escape(url_for([:mturk, @game])))

      redirect_to [:dashboard, @game], :notice => "You created a game!"
    else
      render :new
    end
  end

  def destroy
    @game.hits.each do |h|
      RTurk::Hit.find(h.hitid).try(:expire!)
    end
    @game.destroy

    redirect games_path
  end

  def log
    path = Rails.root.join("private/logs/#{params[:id]}").to_s

    unless File.exist? path
      #process logs
    end

    send_file path
  end

  def dashboard
    @hero_unit_title="Trial #{@game.id}"
    @hiddens = {:gameid => @game.id}

    @hiddens = {
      :gameid => @game.id
    }
  end

  def summary
    @hero_unit_title = "Game #{params[:id]} Summary"
    @gameusers = @game.gameusers(:mturk => false)
  end

  def template
    data = {
      :title => @game.title,
      :description => @game.description,
      :cont_prob => helpers.number_to_currency(@game.contprob),
      :init_endow => @game.init_endow,
      :cost_def => @game.cost_defect,
      :cost_coop => @game.cost_coop,
      :ind_pay_shares => helpers.number_to_currency(@game.ind_payoff_shares, :precision => 3),
      :exch_rate => helpers.number_to_currency(@game.exchange_rate),
      :tot_sub => @game.totalplayers,
      :hum_sub => @game.humanplayers
    }

    respond_with(data)
  end

  private

  def find_experiment
    @experiment = Experiment.find(params[:experiment_id])
  end

  def find_game
    @game = Game.find(params[:id])
    redirect_to root_path, :error => "Cannot find game!" unless @game
  end

  def unity_player_url
    WindowsServer.unity_player_url(@game)
  end
end
