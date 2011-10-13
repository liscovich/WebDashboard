load 'deploy' if respond_to?(:namespace)

default_run_options[:pty] = true

set :user,              'lucidrains1'
set :password,          'caC1tuS2!'
set :domain,            '69.164.201.59'
set :port,              28282
set :application,       'octomed'
set :repository,        "git@epicmafia.unfuddle.com:epicmafia/octomed.git"
set :scm,               "git"
set :scm_password,      "refinemenT1"
set :branch,            "master"

set :deploy_to,         "/var/www/octomed/" 
set :deploy_via,        :remote_cache
set :git_shallow_clone, 1
set :copy_strategy,     :export
set :copy_compression,  :bz2
set :use_sudo,          true
set :keep_releases,     2

server domain, :app, :web
ssh_options[:forward_agent] = true

def surun(command)
  password = fetch(:root_password, Capistrano::CLI.password_prompt("root password: "))
  run("sh - -c '#{command}'",:pty=>true) do |channel, stream, output|
    channel.send_data("#{password}\n") if output
  end
end

ROOT = "~/web/calc/"

namespace :local do
  task :delete_files do
    [
      
    ].each do |dir|
      `rm -r #{ROOT+dir+"/*"}`
    end
  end
end

namespace :passenger do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  task :symlink_uploads do
    [ 
    ].each do |upload_path|
      run "mkdir -p #{shared_path}/files/#{upload_path}"
      run "rm -rf #{current_path}/#{upload_path} && ln -nfs #{shared_path}/files/#{upload_path} #{current_path}/#{upload_path}"             
    end
  end   

  task :compile_javascript do
    filepath = File.expand_path(File.dirname(__FILE__))
    [
      #"/common.js",
      #"/app/*.js",
      #"/*.js",
      #"/soundmanager/*.js",
      #"/pagedown/*.js"
    ].each do |dirpath|
      Dir[filepath+"/public/javascripts"+dirpath].each do |path|
        path.gsub!(filepath,"")
        run "java -jar /var/www/compiler.jar --js=#{current_path}#{path} --js_output_file=/var/www/tmp.js --compilation_level=SIMPLE_OPTIMIZATIONS"
        run "cp -fr /var/www/tmp.js #{current_path+path}"
        run "rm /var/www/tmp.js"   
      end
    end
  end
  
  task :s3_upload do
    s3_files = {
      #"/stylesheets/style.css"=>["em.css","style.css"]
    }
    s3_files.each do |k,v|
      bucket, filename = v
      run "s3cmd put --acl-public --guess-mime-type #{current_path}/public#{k} s3://#{bucket}/#{filename}"
    end
    
    s3_directories = {
      #"/images" => ["em.css",""]
    }
    
    s3_directories.each do |k,v|
      bucket, path = v
      run "s3cmd put -r --acl-public --guess-mime-type #{current_path}/public#{k} s3://#{bucket}/#{path}"
    end
  end
  
  task :restart_memcached do
    run "sudo /etc/init.d/memcached restart"
  end
  
  task :restart_nginx do
    surun "/etc/init.d/nginx restart"
  end
  
  task :restart_god do
    surun "god restart resque"
  end
end

namespace :deploy do 
  task :restart, :roles => :app do 
  end 
end 

before :deploy, "deploy:web:disable"
after :deploy, "passenger:restart"
#after :deploy, "passenger:symlink_uploads"
after :deploy, "deploy:web:enable"
#after :deploy, "passenger:s3_upload"
#after :deploy, "passenger:compile_javascript"
after :deploy, "deploy:cleanup"
