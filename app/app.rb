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
require 'dm-pager'
require 'dm-types'
require 'slim'
require 'rturk'

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

get "/admin_console" do
  
  slim :"pages/home"
end

post "/game" do
  p params.inspect
  g = Game.new
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
  g.save

  flash_back(g.errors.full_messages.first) unless g.errors.empty?
  
  redirect_url = URI::escape("http://#{root_url}/game/#{g.id}")

  uri = URI("http://#{WINDOWS_SERVER_IP}/new")
  param = "-session=#{g.id} -server=#{WINDOWS_IP}:#{WINDOWS_PHOTON_PORT} -totalPlayers=#{params[:total_subjects]} -humanPlayers=#{params[:human_subjects]} -probability=#{g.contprob} -initialEndowments=#{g.init_endow} -payout=#{g.ind_payoff_shares} -cardLowValue=#{g.cost_defect} -cardHighValue=#{g.cost_coop} -batchmode"

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
  flash_back "You created a game!"
end

get "/game/delete_all" do
  Game.all.destroy!
  uri = URI("http://#{WINDOWS_SERVER_IP}/instance/delete_all")
  res = Net::HTTP.get(uri)
  flash_back "Deleted all games!"
end

get "/game/frame" do
  slim :"/pages/game_frame", :layout=>false
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

get "/game/:id" do
  @game = Game.get params[:id]
  flash_back("Cannot find game!") if @game.nil?
  if params[:hitId]
    @hit = RTurk::Hit.find(params[:hitId])
  end
  @hiddens = {
    :gameid=>@game.id,
    :webplayer=> "http://#{WINDOWS_SERVER_IP}/instance/#{@game.id}.unity3d"
  }
  slim :"pages/join"
end

get "/game/:id/dashboard" do
  @game = Game.get params[:id]
  slim :"pages/game_dashboard"
end

get "/game/:id/hit_details" do
  @game = Game.get params[:id]
  slim :"pages/hit_detail"
end

get "/game/:id/approve" do
  g = Game.get params[:id]
  g.hits.each do |hit|
    h = RTurk::Hit.find(hit.hitid)
    h.assignments.each do |a|
      a.approve! if a.status=='Submitted'
    end  
    g.update!(:approved=>true)
    h.expire!
  end
  flash_back "You approved all assignments!"
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
  @hit = RTurk::Hit.find(params[:id])
  flash_back "Cannot find HIT!" if @hit.nil?
  pass
end

get "/hit/:id/approve" do
  @hit.assignments.each do |a|
    a.approve! if a.status=='Submitted'
  end  
  @hit.expire!
  flash_back "You approved hit id #{params[:id]}!"
end

get "/hit/:id/reject" do
  @hit.assignments.each do |a|
    a.reject! if a.status=='Submitted'
  end
  @hit.expire!
  flash_back "You rejected hit id #{params[:id]}"
end

get "/hit/:id/bonus" do
  @hit.assignments.each do |a|
    a.bonus!(params[:amount], params[:reason])
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
end

post "/user" do
  u = User.new
  if params[:mturk_id]
    u.mid = params[:mturk_id]
    u.fake = false
  else
    u.fake = true
  end
  u.save
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