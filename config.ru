require 'rubygems'
require 'bundler/setup'
require 'sinatra'
set :environment, :production

require './app/app'
run Sinatra::Application