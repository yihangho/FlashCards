# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("#show-hint-btn").click ->
    if $(".card.hidden").length
      $($(".hidden.card")[0]).removeClass("hidden")
      $(this).text("Get a new card") unless $(".hidden.card").length
    else
      window.location.reload()
    false
