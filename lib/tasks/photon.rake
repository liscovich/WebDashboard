namespace :photon do
  task :start_websocket_server do
    system "rackup websocket.ru -s thin -p 9292 -E production"
  end

  task :start_client do
    system "ruby lib/photon_client_service.rb start"
  end

  task :stop_client do
    system "ruby lib/photon_client_service.rb stop"
  end

  task :start_database_worker do
    system "ruby lib/database_worker_service.rb start"
  end

  task :stop_database_worker do
    system "ruby lib/database_worker_service.rb stop"
  end

end
