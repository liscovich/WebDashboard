# encoding: utf-8
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# if you are using Rails' asset pipeline
load 'deploy/assets'

# RVM details:
#set :using_rvm, true
set :rvm_ruby_string, "1.9.3"#@web_dashboard"
set :rvm_bin_path, "/usr/local/rvm/bin"
set :rvm_path, "/usr/local/rvm"
#set :rvm_type, :user  # Don't use system-wide RVM

require "rvm/capistrano"
require "bundler/capistrano" # adds `bundle install` to the list
require 'capistrano_colors'
#require 'hoptoad_notifier/capistrano'
#require "whenever/capistrano"

#set :whenever_command, "bundle exec whenever"
#set :whenever_environment, defer { stage } # for future stages

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/id_rsa", "#{ENV['HOME']}/.ssh/sweet_speeches"]

set :application, "econ_rails"

set :user, 'root'
set :password, 'hcpLab180'
set :use_sudo, false
set :sudo_prompt, "hcpLab180"
#set :verbose, true


# SCM details:
set :scm, :git
set :scm_verbose, true
set :git_enable_submodules, false
set :deploy_via, :remote_cache
set :repository,  "git@github.com:liscovich/WebDashboard.git"
set :branch, "photon_client"
set :keep_releases, 4

set :stack, :passenger
server "50.57.187.207", :web, :app, :db, :primary => true
#set :port, 28
set :deploy_to, "/var/www/#{application}"
set :rails_env, "production"
set :bundle_without, [:test, :development]

depend :remote, :gem, "bundler", ">=1.0.11"

namespace :deploy do
  task :restart, :roles => :app do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end

task :symlink_assets do
  [].each do |share|
    run "ln -s #{shared_path}/#{share} #{release_path}/#{share}"
  end
end

desc "tail production log files"
task :tail_log, :roles => :app do
  run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
    trap("INT") { puts 'Interupted'; exit 0; }
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

after 'deploy:update_code', :symlink_assets
after "deploy:update_code", "deploy:migrate"
after 'deploy:update', 'deploy:cleanup'