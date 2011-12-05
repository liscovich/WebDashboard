window.gst = null

$ ->
  game_id = parseInt window.configs.gameid

  window.gst = new game_state_tracker_dashboard(game_id, 500)

  setTimeout =>
    window.gst.fetch_state()
  , 2000

class game_state_tracker_dashboard extends game_state_tracker
  process: (o)->
    $('#debug').append("<div>#{JSON.stringify(o)}</div>")
    switch o.event_type
      when 'gamestate_update'
        $('#game_state').text o.state_name
      when 'player_choice'
        return unless o.user_id? and o.choice?
        $('#dashboard_tbody').append("<tr><td></td><td>#{o.user_id}</td><td>#{o.choice}</td><td>#{o.score}</td><td>#{o.total_score+o.score}</td></tr>")
      when 'new_round'
        $('#dashboard_tbody').append "<tr><td>Round #{o.round_id}</td></tr>"