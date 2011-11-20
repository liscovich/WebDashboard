(function() {
  window.configs = {};
  $(function() {
    $('[id^=hidden_]').each(function() {
      var key, val, __, _ref;
      _ref = $(this).attr('id').split('_'), __ = _ref[0], key = _ref[1];
      val = $(this).val();
      return window.configs[key] = val;
    });
    if (!$('#error').is(":empty")) {
      return $('#error').slideDown(function() {
        return setTimeout(function() {
          return $('#error').slideUp();
        }, 2000);
      });
    }
  });
}).call(this);
