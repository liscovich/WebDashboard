window.gst = null

$ ->
  $('.slider').slider()

  window.gst = new game_state_tracker(2000)

  setTimeout =>
    window.gst.fetch_state()
  , 5000

class game_state_tracker
  constructor: (@poll_freq)->
    @last_id = 0
    @run = true

  fetch_state: =>
    return unless @run
    data = {id: @last_id}
    data.game_id = @game_id if @game_id
      
    $.getJSON "/log", data, (o)=>
      for log in o
        @process(log)
      
      if o.length>0
        @last_id = o[o.length-1]['id']
      
      setTimeout =>
        @fetch_state()
      , @poll_freq
  
  process_log: (log)->
    console.log log
    switch log['name']
      when 'game_started'
        alert "game started"
      when 'game_ended'
        alert "game ended!"