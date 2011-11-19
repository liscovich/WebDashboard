require 'rubygems'
require 'bundler/setup'
require 'sinatra'

set :environment, :development
require './app/app'

run Sinatra::Application