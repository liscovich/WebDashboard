class GameStateTracker
  constructor: (@game_id, @poll_freq)->
    @last_id = 0
    @run = true

  fetch_state: =>
    return unless @run
    data = {id: @last_id}
    data.game_id = @game_id if @game_id
      
    $.getJSON "/events", data, (o)=>
      for log in o
        @process(log)
      
      if o.length>0
        @last_id = o[o.length-1]['id']
      
      setTimeout =>
        @fetch_state()
      , @poll_freq
  
  process: (log)->
    console.log log

window.game_state_tracker = GameStateTracker