(function() {
  window.display_error = function(msg) {
    if (msg == null) {
      msg = null;
    }
    if (msg) {
      $('#error').text(msg);
    }
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
    if (!$('#error').is(":empty")) {
      return window.display_error();
    }
  });
}).call(this);
