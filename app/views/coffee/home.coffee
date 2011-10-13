class Equation extends Spine.Model
  @configure "Equation", "name"

class EquationApp extends Spine.Controller
  events:
    "click #submit_equation":   "sayHi"
  constructor: ->
    super
  
  sayHi: (e)->
    alert "HELLo!"
    e.preventDefault()

$ ->
  alert "started"
  new EquationApp el: $('#equations')