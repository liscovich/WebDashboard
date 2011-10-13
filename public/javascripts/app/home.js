(function() {
  var Equation, EquationApp;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Equation = (function() {
    __extends(Equation, Spine.Model);
    function Equation() {
      Equation.__super__.constructor.apply(this, arguments);
    }
    Equation.configure("Equation", "name");
    return Equation;
  })();
  EquationApp = (function() {
    __extends(EquationApp, Spine.Controller);
    EquationApp.prototype.events = {
      "click #submit_equation": "sayHi"
    };
    function EquationApp() {
      EquationApp.__super__.constructor.apply(this, arguments);
    }
    EquationApp.prototype.sayHi = function(e) {
      alert("HELLo!");
      return e.preventDefault();
    };
    return EquationApp;
  })();
  $(function() {
    alert("started");
    return new EquationApp({
      el: $('#equations')
    });
  });
}).call(this);
