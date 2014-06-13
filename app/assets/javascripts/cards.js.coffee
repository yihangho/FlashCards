# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(this).trigger("page:load")

$(document).on "page:load", ->
  rate = (id, score) ->
    $.ajax("/cards/rate/#{id}",
      data:
        rating: score
      complete: ->
        Turbolinks.visit(document.URL)
      type: "PATCH")

  $("#show-hint-btn").click ->
    if $(".card.hidden").length
      $($(".hidden.card")[0]).removeClass("hidden")
      $(this).addClass("hidden") unless $(".hidden.card").length
    false

  $("#thumbs-up-btn").click ->
    rate($(this).data("card-id"), 1)
    false

  $("#thumbs-down-btn").click ->
    rate($(this).data("card-id"), -1)
    false
