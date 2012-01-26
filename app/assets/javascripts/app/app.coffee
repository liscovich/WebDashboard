window.display_error = (msg=null)->
  $('#error').text(msg) if(msg)
  
  $('#error').slideDown ->
    setTimeout ->
      $('#error').slideUp()
    , 2000

window.configs = {}

$ ->
  $('[id^=hidden_]').each ->
    [__, key] = $(@).attr('id').split('_') 
    val = $(@).val()
    window.configs[key] = val
  unless $('#error').is(":empty")
    window.display_error()
  
  $('.hide_on_click').click ->
    if $(@).val is $(@).attr('placeholder')
      $(@).val ''
    $(@).focus()

  $('.hide_on_click').blur ->
    el = $(@).get 0
    if $(@).val() is ''
      sub = $(@).attr('placeholder')
      if el.tagName is 'INPUT'
        $(@).val sub
      else if el.tagName is 'TEXTAREA'
        $(@).val sub
      

class game_state_tracker
  constructor: (@game_id, @poll_freq)->
    @last_id = 0
    @run = true

  fetch_state: =>
    return unless @run
    data = {id: @last_id}
    data.game_id = @game_id if @game_id
      
    $.getJSON "/game/events", data, (o)=>
      for log in o
        @process(log)
      
      if o.length>0
        @last_id = o[o.length-1]['id']
      
      setTimeout =>
        @fetch_state()
      , @poll_freq
  
  process: (log)->
    console.log log

window.game_state_tracker = game_state_tracker