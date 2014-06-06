# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("#show-hint-btn").click ->
    $($(".hidden.card")[0]).removeClass("hidden") if $(".hidden.card").length
    $(this).hide() unless $(".card.hidden").length
    false
