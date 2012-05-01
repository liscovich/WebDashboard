$ ->
  players = {}

  process = (o)->
    console.dir o
    $('#debug').append("<div>#{JSON.stringify(o)}</div>")
    switch o.event_type
      when 'gamestate_update'
        $('#game_state').text o.state_name
      when 'player_choice'
        return if o.round_id<=0
        return unless (o.user_id? or o.ai_id?) and o.choice?
        player_id = if o.is_ai then o.ai_id else o.user_id

        str_id = "#{o.round_id}.#{player_id}.#{o.choice}"
        return if players[str_id]
        players[str_id] = true

        $('#dashboard_tbody').append("<tr><td></td><td>#{player_id}</td><td>#{o.choice}</td><td>#{o.score}</td><td>#{o.total_score+o.score}</td></tr>")
      when 'new_round'
        $('#dashboard_tbody').append "<tr><td>Round #{o.round_id}</td></tr>"

  client = new Faye.Client('http://localhost:9292/socket')

  client.subscribe '/messages', (message) ->
    process(message)

