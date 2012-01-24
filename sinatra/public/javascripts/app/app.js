(function() {
  var game_state_tracker;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.display_error = function(msg) {
    if (msg == null) msg = null;
    if (msg) $('#error').text(msg);
    return $('#error').slideDown(function() {
      return setTimeout(function() {
        return $('#error').slideUp();
      }, 2000);
    });
  };

  window.configs = {};

  $(function() {
    $('[id^=hidden_]').each(function() {
      var key, val, __, _ref;
      _ref = $(this).attr('id').split('_'), __ = _ref[0], key = _ref[1];
      val = $(this).val();
      return window.configs[key] = val;
    });
    if (!$('#error').is(":empty")) window.display_error();
    $('.hide_on_click').click(function() {
      if ($(this).val === $(this).attr('placeholder')) $(this).val('');
      return $(this).focus();
    });
    return $('.hide_on_click').blur(function() {
      var el, sub;
      el = $(this).get(0);
      if ($(this).val() === '') {
        sub = $(this).attr('placeholder');
        if (el.tagName === 'INPUT') {
          return $(this).val(sub);
        } else if (el.tagName === 'TEXTAREA') {
          return $(this).val(sub);
        }
      }
    });
  });

  game_state_tracker = (function() {

    function game_state_tracker(game_id, poll_freq) {
      this.game_id = game_id;
      this.poll_freq = poll_freq;
      this.fetch_state = __bind(this.fetch_state, this);
      this.last_id = 0;
      this.run = true;
    }

    game_state_tracker.prototype.fetch_state = function() {
      var data;
      var _this = this;
      if (!this.run) return;
      data = {
        id: this.last_id
      };
      if (this.game_id) data.game_id = this.game_id;
      return $.getJSON("/game/events", data, function(o) {
        var log, _i, _len;
        for (_i = 0, _len = o.length; _i < _len; _i++) {
          log = o[_i];
          _this.process(log);
        }
        if (o.length > 0) _this.last_id = o[o.length - 1]['id'];
        return setTimeout(function() {
          return _this.fetch_state();
        }, _this.poll_freq);
      });
    };

    game_state_tracker.prototype.process = function(log) {
      return console.log(log);
    };

    return game_state_tracker;

  })();

  window.game_state_tracker = game_state_tracker;

}).call(this);
