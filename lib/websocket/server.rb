module WebSocket
  class Server
    def incoming(message, callback)
      callback.call message
    end
  end
end
