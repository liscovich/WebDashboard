(function() {
  var game_tracker;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
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
  $(function() {
    var gt;
    gt = new game_tracker(window.configs.gameid, 2000);
    setTimeout(function() {
      return gt.fetch_state();
    }, 5000);
    return $('#submit_mturk').click(function() {
      $(this).fadeOut();
      return window.display_error("You successfully submitted this assignment!");
    });
  });
  game_tracker = (function() {
    function game_tracker(game_id, poll_freq) {
      this.game_id = game_id;
      this.poll_freq = poll_freq;
      this.process = __bind(this.process, this);
      this.fetch_state = __bind(this.fetch_state, this);
      this.run = true;
    }
    game_tracker.prototype.fetch_state = function() {
      if (!this.run) {
        return;
      }
      return $.getJSON("/game/" + this.game_id + "/state", __bind(function(o) {
        console.log(o);
        this.process(o);
        return setTimeout(__bind(function() {
          return this.fetch_state();
        }, this), this.poll_freq);
      }, this));
    };
    game_tracker.prototype.process = function(obj) {
      var state, state_name;
      state = obj[0], state_name = obj[1];
      $('#game_state').text(state_name);
      switch (state) {
        case 'game_ended':
          this.run = false;
          return $('#submit_row').slideDown();
      }
    };
    return game_tracker;
  })();
}).call(this);
