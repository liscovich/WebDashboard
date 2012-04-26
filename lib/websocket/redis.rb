require 'em-hiredis'
require 'yajl'

module WebSocket
  class Redis

    DEFAULT_HOST     = 'localhost'
    DEFAULT_PORT     = 6379
    DEFAULT_DATABASE = 0
    DEFAULT_GC       = 60
    LOCK_TIMEOUT     = 120

    def self.create(options)
      new(options)
    end

    def initialize(options)
      @options = options
    end

    def init
      return if @redis

      host   = @options[:host]      || DEFAULT_HOST
      port   = @options[:port]      || DEFAULT_PORT
      db     = @options[:database]  || DEFAULT_DATABASE
      auth   = @options[:password]
      @ns    = @options[:namespace] || ''
      socket = @options[:socket]

      if socket
        @redis      = EventMachine::Hiredis::Client.connect(socket, nil)
      else
        @redis      = EventMachine::Hiredis::Client.connect(host, port)
      end
      if auth
        @redis.auth(auth)
      end
      @redis.select(db)
    end

    def onmessage &callback
      init
      @redis.on :message do |topic, message|
        p [:really_onmessage, message, topic]
        callback.call message if topic == @ns + "/messages"
      end
    end

    def subscribe
      init
      @redis.subscribe(@ns + "/messages")
    end

    def unsubscribe
      init
      @redis.unsubscribe(@ns + "/messages")
    end

    def publish(message)
      init
      json_message = Yajl::Encoder.encode(message)
      @redis.publish(@ns + "/messages", json_message)
    end
  end
end
