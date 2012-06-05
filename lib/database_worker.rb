require 'yajl'
require 'active_record'

require File.expand_path('../../config/environment', __FILE__)

require File.expand_path('../settings.rb', __FILE__)

require File.expand_path('../../app/models/event.rb', __FILE__)
require File.expand_path('../websocket/redis.rb', __FILE__)

EM.run {
  redis = WebSocket::Redis.create(host: FAYE_REDIS_SERVER, namespace: REDIS_NAMESPACE)

  redis.subscribe

  redis.onmessage do |message|
    message = Yajl::Parser.parse(message)
    event_data = message["245"]

    event_data["game_id"]  = message["255"]

    Event.create!(event_data)
  end
}
