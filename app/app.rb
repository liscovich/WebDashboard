require 'sinatra'

application = Sinatra::Application
DEV = application.environment!=:production and ENV['APP_ENV']!='production'
E = DEV ? 'development' : 'production'

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
require 'slim'
require 'rturk'

ROOT        = File.expand_path(File.dirname(__FILE__))
RESET_CACHE = Time.now.to_i

set :root, ROOT   
set :public_folder, File.expand_path(ROOT+'/../public')
set :views , ROOT + "/views"
set :logging, false
set :run, true

Dir[ ROOT + "/models/*.rb" ].each do |f| require f end
Dir[ROOT+"/controllers/*.rb"].each{ |f| require f}
require ROOT + '/config/config'
require ROOT + '/helpers'

get "/" do
  u = Test.new
  u.name = "Phillip"
  u.save
  slim :"pages/home"
end

get "/upgrade" do
  Test.auto_migrate!
  "upgraded"
end


not_found do
  "Not found."
end

error do
  "Error."
end