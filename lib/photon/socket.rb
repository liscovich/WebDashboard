require 'json'

class Photon::Socket
  def initialize(host = nil, options = {})
    @host = host if host
    self.options.merge! options
    @connected = false
    @connecting = false
    @transport = get_transport
  end

  def host
    @host ||= 'localhost'
  end

  def connected?
    @connected
  end

  def connecting?
    @connecting
  end

  def get_transport
    Photon::WebSocket.new self, @options
  end

  def _events
    @_events ||= {}
  end

  def options
    @options ||= {
      secure:false,
      port: 80,
      resource: '',
      reconnect: true,
      reconnection_delay: 500,
      max_reconnection_attempts: 10
    }
  end

  def connect
    unless connected?

      if connecting?
        disconnect(true)
      end
      @connecting = true
      emit('connecting')
      @transport.connect
    end
  end

  def msend(data)
    unless @transport.connected?
      return _queue(data)
    end
    @transport.msend(data)
  end

  def disconnect(reconnect)
    @options[:reconnect] = false unless reconnect
    @transport.disconnect
  end

  def on(name, &block)
    _events[name] = [] unless _events.include? name
    _events[name] << block
  end

  def emit(name, args = {})
    if _events.include? name
      _events[name].each do |event|
        event.call(args || [])
      end
    end
  end

  # TODO remove by function eql
  def remove_event(name)
    if _events.include? name
      _events.delete(name)
    end
  end

  def _queue(message)
    _queue_stack << message
  end

  def _queue_stack
    @_queue_stack ||= []
  end

  def _do_queue
    return unless _queue_stack.length > 0
    @transport.msend(_queue_stack)
    @_queue_stack = []
  end

  def _on_connect
    @connected = true
    @connecting = false
    emit('connect')
  end

  def _on_message(data)
    emit('message', data)
  end

  # TODO reconnect
  def _on_disconnect
    connected = @connected
    @connected = false
    @connecting = false
    @_queue_stack = []
    emit('disconnect') if connected
  end

  alias :fire :emit
  alias :add_listener :on
  alias :add_event :on
  alias :add_event_listener :on
  alias :remove_listener :remove_event
  alias :remove_event_listener :remove_event
end
