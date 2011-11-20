(function() {
  var game_state_tracker;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.gst = null;
  $(function() {
    window.gst = new game_state_tracker(2000);
    return setTimeout(__bind(function() {
      return window.gst.fetch_state();
    }, this), 3000);
  });
  game_state_tracker = (function() {
    function game_state_tracker(poll_freq) {
      this.poll_freq = poll_freq;
      this.fetch_state = __bind(this.fetch_state, this);
      this.last_id = 0;
      this.run = true;
    }
    game_state_tracker.prototype.fetch_state = function() {
      var data;
      if (!this.run) {
        return;
      }
      data = {
        id: this.last_id
      };
      if (this.game_id) {
        data.game_id = this.game_id;
      }
      return $.getJSON("/log", data, __bind(function(o) {
        var log, _i, _len;
        for (_i = 0, _len = o.length; _i < _len; _i++) {
          log = o[_i];
          this.process(log);
        }
        if (o.length > 0) {
          this.last_id = o[o.length - 1]['id'];
        }
        return setTimeout(__bind(function() {
          return this.fetch_state();
        }, this), this.poll_freq);
      }, this));
    };
    game_state_tracker.prototype.process_log = function(log) {
      console.log(log);
      switch (log['name']) {
        case 'game_started':
          return alert("game started");
        case 'game_ended':
          return alert("game ended!");
      }
    };
    return game_state_tracker;
  })();
}).call(this);
