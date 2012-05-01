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
    puts "Message have been read: #{message.inspect}"
    message = Yajl::Parser.parse(message)
    p Event.create!(message['data'])
  end
}
