require 'eventmachine'
require 'faye'
require 'faye/redis'
require File.expand_path('../websocket/redis.rb', __FILE__)
DIRNAME = File.dirname(File.expand_path(__FILE__))
module Photon
  autoload :Socket, "#{DIRNAME}/photon/socket"
  autoload :WebSocket, "#{DIRNAME}/photon/web_socket"
  autoload :Client, "#{DIRNAME}/photon/client.rb"
end

EM.run do
  client = Photon::Client.new

  redis_server = Faye::Redis.create(Faye::Engine::Proxy.new({}), {host: 'localhost', namespace: 'server_'})
  redis_database = WebSocket::Redis.create({host: 'localhost', namespace: 'database_'})

  client.connect('localhost', {port: 9090})

  client.add_event_listener 'connect' do
    client.join('my_room')
  end

  client.add_custom_event_listener 123 do |data|
    data['channel'] = '/game'
    redis_server.publish(data, [])
    redis_database.publish(data)
  end

  client.add_event_listener 'join' do |data|
    client.raise_event(123, {message: 'test'})
  end

end
