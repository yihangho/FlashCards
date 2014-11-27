# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(this).trigger("page:load")

$(document).on "page:load", ->
  pronunciationPlayers = {}

  rate = (id, score) ->
    $.ajax("/cards/rate/#{id}",
      data:
        rating: score
      complete: ->
        Turbolinks.visit(document.URL)
      type: "PATCH")

  $("#show-hint-btn").click ->
    if $(".hidden.card").length
      $(".hidden.card").eq(0).removeClass("hidden")

      $(this).addClass("disabled") unless $(".hidden.card").length

      $("html, body").animate(scrollTop: $(document).height(), "slow")
    false

  $("#thumbs-up-btn").click ->
    return if $(this).hasClass("disabled")
    $(this).addClass("disabled")
           .children("i")
           .removeClass("fa-thumbs-o-up").addClass("fa-spinner fa-spin")
    rate($(this).data("card-id"), 1)
    false

  $("#thumbs-down-btn").click ->
    return if $(this).hasClass("disabled")
    $(this).addClass("disabled")
           .children("i")
           .removeClass("fa-thumbs-o-down").addClass("fa-spinner fa-spin")
    rate($(this).data("card-id"), -1)
    false

  $("[data-pronounce]").click ->
    word = $(this).data("pronounce")
    $(this).children("i").removeClass("fa-volume-up").addClass("fa-spinner fa-spin disabled")
    TTS word, =>
      $(this).children("i").addClass("fa-volume-up").removeClass("fa-spinner fa-spin disabled")
    , =>
      $(this).children("i").addClass("fa-volume-up text-danger").removeClass("fa-spinner fa-spin disabled")
    false
