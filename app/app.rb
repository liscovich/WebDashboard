require 'sinatra'

application = Sinatra::Application
DEV = application.environment!=:production or ENV['APP_ENV']=='production'
E   = DEV ? 'development' : 'production'

require 'sinatra/reloader' if DEV
require 'rack-flash'
require 'yajl/json_gem'
require 'compass'
require 'dm-postgres-adapter'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'dm-aggregates'
require 'dm-pager'
require 'slim'

ROOT        = File.expand_path(File.dirname(__FILE__))
RESET_CACHE = Time.now.to_i

set :root, ROOT   
set :public_folder, File.expand_path(ROOT+'/../public')
set :views , ROOT + "/views"
set :logging, false
set :run, true

require ROOT + '/config/config'
Dir[ ROOT + "/models/*.rb" ].each do |f| require f end
require ROOT + '/helpers'
Dir[ROOT+"/controllers/*.rb"].each{ |f| require f}


get "/" do
  slim :"pages/home"
end

get "/upgrade" do
  DataMapper.auto_upgrade!
  "upgraded"
end


not_found do
  "Not found."
end

error do
  "Error."
end