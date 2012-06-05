require 'daemons'

Daemons.run(File.expand_path('../database_worker.rb', __FILE__))
