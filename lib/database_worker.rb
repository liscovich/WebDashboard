require 'yajl'
require 'active_record'
require File.expand_path('../../app/models/event.rb', __FILE__)
require File.expand_path('../websocket/redis.rb', __FILE__)

EM.run {
  redis = WebSocket::Redis.create(host:'localhost', namespace: 'database_')
  redis.subscribe
  redis.onmessage do |message|
    message = Yajl::Parser.parse(message)
    Event.create(message['data'])
  end
}
