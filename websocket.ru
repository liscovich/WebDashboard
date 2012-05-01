require 'faye'
require 'faye/redis'
require File.expand_path('../lib/settings.rb', __FILE__)
require File.expand_path('../lib/websocket/server.rb', __FILE__)

Faye::WebSocket.load_adapter('thin')

app = Faye::RackAdapter.new(
    mount:  '/socket',
    engine: {
        type:      Faye::Redis,
        host:      FAYE_REDIS_SERVER,
        namespace: FAYE_REDIS_NAMESPACE
    }
)

app.add_extension WebSocket::Server.new

run app
