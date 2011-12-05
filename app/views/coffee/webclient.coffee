window.get_parameter = (name)->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.href)
  if(results == null)
    return ""
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "))

window.gt = null
$ ->
  window.gt = new game_state_tracker_webclient(window.configs.gameid, 2000)

  setTimeout ->
    window.gt.fetch_state()
  , 5000

  $('#submit_mturk').click ->
    $(@).fadeOut()
    $('#game_state').html "You submitted your HIT! <div> Go play <a href='/trials'>more games</a></div>"
    #window.display_error("You successfully submitted this assignment!")
  
  $('#submit_non_mturk').click ->
    console.log {user_id:window.configs.userid,game_id:window.configs.gameid}
    $(@).fadeOut()
    $.get $(@).attr('href'), {user_id:window.configs.userid,game_id:window.configs.gameid}, (o)->
      $('#game_state').html "You submitted your exercise, please wait for someone to pay you!<div> Mean while, go play <a href='/trials'>more Games</a></div>"
    false


class game_state_tracker_webclient extends game_state_tracker
  process: (obj)=>
    return if obj.event_type isnt 'gamestate_update'
    $('#game_state').text obj.state_name
    switch obj.state
      when 'game_ended'
        @run = false
        $('#submit_row').slideDown()
        $.get "/gameuser/get_earnings", {user_id: window.configs.userid, game_id: window.configs.gameid}, (o)->
          [status,data] = o
          if(status)
            $('#earnings').text data
            $('#earnings_').slideDown()