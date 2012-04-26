require 'faye'
require 'faye/redis'
require File.expand_path('../lib/websocket/server.rb', __FILE__)

Faye::WebSocket.load_adapter('thin')

app = Faye::RackAdapter.new(
  mount: '/socket',
  engine: {
    type: Faye::Redis,
    host: 'localhost',
    namespace: 'server_'
  }
)

app.add_extension WebSocket::Server.new(namespace: 'database_')

run app
