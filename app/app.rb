require 'sinatra'

application = Sinatra::Application
DEV = application.environment!=:production and ENV['APP_ENV']!='production'
E = DEV ? 'development' : 'production'

require 'net/http'
require 'sinatra/reloader' if DEV
require 'rack-flash'
require 'yajl/json_gem'
require 'compass'
require 'do_mysql'
require 'dm-mysql-adapter'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'dm-aggregates'
require 'dm-serializer'
require 'dm-pager'
require 'dm-types'
require 'slim'
require 'rturk'
require 'omniauth'
#require 'omniauth-openid'
require 'omniauth-facebook'
#require 'openid/store/filesystem'

ROOT        = File.expand_path(File.dirname(__FILE__))
RESET_CACHE = Time.now.to_i

set :root, ROOT   
set :public_folder, File.expand_path(ROOT+'/../public')
set :views , ROOT + "/views"
set :logging, DEV
set :run, true

Dir[ ROOT + "/models/*.rb" ].each do |f| require f end
Dir[ROOT+"/controllers/*.rb"].each{ |f| require f}
require ROOT + '/config/config'
require ROOT + '/helpers'

get "/" do
  redirect '/trials' if is_logged_in?
  @hero_unit_title = "Welcome!"
  slim :"pages/signup"
end

get "/trials" do
  redirect_flash '/', :error, "You need to be logged in to see the games!" unless is_logged_in?  
  @games = Game.all(:order=>[:created_at.desc])
  @hero_unit_title = "Trials"
  slim :"pages/trial"
end

get "/experiments" do
  redirect_flash '/', :error, "You need to be logged in to see the games!" unless is_logged_in? and is_researcher
  slim :"pages/experiments", :layout=>false
end

post "/authmethod/mturk" do
  login_required
  Authmethod.create({
    :user_id=>session[:id],
    :auth_type=>'mturk',
    :auth_id=>params[:mturk_id] 
  })
  flash_back "You linked yourself to MTurk!"
end

get '/auth/:provider_id/callback' do 
  case params[:provider_id]
    when 'facebook'
      provider = request.env['omniauth.auth']['provider']
      uid = request.env['omniauth.auth']['uid']
  end

  if is_logged_in?
    Authmethod.create({
      :auth_type=>provider,
      :auth_id=>uid,
      :user_id=>session[:id]
    })
    redirect_id = session[:id]
  else
    u = Authmethod.find_user_by_provider(provider,uid)
    u = User.create_user_with_provider(provider, uid) if u.nil?
    u.sign_in!(session)
    redirect_id = u.id
  end
  redirect "/user/#{redirect_id}"
end 

get "/admin_console" do
  slim :"pages/home"
end

post "/game" do
  flash_back "You cannot create a game unless you are a researcher!" unless is_researcher

  g = Game.new
  g.user_id = session[:id]
  g.created_at = Time.now
  g.title = params[:title]
  g.description = params[:description]
  g.contprob = params[:cont_prob]
  g.cost_defect = params[:cost_defect]
  g.cost_coop = params[:cost_coop]
  p params[:ind_payoff_shares].to_f
  g.ind_payoff_shares = params[:ind_payoff_shares].to_f
  g.init_endow = params[:init_endow]
  g.totalplayers = params[:total_subjects]
  g.humanplayers = params[:human_subjects]
  g.exchange_rate = params[:exchange_rate]
  g.save

  flash_back(g.errors.full_messages.first) unless g.errors.empty?
  
  redirect_url = URI::escape("http://#{root_url}/game/#{g.id}/mturk")

  uri = URI("http://#{WINDOWS_SERVER_IP}/new")
  param = "-session=#{g.id} -server=#{WINDOWS_IP}:#{WINDOWS_PHOTON_PORT} -totalPlayers=#{params[:total_subjects]} -humanPlayers=#{params[:human_subjects]} -probability=#{g.contprob} -initialEndowments=#{g.init_endow} -payout=#{g.ind_payoff_shares} -cardLowValue=#{g.cost_defect} -cardHighValue=#{g.cost_coop} -exchangeRate=#{g.exchange_rate} -batchmode"

  res = Net::HTTP.post_form(uri, 'id'=>g.id, 'instance'=>'test', 'args'=>param)

  if res.code!="200"
    g.destroy!
    return res.body
    #flash_back "Cannot not start up master client!"
  end

  #uri = URI("http://#{WINDOWS_SERVER_IP}/instance/#{g.id}.unity3d")
  #res = Net::HTTP.get(uri)
  
  #File.open(ROOT+"/../public/flash/webplayer.unity3d", "wb") do |file|
  #  file.write(res)
  #end
  
  g.humanplayers.times do

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
    h.game_id = g.id
    h.sandbox = RTurk.sandbox?
    h.save
  end

  g.save
  redirect_flash "/game/#{g.id}/dashboard", :error, "You created a game!"
end

get "/game/listing" do

end

get "/game/create" do
  flash_back "Only researchers can create games!" unless is_researcher
  @hero_unit_title = "Create Game"
  @games = Game.all
  slim :"pages/game_create"
end

get "/game/delete_all" do
  Game.all.destroy!
  Gameuser.all.destroy!
  Event.all.destroy!
  uri = URI("http://#{WINDOWS_SERVER_IP}/instance/delete_all")
  res = Net::HTTP.get(uri)
  flash_back "Deleted all games!"
end

get "/game/frame" do
  slim :"/pages/game_frame", :layout=>false
end

get "/game/events" do
  content_type :json
  events = Event.all(:game_id=>params[:game_id].to_i, :id.gt=>params[:id])

  events.map{ |e|
    {
      :id           => e.id,
      :user_id      => e.user_id,
      :event_type   => e.event_type,
      :state        => e.state,
      :state_name   => (e.state.nil? ? nil : Game.get_state_name(e.state)),
      :choice       => e.choice,
      :round_id     => e.round_id,
      :total_score  => e.total_score,
      :score        => e.score
    }.reject{|k,v| v.nil? }
  }.to_json
end

get "/game/:id/state" do
  g = Game.get params[:id]
  [g.state, g.state_name].to_json
end

get "/game/:id/delete" do
  g = Game.get(params[:id])
  
  g.hits.each do |h|
    hh = RTurk::Hit.find(h.hitid)
    hh.expire! if hh
  end

  g.destroy!
  redirect back
end

get "/game/:id/mturk" do
  #unless is_logged_in?
    am = Authmethod.first(:auth_type=>'mturk', :auth_id=>params[:workerId])
    p am.inspect
    if am.nil?
      u = User.create_user_with_provider('mturk', params[:workerId])

      u.sign_in!(session)
    else
      am.user.sign_in!(session)
    end
  #end

  request.path_info = "/game/#{params[:id]}"
  pass
end

get "/game/:id" do
  redirect_flash '/',:error, "You need to be logged in or coming from Amazon in order to play!" unless is_logged_in?

  @hide_header = true
  @game = Game.get params[:id]
  @no_default_side_bar = true
  @hide_navigation = true
  flash_back("Cannot find game!") if @game.nil?
  
  if params[:hitId]
    @hit = RTurk::Hit.find(params[:hitId])
  end
  
  @hiddens = {
    :userid=>session[:id],
    :gameid=>@game.id,
    :isamazon=>(params[:workerId].nil? ? 0 : 1),
    :webplayer=> "http://#{WINDOWS_SERVER_IP}/instance/#{@game.id}.unity3d"
  }
  slim :"pages/join"
end

get "/game/:id/summary" do
  flash_back "You must be a researcher!" unless is_researcher
  @game = Game.get params[:id]
  slim :"pages/summary"
end

get "/game/:id/dashboard" do
  flash_back "You must be a researcher!" unless is_researcher
  

  @game = Game.get params[:id]
  @hero_unit_title="Trial #{@game.id}"
  @hiddens = {
    :gameid=>@game.id
  }
  slim :"pages/game_dashboard"
end

get "/game/:id/hit_details" do
  @game = Game.get params[:id]
  slim :"pages/hit_detail"
end

get "/game/:id/log" do
  @game = Game.get params[:id]
  flash_back "Cannot find game!" if @game.nil?

  path = ROOT + "/private/logs/#{params[:id]}"
  
  if !File.exist? path
    #process logs
  end
  
  send_file path
end

get "/game/:id/template" do
  content_type :json
  @game = Game.get params[:id]
  {
    :title => @game.title,
    :description=> @game.description,
    :cont_prob=> display_decimal(2,@game.contprob),
    :init_endow=> @game.init_endow,
    :cost_def => @game.cost_defect,
    :cost_coop => @game.cost_coop,
    :ind_pay_shares=> display_decimal(2,@game.ind_payoff_shares),
    :exch_rate=> display_decimal(3,@game.exchange_rate),
    :tot_sub=> @game.totalplayers,
    :hum_sub=> @game.humanplayers
  }.to_json
end

get "/gameuser/get_earnings" do
  content_type :json
  gu = Gameuser.first(:user_id=>params[:user_id], :game_id=>params[:game_id])
  return [0].to_json if gu.nil? or gu.final_score.nil?
  [1, display_decimal(2,gu.final_score*gu.game.exchange_rate)].to_json
end

get "/gameuser/record_submission" do
  content_type :json
  gu = Gameuser.first(:user_id=>params[:user_id],:game_id=>params[:game_id])
  return [0].to_json if gu.nil? or gu.final_score.nil?
  gu.mturk = false
  gu.save
  [1].to_json
end

get "/gameuser/:id/pay" do
  gu = Gameuser.get params[:id]
  gu.state = :approved
  gu.save
  flash_back "You paid #{gu.user.get_name}!"
end

get "/hit/dispose_all" do
  p1 = fork do
    hits = RTurk::Hit.all_reviewable
    hits.each do |hit|
      hit.expire!
      hit.assignments.each do |a|
        a.approve!
      end
      hit.dispose!
    end
  end
  Process.detach p1

  flash_back "Disposed all hits!"
end

get "/hit/:id/dispose" do
  h = RTurk::Hit.find(params[:id])
  h.dispose! if h
  flash_back "You disposed of a HIT!"
end


before "/hit/:id/*" do
  flash_back "You must be a researcher!" unless is_researcher
  @hit = RTurk::Hit.find(params[:id])
  flash_back "Cannot find HIT!" if @hit.nil?
  pass
end

get "/hit/:id/approve" do
  @hit.assignments.each do |a|
    a.approve! if a.status=='Submitted'
    am = Authmethod.first(:auth_type=>'mturk', :auth_id=>a.worker_id)
    h = Hit.first(:hitid=>params[:id])
    if am and h      
      gu = Gameuser.first(:user_id=>am.user_id, :game_id=>h.game_id)
      gu.mturk_id = am.auth_id
      gu.mturk = true
      gu.state = :approved
      gu.save
    end
  end  
  @hit.expire!
  flash_back "You approved hit id #{params[:id]}!"
end

get "/hit/:id/reject" do
  reason = params[:reason] || 'You did not finish the assignment properly!'
  @hit.assignments.each do |a|
    a.reject!(reason) if a.status=='Submitted'
    am = Authmethod.first(:auth_type=>'mturk', :auth_id=>a.worker_id)
    h = Hit.first(:hitid=>params[:id])
    if am and h
      gu = Gameuser.first(:user_id=>am.user_id, :game_id=>h.game_id)
      gu.mturk_id = am.auth_id
      gu.mturk = true
      gu.state = :rejected
      gu.save
    end
  end
  @hit.expire!
  flash_back "You rejected hit id #{params[:id]}"
end

get "/hit/:id/bonus" do
  @hit.assignments.each do |a|
    if a.status=='Submitted'
      am = Authmethod.first(:auth_type=>'mturk', :auth_id=>a.worker_id)
      h = Hit.first(:hitid=>params[:id])
      if am and h
        gu = Gameuser.first(:user_id=>am.user_id, :game_id=>h.game_id)
        gu.mturk_id = am.auth_id
        gu.mturk = true
        gu.bonus_amount = (h.game.exchange_rate*gu.final_score).round(2)
        gu.state = :bonused
        gu.save

        a.bonus!(gu.bonus_amount, "You earned $#{gu.bonus_amount} from doing well this round!")
        a.approve!
      end
    end
  end
  @hit.expire!
  flash_back "You bonused hit id #{params[:id]} with amount #{params[:amount]}"
end

get "/hit/:id/dispose" do
  @hit.dispose!
  redirect back
end

get "/signup" do
  slim :"pages/signup"
end

get "/user/:id" do
  @user = User.get params[:id]
  flash_back "No user exists!" if @user.nil?

  @authmethods_left = ['facebook', 'mturk']
  authmethods_used = @user.authmethods.map{|am| am.auth_type }
  @authmethods_left -= authmethods_used

  slim :"pages/user"
end

get "/user/:id/edit" do
  @user = User.get params[:id]
  flash_back "No user exists!" if @user.nil?
  slim :"pages/user_edit"
end

get "/directory" do
  slim :"pages/directory"
end

get "/logout" do
  session.clear
  redirect_flash '/',:error, "Goodbye!"
end

post "/login" do
  u = User.auth(params[:user])
  flash_back "Your login information is incorrect!" if u.nil?
  u.sign_in!(session)
  redirect_flash '/trials', :error, "You are now logged in!"
end

post "/user" do
  u = User.new
  u.username = params[:username]
  u.email = params[:email]
  u.initial_password = params[:password]
  u.initial_password_confirmation = params[:confirm_password]
  u.complete = true
  u.role = (params[:is_researcher]=='on' ? :researcher : :player)
  u.save :newuser

  flash_back(u.errors.full_messages.first) unless u.errors.empty?

  u.sign_in!(session)
  flash_back "Created you in the system!"
end

post "/user/complete" do
  login_required
  
  u = current_user
  u.username = params[:username]
  u.initial_password = params[:password]
  u.initial_password_confirmation = params[:confirm_password]
  u.email = params[:email]
  u.complete = true
  u.save :newuser

  flash_back(u.errors.full_messages.first) unless u.errors.empty?

  session[:username] = u.username
  flash_back "You completed your profile!"
end

post "/user/info" do
  login_required
  u = current_user
  u.age = params[:age]
  u.location = params[:location]
  u.bio = params[:bio]
  u.gender = params[:gender]=='1'
  u.save

  flash_back "You edited your profile!"
end

post "/user/info/researcher" do
  login_required
  u = current_user
  u.location = params[:location]
  u.telephone = params[:telephone]
  u.institution = params[:institution]
  u.save

  flash_back "You edited your profile!"
end

post "/user/password" do
  login_required
  u = current_user
  u.initial_password = params[:password]
  u.initial_password_confirmation = params[:confirm_password]
  u.save :newpass

  flash_back(u.errors.full_messages.first) unless u.errors.empty?

  flash_back "You changed your password!"
end

get "/upgrade" do
  DataMapper.auto_migrate!
  "upgraded"
end

not_found do
  "Not found."
end

error do
  "Error."
end