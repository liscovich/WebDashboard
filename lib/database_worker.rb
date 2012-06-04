require 'yajl'
require 'active_record'
require 'active_support'

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

    data = {}
    event_data.each_pair do |k, v|
      data[k.underscore] = v
    end
    event_data.delete 'channel'
    data.delete 'round'

    data["round_id"] = event_data["round"]
    data["game_id"]  = message["255"]

    puts "New data: #{data}"


    # p Event.create!(data)
  end
}
