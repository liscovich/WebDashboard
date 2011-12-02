window.get_parameter = (name)->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.href)
  if(results == null)
    return ""
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "))

$ ->
  gt = new game_tracker(window.configs.gameid, 2000)

  setTimeout ->
    gt.fetch_state()
  , 5000

  $('#submit_mturk').click ->
    $(@).fadeOut()
    window.display_error("You successfully submitted this assignment!")

class game_tracker
  constructor: (@game_id, @poll_freq)->
    @run = true

  fetch_state: =>
    return unless @run
    $.getJSON "/game/#{@game_id}/state", (o)=>
      console.log(o)
      @process(o)
      
      setTimeout =>
        @fetch_state()
      , @poll_freq
  
  process: (obj)=>
    [state, state_name] = obj
    $('#game_state').text state_name
    switch state
      when 'game_ended'
        @run = false
        $('#submit_row').slideDown()