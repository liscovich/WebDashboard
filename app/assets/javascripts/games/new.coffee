$ ->
  $('.slider').slider()
  $('.game-template').click ->
    $.get $(@).attr('href'), (o)->
      for k, v of o
        $("#game_#{k}").val v
    false


