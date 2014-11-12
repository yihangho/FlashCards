# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(this).trigger("page:load")

  if annyang?
    commands =
      "correct": ->
        $("#thumbs-up-btn").click()
      "wrong": ->
        $("#thumbs-down-btn").click()
      "more": ->
        $("#show-hint-btn").click()
      "next": ->
        Turbolinks.visit(document.URL)
      "read the word": ->
        $("[data-pronounce]").click() if $("[data-pronounce]").length == 1
      "search *query": (query) ->
        Turbolinks.visit("/cards/search?query=#{query}")

    annyang.addCommands(commands)
    annyang.start()

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

    if "speechSynthesis" of window
      utterance = new SpeechSynthesisUtterance(word)

      utterance.addEventListener "end", =>
        $(this).children("i").addClass("fa-volume-up").removeClass("fa-spinner fa-spin disabled")

      speechSynthesis.speak(utterance)
    else
      if pronunciationPlayers.hasOwnProperty(word)
        pronunciationPlayers[word].load()
        pronunciationPlayers[word].play()
      else
        $.ajax "/pronounce/#{word}",
          type: "GET"
          success: (path) =>
            pronunciationPlayers[word] = new Audio(path)
            pronunciationPlayers[word].play()

            pronunciationPlayers[word].addEventListener "ended", =>
              $(this).children("i").addClass("fa-volume-up").removeClass("fa-spinner fa-spin disabled")

            pronunciationPlayers[word].addEventListener "error", =>
              $(this).children("i").addClass("fa-volume-up text-danger").removeClass("fa-spinner fa-spin disabled")
              delete pronunciationPlayers[word]
          error: =>
            $(this).children("i").addClass("fa-volume-up text-danger").removeClass("fa-spinner fa-spin disabled")
    false
