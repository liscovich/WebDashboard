require File.expand_path('../redis.rb', __FILE__)
module WebSocket

  class Server

    def initialize(options)
      @redis = WebSocket::Redis.create(options)
    end

    def incoming(message, callback)
      @redis.publish(message) unless message['channel'].match /^\/meta/
      callback.call message
    end
  end
end
