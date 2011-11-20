window.configs = {}

$ ->
  $('[id^=hidden_]').each ->
    [__, key] = $(@).attr('id').split('_') 
    val = $(@).val()
    window.configs[key] = val
  unless $('#error').is(":empty")
    $('#error').slideDown ->
      setTimeout ->
        $('#error').slideUp()
      , 2000
