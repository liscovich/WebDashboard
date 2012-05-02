class Photon::Client
  OPERATION_CODES = {
      join:           255,
      leave:          254,
      raise_event:    253,
      set_properties: 252,
      get_properties: 251,
      ping:           "Ping"
  }

  EVENT_CODES = {
      join:               255,
      leave:              254,
      properties_changed: 253,
      connecting:         'connecting',
      connect:            'connect',
      connectFailed:      'connectFailed',
      disconnect:         'disconnect',
      error:              'error',
      timeout:            'timeout'
  }

  PARAMETER_CODES = {
      game_id:          255,
      actor_nr:         254,
      target_actor_nr:  253,
      actors:           252,
      properties:       251,
      broadcast:        250,
      actor_properties: 249,
      game_properties:  248,
      cache:            247,
      receiver_group:   246,
      data:             245,
      code:             244,
      flush:            243
  }

  def initialize(host = nil, options = {})
    @connected = false
    @joined    = false
    @room_name = ""
    @closing   = false
    self.options.merge! options
    @host = host || 'localhost'
  end

  def options
    @options ||= {port: 9090}
  end

  def _events
    @_events ||= {}
  end

  def _socket
    @_socket ||= nil
  end

  def _socket=(socket)
    @_socket = socket
  end

  def closing?
    @closing
  end

  def my_actor
    @my_actor ||= {photon_id: nil, properties: {}}
  end

  def my_actor=(actor)
    @my_actor = actor
  end

  def game
    @game ||= {properties: {}}
  end

  def game=(game)
    @game = game
  end

  def actors
    @actors ||= {}
  end

  def connected?
    @connected
  end

  def connecting?
    @connecting
  end

  def disconnect
    @connected = false
  end

  def joined?
    @joined
  end


  def connect(host, options)
    self.options.merge! options

    if !closing? and !connected? and !connecting?

      @host = host if host

      @_socket = Photon::Socket.new(@host, self.options)

      _socket.connect

      _socket.on 'connecting' do
        _on_connecting
      end

      _socket.on 'connect' do
        _on_connect
      end

      _socket.on 'error' do
        _on_error
      end

      _socket.on 'message' do |data|
        _on_message_received(data)
      end

      _socket.on 'disconnect' do
        _on_disconnect
      end
    else
      raise "PhotonPeer[connect] - The socket is already connected!" if connected?
      raise "PhotonPeer[connect] - The socket is still connecting!" if connecting?
      raise "PhotonPeer[connect] - The socket is still closing!" if closing?
    end
  end

  def disconnect
    if !closing? and !connected? and !connecting?
      @closing = true
      _socket.close
    end
  end


  def join(game_id, game_properties = nil, actor_properties = nil, broadcast = nil)
    if game_id and connected? and !joined?
      data_for_send = []
      data_for_send << PARAMETER_CODES[:game_id]
      data_for_send << game_id

      if game_properties
        data_for_send << PARAMETER_CODES[:game_properties]
        data_for_send << game_properties
      end

      if actor_properties
        data_for_send << PARAMETER_CODES[:actor_properties]
        data_for_send << actor_properties
      end

      data_for_send << PARAMETER_CODES[:broadcast]
      data_for_send << (broadcast || false)

      _send_operation(OPERATION_CODES[:join], data_for_send)

    else
      if !game_id
        raise "PhotonPeer[join] - trying to join with undefined gameId"
      else
        if joined?
          raise "PhotonPeer[join] - you have already joined!"
        else
          raise "PhotonPeer[join] - Not connected!"
        end
      end
    end
  end

  def _send(data)
    if connected? and !closing?
      _socket.msend(data)
    else
      raise "PhotonPeer[_send] - Operation #{data[:req]} - failed!"
    end
  end

  def _send_operation(operation_code, data = nil)
    json = {req: operation_code}

    if data.is_a? Array
      json[:vals] = data
    elsif data.nil?
      json[:vals] = []
    else
      raise "PhotonPeer[_sendOperation] - Trying to send non array data"
    end

    _send(json)
  end

  def _on_message_received(message)
    puts "photon client _on_message_received #{message}"
    if message.is_a? Hash
      if !message['err'] or message['err'] == 0
        type            = ''
        message['vals'] = message['vals'] || []
        message['vals'] = _parse_message_values_array_to_json(message['vals']) if message['vals'].length > 0
        message_actor_id = message['vals']['254'] ? message['vals']['254'] : my_actor[:photon_id] ? my_actor[:photon_id] : -1
        if message['res']
          _parse_response(message['res'], message, message_actor_id)
        else
          if message['evt']
            _parse_event(message['evt'], message, message_actor_id)
          else
            raise "PhotonPeer[_on_message_received] - Received undefined message type"
          end
        end
      else
        raise "PhotonPeer[_on_message_received] - Response error\n #{message.inspect}"
      end
    end
  end

  def _parse_message_values_array_to_json(vals)
    json = {}
    if vals.is_a? Array
      if vals.length % 2 == 0
        vals.each_slice(2) do |key, value|
          json[key.to_s] = value
        end
      else
        raise "PhotonPeer[_parse_message_values_to_json] - Received invalid values array"
      end
    end
    json
  end

  def _on_connecting
    @connecting = true
    dispatch_event('connecting')
  end

  def _on_connect
    @connecting = false
    @connected  = true
    dispatch_event('connect')
  end

  def _on_connect_failed(evt)
    @connecting = false
    @connected  = false
    dispatch_event('connect_failed')
  end

  def _on_disconnect
    connected   = @connected
    @closing    = false
    @connected  = false
    @connecting = false
    dispatch_event('disconnect') if connected
  end

  def _on_timeout
    dispatch_event('timeout')
  end

  def _on_error
    @connecting = false
    @connected  = false
    @closing    = false
    dispatch_event('error')
  end

  def _add_listener(name, &block)
    _events[name] = [] unless _events.include? name
    _events[name] << block if block_given?
  end

  def add_event_listener(name, &block)
    _add_listener("evt_#{name}", &block)
  end

  def add_custom_event_listener(name, &block)
    add_event_listener("cus_#{name}", &block)
  end

  def add_response_listener(name, &block)
    _add_listener("rsp_#{name}", &block)
  end

  def add_custom_response_listener(name, &block)
    _add_response_listener("cus_#{name}", &block)
  end

  def _dispatch(name, args)
    puts "dispatch #{name} : #{args.inspect}"
    if _events.include? name
      events = _events[name]
      type   = name.slice(0, 2)
      events.each do |event|
        event.call(args)
      end
    end
  end

  def dispatch_event(name, args={})
    _dispatch("evt_#{name}", args)
  end

  def dispatch_custom_event(name, args={})
    dispatch_event("cus_#{name}", args)
  end

  def dispatch_response(name, args={})
    _dispatch("rsp_#{name}", args)
  end

  def dispatch_custom_response(name, args={})
    dispatch_response("cus_#{name}", args)
  end

  def _remove_listener(name)
    _events[name].reject { |i| i % 2 == 0 } if _events.include? name
  end

  def remove_event_listener(name)
    _remove_listener("evt_#{name}")
  end

  def remove_custom_event_listener(name)
    remove_event_listener("cus_#{name}")
  end

  def remove_response_listener(name)
    _remove_listener("rsp_#{name}")
  end

  def remove_custom_response_listener(name)
    remove_response_listener("cus_#{name}")
  end

  def leave
    if joined?
      _send_operation(OPERATION_CODES[:leave])
    else
      raise "PhotonPeer[leave] - Not joined!"
    end
  end

  def ping
    _send_operation(OPERATION_CODES[:ping], [])
  end

  def raise_event(event_code, data = nil)
    if joined?
      if data
        _send_operation(OPERATION_CODES[:raise_event], [PARAMETER_CODES[:code], event_code, PARAMETER_CODES[:data], data])
      else
        raise "PhotonPeer[raise_event] - Event #{event_code} - data not passed"
      end
    else
      raise "PhotonPeer[raise_event] - Not joined!"
    end
  end

  def set_actor_properties(data, broadcast, actor_number)
    if joined?
      actor_number ||= 0
      _send_operation(OPERATION_CODES[:setProperties], [PARAMETER_CODES[:broadcast], !!broadcast, PARAMETER_CODES[:properties], data, PARAMETER_CODES[:actor_nr], actor_number])
    else
      raise "PhotonPeer[set_actor_properties] - Not Joined!"
    end
  end

  def get_actor_properties(actor_property_keys, actor_numbers)
    if joined?
      data_for_send = []
      data_for_send << PARAMETER_CODES[:actor_properties]
      data_for_send << actor_property_keys if actor_property_keys.is_a? Array and actor_property_keys.length > 0
      data_for_send << nil if data_for_send.length != 2
      data_for_send << PARAMETER_CODES[:actors]
      data_for_send << actor_numbers if actor_numbers.is_a? Array and actor_numbers.length > 0
      data_for_send << nil if data_for_send.length != 4
      data_for_send << PARAMETER_CODES[:properties]
      data_for_send << 2

      _send_operation(OPERATION_CODES[:get_properties, data_for_send])
    else
      raise 'PhotonPeer[get_properties] - Not joined!'
    end
  end

  def set_game_properties(data, broadcast)
    if joined?
      actor_number ||= 0
      _send_operation(OPERATION_CODES[:setProperties], [PARAMETER_CODES[:broadcast], !!broadcast, PARAMETER_CODES[:properties], data])
    else
      raise "PhotonPeer[set_actor_properties] - Not Joined!"
    end
  end

  def get_game_properties(game_property_keys)
    if joined?
      data_for_send = []
      data_for_send << PARAMETER_CODES[:game_properties]
      data_for_send << game_property_keys if game_property_keys.is_a? Array and game_property_keys.length > 0
      data_for_send << nil if data_for_send.length != 2


      _send_operation(OPERATION_CODES[:get_properties], data_for_send)
    else
      raise 'PhotonPeer[get_game_properties] - Not joined!'
    end
  end

  def _add_actor(actor_nr)
    actors[actor_nr] = {photon_id: actor_nr}
  end

  def _remove_actor(actor_nr)
    actors.delete actor_nr
  end


  def _parse_event(type, event, actor_nr)
    case type
      when EVENT_CODES[:join] then
        _on_event_join(event, actor_nr)
      when EVENT_CODES[:leave] then
        _on_event_leave(actor_nr)
      when EVENT_CODES[:set_properties] then
        _on_event_set_properties(event, actor_nr)
      else
        dispatch_custom_event(type, vals: event['vals'], actor_nr: actor_nr)
    end
  end

  def _on_event_join(event, actor_nr)
    if actor_nr != my_actor[:photon_id]
      _add_actor(actor_nr)
      dispatch_event('join', new_actors: [actor_nr])
    else
      event_actors  = event['vals'][PARAMETER_CODES[:actors]]
      joined_actors = []
      event_actors.each do |actor|
        _add_actor(actor)
        joined_actors << actor
      end
      dispatch_event('join', new_actors: [joined_actors])
    end
  end

  def _on_event_leave(actor_nr)
    _remove_actor(actor_nr)
    dispatch_event('leave', actor_nr: actor_nr)
  end

  def _on_event_set_properties(event, actor_nr)
    dispatch_event('setProperties', {vals: event['vals'], actor_nr: actor_nr})
  end

  def _parse_response(type, response, actor_nr)
    case type
      when OPERATION_CODES[:ping] then
        ping
      when OPERATION_CODES[:join] then
        _on_response_join(actor_nr)
      when OPERATION_CODES[:leave] then
        _on_response_leave(actor_nr)
      when OPERATION_CODES[:raise_event] then
        return
      when OPERATION_CODES[:get_properties] then
        _on_response_get_properties(response)
      when OPERATION_CODES[:set_properties] then
        _on_response_set_properties(response, actor_nr)
      else
        dispatch_custom_response(type, vals: response['vals'], actor_nr: actor_nr)
    end
  end

  def _on_response_get_properties(response)
    if (actor_properties = response['vals'][PARAMETER_CODES[:actor_properties]])
      actor_properties.each do |actor|
        actors[actor][:properties] = actor
      end
    end

    if (game_properties = response['vals'][PARAMETER_CODES[:game_properties]])
      game[:properties] = game_properties
    end

    dispatch_response(OPERATION_CODES[:get_properties], vals: response['vals'])
  end

  def _on_response_join(actor_nr)
    @joined = true
    my_actor = _add_actor(actor_nr) if my_actor.is_a? Hash
    dispatch_response(OPERATION_CODES[:join], actor_nr: actor_nr)
  end

  def _on_response_leave(actor_nr)
    @joined = false
    _remove_actor(my_actor[:photon_id])
    @room_name = ''
    @game      = {properties: {}}
    dispatch_response(OPERATION_CODES[:leave], actor_nr: actor_nr)
  end

  def _on_response_set_properties(response, actor_nr)
    dispatch_response(OPERATION_CODES[:set_properties], vals: response['vals'], actor_nr: actor_nr)
  end
end
