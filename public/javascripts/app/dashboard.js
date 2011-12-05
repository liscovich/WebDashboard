(function() {
  var game_state_tracker_dashboard;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  window.gst = null;

  $(function() {
    var game_id;
    var _this = this;
    game_id = parseInt(window.configs.gameid);
    window.gst = new game_state_tracker_dashboard(game_id, 500);
    return setTimeout(function() {
      return window.gst.fetch_state();
    }, 2000);
  });

  game_state_tracker_dashboard = (function() {

    __extends(game_state_tracker_dashboard, game_state_tracker);

    function game_state_tracker_dashboard() {
      game_state_tracker_dashboard.__super__.constructor.apply(this, arguments);
    }

    game_state_tracker_dashboard.prototype.process = function(o) {
      $('#debug').append("<div>" + (JSON.stringify(o)) + "</div>");
      switch (o.event_type) {
        case 'gamestate_update':
          return $('#game_state').text(o.state_name);
        case 'player_choice':
          if (!((o.user_id != null) && (o.choice != null))) return;
          return $('#dashboard_tbody').append("<tr><td></td><td>" + o.user_id + "</td><td>" + o.choice + "</td><td>" + o.score + "</td><td>" + (o.total_score + o.score) + "</td></tr>");
        case 'new_round':
          return $('#dashboard_tbody').append("<tr><td>Round " + o.round_id + "</td></tr>");
      }
    };

    return game_state_tracker_dashboard;

  })();

}).call(this);
