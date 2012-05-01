// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery_nested_form
//= require chosen.jquery.min
//= require game_state_tracker

//= require faye.min
//= require faye_client

window.configs = {};

$(function() {
  window.display_error = function(msg) {
    if (msg == null) msg = null;
    if (msg) $('#error').text(msg);
    return $('#error').slideDown(function() {
      return setTimeout(function() {
        return $('#error').slideUp();
      }, 2000);
    });
  };

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

  $('.toggle').click(function(e){
    e.preventDefault();
    $(this).next('.toggled_block').toggle();
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