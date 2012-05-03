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
  room   = "ruby16"

  redis_server   = Faye::Redis.create(Faye::Engine::Proxy.new({}), host: FAYE_REDIS_SERVER, namespace: FAYE_REDIS_NAMESPACE)
  redis_database = WebSocket::Redis.create(host: FAYE_REDIS_SERVER, namespace: REDIS_NAMESPACE)

  client.connect(PHOTON_SERVER_HOST, port: PHOTON_SERVER_PORT)

  client.add_event_listener 'connect' do
    client.join(room)
  end

  client.add_custom_event_listener room do |data|
    data['channel'] = '/messages'

    redis_server.publish(data, [])
    redis_database.publish(data)
  end

  client.add_event_listener room do |data|
    data['channel'] = '/messages'
  end

  client.add_event_listener 'join' do |data|
    client.raise_event(16, event_type: 'new_round', state_name: 'state_name', round_id: 1, user_id: 1, ai_id: 'true')
  end

  EventMachine.add_periodic_timer(10) do
    #client.raise_event(16, event_type: 'gamestate_update', state_name: 'state_name', round_id: 1, user_id: 1, ai_id: 'true')
    redis_server.publish({"channel" => "/messages",
                          data:     {
                              "state_name"  => "Finished",
                              "ai_id"       => "true",
                              "event_type"  => "gamestate_update",
                              "user_id"     => 1,
                              "player_id"   => 1,
                              "choice"      => 3,
                              "total_score" => 1,
                              "score"       => 1,
                              "round_id"    => 1}},
                         [])
  end
end