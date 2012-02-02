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
