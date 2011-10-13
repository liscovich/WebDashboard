require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './app/app'
require 'bowtie'

set :environment, :development

BOWTIE_AUTH = {:user => 'admin', :pass => 'caC1tuS23'}

map "/" do
  run Sinatra::Application
end

map "/admin" do
  run Bowtie::Admin
end