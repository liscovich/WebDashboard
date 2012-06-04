require 'faye/websocket'
require 'json'

class Photon::WebSocket
  def initialize(base, options)
    @base = base
    @connected = false
    @options = options
    @frame = '~m~'
  end

  def connected?
    @connected
  end

  def connect
    @socket = Faye::WebSocket::Client.new(_prepare_url)

    @socket.onopen = lambda do |event|
    end

    @socket.onmessage = lambda do |event|
      _on_data(event.data)
    end

    @socket.onclose = lambda do |event|
      _on_close
    end

    @socket.onerror = lambda do |event|
      _on_error
    end
  end

  def msend(data)
    @socket.send(_encode(data)) if @socket
  end

  def disconnect
    @socket.close if @socket
  end

  def _on_close
    _on_disconnect
  end

  def _on_error
  end

  def _encode(messages)
    ret = ""
    messages = [messages] unless messages.is_a? Array
    messages.each do |message|
      message = "~j~#{message.to_json}"
      ret += @frame + message.length.to_s + @frame + message
    end
    ret
  end

  def _decode(data)
    messages = []
    null_index = data.index("\x00")
    data = data.replace(/[\0]/, "") unless null_index.nil?

    while data.length > 0
      return messages if data[0..2] != @frame

      data = data[3..-1]
      number = ""
      n = ""
      data.length.times do |i|
        n = data[i].to_i.to_s
        if data[i] == n
          number += n
        else
          data = data[(number.length+@frame.length)..-1]
          number = number.to_i
          break
        end
      end
      messages << data[0..number]
      data = data[number..-1]
    end
    messages
  end

  def _on_data(data)
    # puts "on data"
    messages = _decode(data)
    messages.each { |message| _on_message(message) } if messages.length > 0
  end

  def _on_message(message)
    if @session_id.nil?
      @session_id = message
      _on_connect
    else
      if message[0..2] == "~h~"
        _on_hearbeat(message[3..-1])
      else
        if message[0..2] == "~j~"
          @base._on_message(JSON.parse(message[3..-1]))
        else
          @base._on_message(message)
        end
      end
    end
  end

  def _on_hearbeat(heartbeat)
    msend("~h~#{heartbeat}")
  end

  def _on_connect
    @connected  = true
    @connecting = false
    @base._on_connect
  end

  def _on_disconnect
    @connected  = false
    @connecting = false
    @session_id = nil
    @base._on_disconnect
  end

  def _prepare_url
    (@base.options[:secure] ? "wss" : "ws") + "://" + @base.host + ":" + @base.options[:port].to_s + "/"
  end
end
