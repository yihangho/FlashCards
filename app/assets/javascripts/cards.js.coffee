# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(this).trigger("page:load")

$(document).on "page:load", ->
  pronunciationPlayer = null

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
    if pronunciationPlayer
      pronunciationPlayer.play()
      return false

    $(this).children("i").removeClass("fa-volume-up").addClass("fa-spinner fa-spin disabled")

    word = $(this).data("pronounce")
    $.ajax "/pronounce/#{word}",
      type: "GET"
      success: (path) =>
        pronunciationPlayer = new Audio(path)
        pronunciationPlayer.play()

        pronunciationPlayer.addEventListener "loadeddata", =>
          $(this).children("i").addClass("fa-volume-up").removeClass("fa-spinner fa-spin disabled")

        pronunciationPlayer.addEventListener "error", =>
          $(this).children("i").addClass("fa-volume-up text-danger").removeClass("fa-spinner fa-spin disabled")
          pronunciationPlayer = null
      error: =>
        $(this).children("i").addClass("fa-volume-up text-danger").removeClass("fa-spinner fa-spin disabled")

    false
