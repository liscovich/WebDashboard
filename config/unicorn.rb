#corn.rb
# Set environment to development unless something else is specified
env = "production"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes 4

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/econ.socket", :backlog => 64

# Preload our app for more speed
preload_app true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

pid "/tmp/unicorn.econ.pid"

# Production specific settings
if env == "production"
  # Help ensure your application will always spawn in the symlinked
  # Help ensure your application will always spawn in the symlinked
  # "current" directory that Capistrano sets up.
  working_directory "/var/www/econ/current"

  # feel free to point this anywhere accessible on the filesystem
  user 'root'
  shared_path = "/var/www/econ/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection

  DataObjects::Pooling.pools.each do |pool|
     pool.dispose
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/tmp/unicorn.octomed.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  #$r = Redis.new
end

