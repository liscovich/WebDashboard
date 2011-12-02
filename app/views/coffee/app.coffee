
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


