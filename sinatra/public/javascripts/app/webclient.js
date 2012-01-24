(function() {
  var game_state_tracker_webclient;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  window.get_parameter = function(name) {
    var regex, regexS, results;
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    regexS = "[\\?&]" + name + "=([^&#]*)";
    regex = new RegExp(regexS);
    results = regex.exec(window.location.href);
    if (results === null) {
      return "";
    } else {
      return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
  };

  window.gt = null;

  $(function() {
    window.gt = new game_state_tracker_webclient(window.configs.gameid, 2000);
    setTimeout(function() {
      return window.gt.fetch_state();
    }, 5000);
    $('#submit_mturk').click(function() {
      $(this).fadeOut();
      return $('#game_state').html("You submitted your HIT! <div> Go play <a href='/trials'>more games</a></div>");
    });
    return $('#submit_non_mturk').click(function() {
      console.log({
        user_id: window.configs.userid,
        game_id: window.configs.gameid
      });
      $(this).fadeOut();
      $.get($(this).attr('href'), {
        user_id: window.configs.userid,
        game_id: window.configs.gameid
      }, function(o) {
        return $('#game_state').html("You submitted your exercise, please wait for someone to pay you!<div> Mean while, go play <a href='/trials'>more Games</a></div>");
      });
      return false;
    });
  });

  game_state_tracker_webclient = (function() {

    __extends(game_state_tracker_webclient, game_state_tracker);

    function game_state_tracker_webclient() {
      this.process = __bind(this.process, this);
      game_state_tracker_webclient.__super__.constructor.apply(this, arguments);
    }

    game_state_tracker_webclient.prototype.process = function(obj) {
      if (obj.event_type !== 'gamestate_update') return;
      $('#game_state').text(obj.state_name);
      switch (obj.state) {
        case 'game_ended':
          this.run = false;
          $('#submit_row').slideDown();
          return $.get("/gameuser/get_earnings", {
            user_id: window.configs.userid,
            game_id: window.configs.gameid
          }, function(o) {
            var data, status;
            status = o[0], data = o[1];
            if (status) {
              $('#earnings').text(data);
              return $('#earnings_').slideDown();
            }
          });
      }
    };

    return game_state_tracker_webclient;

  })();

}).call(this);
