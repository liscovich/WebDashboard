require 'daemons'

Daemons.run(File.expand_path('../photon_client.rb', __FILE__))