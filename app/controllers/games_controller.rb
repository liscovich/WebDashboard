class GamesController < ApplicationController
  respond_to :json, :only => [:template, :state]

  before_filter :researcher_required, :only   => [:new, :create, :dashboard]
  before_filter :find_game,           :except => [:new, :delete_all, :frame]

  def delete_all
    Game.destroy_all
    Gameuser.destroy_all
    Event.destroy_all
    uri = URI("http://#{WINDOWS_SERVER_IP}/instance/delete_all")
    res = Net::HTTP.get(uri)

    redirect_to :games_path, :notice => "Deleted all games!"
  end

  def frame
    render :layout => false
  end

  #TODO recheck
  def mturk
    #unless is_logged_in?
    if am = Authmethod.mturk.where(:auth_id=>params[:workerId]).first
      p am.inspect
      am.user.sign_in!(session)
#      sign_in(u)
    else
      u = User.create_user_with_provider('mturk', params[:workerId])
      sign_in(u)
    end
    #end

    redirect_to @game
  end

  def state
    respond_with([@game.state, @game.state_name])
  end

  def listing
    #TODO blank?
  end

  def show
    unless logged_in?
      flash[:error] = "You need to be logged in or coming from Amazon in order to play!"
      deny!
    end

    @hide_header = true
    @no_default_side_bar = true
    @hide_navigation = true

    @hit = RTurk::Hit.find(params[:hitId]) if params[:hitId]

    @hiddens = {
      :userid => session[:id],
      :gameid => @game.id,
      :isamazon => (params[:workerId].nil? ? 0 : 1),
      :webplayer => "http://#{WINDOWS_SERVER_IP}/instance/#{@game.id}.unity3d"
    }
  end

  def new
    @hero_unit_title = "Create Game"
    @games = Game.all
  end

  def create
    #TODO refactor!!
    @game = current_user.games.build
    @game.title = params[:title]
    @game.description = params[:description]
    @game.contprob = params[:cont_prob]
    @game.cost_defect = params[:cost_defect]
    @game.cost_coop = params[:cost_coop]
    p params[:ind_payoff_shares].to_f
    @game.ind_payoff_shares = params[:ind_payoff_shares].to_f
    @game.init_endow = params[:init_endow]
    @game.totalplayers = params[:total_subjects]
    @game.humanplayers = params[:human_subjects]
    @game.exchange_rate = params[:exchange_rate]

    unless @game.save
      render :new and return
    end

    redirect_url = URI::escape(url_for([:mturk, @game]))

    uri = URI("http://#{WINDOWS_SERVER_IP}/new")
    param = "-session=#{@game.id} -server=#{WINDOWS_IP}:#{WINDOWS_PHOTON_PORT} -totalPlayers=#{params[:total_subjects]} -humanPlayers=#{params[:human_subjects]} -probability=#{@game.contprob} -initialEndowments=#{@game.init_endow} -payout=#{@game.ind_payoff_shares} -cardLowValue=#{@game.cost_defect} -cardHighValue=#{@game.cost_coop} -exchangeRate=#{@game.exchange_rate} -batchmode"

    res = Net::HTTP.post_form(uri, 'id'=>@game.id, 'instance'=>'test', 'args'=>param)

    if res.code!="200"
      @game.destroy
      return res.body
      #flash_back "Cannot not start up master client!"
    end

    #uri = URI("http://#{WINDOWS_SERVER_IP}/instance/#{g.id}.unity3d")
    #res = Net::HTTP.get(uri)

    #File.open(ROOT+"/../public/flash/webplayer.unity3d", "wb") do |file|
    #  file.write(res)
    #end

    @game.humanplayers.times do
      #TODO refactor
      hitt = RTurk::Hit.create(:title => "Come play a card game!") do |hit|
        hit.hit_type_id = HIT_TYPE.type_id
        hit.assignments = 1
        hit.description = "More card games!"
        hit.question("http://card.demo.s3.amazonaws.com/frame.html?redirect_url=#{redirect_url}" , :frame_height => 1000)
        hit.keywords = 'card, game, economics'
        hit.reward = 0.01
        hit.lifetime = 240
        hit.duration = 240
      end

      h = Hit.new
      h.hitid = hitt.id
      h.url = hitt.url
      h.game_id = @game.id
      h.sandbox = RTurk.sandbox?
      h.save
    end

    @game.save!
    
    redirect_to [@game, :dashboard], :notice => "You created a game!"
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

  def find_game
    @game = Game.find(params[:id])
    redirect_to root_path, :error => "Cannot find game!" unless @game
  end
end
