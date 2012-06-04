require 'eventmachine'
require 'faye'
require 'faye/redis'

require File.expand_path('../settings.rb', __FILE__)

require File.expand_path('../websocket/redis.rb', __FILE__)

DIRNAME = File.dirname(File.expand_path(__FILE__))

module Photon
  autoload :Socket, "#{DIRNAME}/photon/socket"
  autoload :WebSocket, "#{DIRNAME}/photon/web_socket"
  autoload :Client, "#{DIRNAME}/photon/client.rb"
end

EM.run do
  client = Photon::Client.new

  redis_server   = Faye::Redis.create(Faye::Engine::Proxy.new({}), host: FAYE_REDIS_SERVER, namespace: FAYE_REDIS_NAMESPACE)
  redis_database = WebSocket::Redis.create(host: FAYE_REDIS_SERVER, namespace: REDIS_NAMESPACE)

  client.connect(PHOTON_SERVER_HOST, port: PHOTON_SERVER_PORT)

  client.add_event_listener 'connect' do
    client.authenticate("v1.0", "Master")
  end

  client.add_custom_event_listener 210 do |data|
    data = data[:vals]

    data            = data[Photon::Client::PARAMETER_CODES[:data].to_s]
    game_id         = data[Photon::Client::PARAMETER_CODES[:game_id].to_s]
    puts "GameID: #{game_id}"

    game_event_data = data[Photon::Client::PARAMETER_CODES[:data].to_s]

    game_event_data['channel'] = "/#{game_id}"

    puts "Game Event Data: #{game_event_data.inspect}"
    puts "All Data: #{data.inspect}"

    redis_server.publish(game_event_data, [])
    redis_database.publish(data)
  end

  client.add_custom_response_listener 230 do |data|
    client.join_lobby
  end
end
