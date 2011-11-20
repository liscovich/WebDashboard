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

get "/" do
  
  slim :"pages/home"
end

post "/game" do
  g = Game.new
  g.title = params[:title]
  g.description = params[:description]
  g.trialid = params[:trial_id]
  g.contprob = params[:cont_prob]
  g.cost_defect = params[:cost_defect]
  g.cost_coop = params[:cost_coop]
  g.ind_payoff_shares = params[:ind_payoff_shares]
  g.init_endow = params[:init_endow]
  g.totalplayers = params[:total_subjects]
  g.humanplayers = params[:human_subjects]
  g.save

  redirect_url = URI::escape("http://#{root_url}/game/#{g.id}")

  uri = URI("http://#{WINDOWS_SERVER_IP}/new")
  param = "-session=#{g.id} -server=#{WINDOWS_IP}:#{WINDOWS_PHOTON_PORT} -totalPlayers=#{params[:total_subjects]} -humanPlayers=#{params[:human_subjects]} -probability=0.8 -initialEndowments=100 -payout=0.6 -cardLowValue=0 -cardHighValue=10 -batchmode"

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
    hitt = RTurk::Hit.create(:title => "Play an econ game!" ) do |hit|
      hit.assignments = 15
      hit.description = 'Come play a game!'
      hit.question("http://econ.demo.s3.amazonaws.com/frame.html?redirect_url=#{redirect_url}" , :frame_height => 1000)
      #http://#{TARGET_SERVER_IP}/game/frame
      hit.reward = 0.05
      hit.duration = 240
      #hit.auto_approval = 1
      hit.lifetime = 240
      #hit.qualifications.add :approval_rate, { :gt => 80 }
    end

    h = Hit.new
    h.hitid = hitt.id
    h.url = hitt.url
    h.game_id = g.id
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

get "/game/:id/delete" do
  g = Game.get(params[:id])
  
  h = RTurk::Hit.find(g.hit_id)
  h.expire! if h

  g.destroy!
  redirect back
end

get "/game/:id" do
  @game = Game.get params[:id]
  @hiddens = {
    :webplayer=> "http://#{WINDOWS_SERVER_IP}/instance/#{@game.id}.unity3d"
  }
  slim :"pages/join"
end

get "/game/:id/join" do
  @game = Game.get params[:id]
  @hiddens = {
    :webplayer=> "http://#{WINDOWS_SERVER_IP}/instance/#{@game.id}.unity3d"
  }
  slim :"pages/join"
end

get "/game/:id/hit_details" do
  @game = Game.get params[:id]
  @hit = RTurk::Hit.find(@game.hit_id)
  slim :"pages/hit_detail"
end

get "/game/:id/approve" do
  g = Game.get params[:id]
  h = RTurk::Hit.find(g.hit_id)
  h.assignments.each do |a|
    a.approve! if a.status=='Submitted'
  end  
  g.update!(:approved=>true)
  redirect back
end

get "/hit/:id/dispose" do
  h = RTurk::Hit.find(params[:id])
  h.dispose!
  redirect back
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