
  $(function() {
    $('.slider').slider();
    return $('.game-template').click(function() {
      $.get($(this).attr('href'), function(o) {
        var k, v, _results;
        _results = [];
        for (k in o) {
          v = o[k];
          _results.push($("#auto_" + k).val(v));
        }
        return _results;
      });
      return false;
    });
  });
