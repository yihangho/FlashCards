# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  get_a_tag = (id, text) ->
    "<a href='#' class='remove-card' data-id='#{id}'>#{text}</a> "

  get_hidden_tag = (id) ->
    "<input type='hidden' name='card-#{id}' id='card-#{id}' value='1'>"

  $("div.selected-cards").on('click', '.remove-card', ->
    $(this).remove()
    false
  )

  $(".edit_deck").submit ->
    $('.remove-card').each (_, e) ->
      $(".edit_deck").append(get_hidden_tag($(e).data("id")))

  $("#card_id").change (x) ->
    id = $(this).val()
    word = $("option[value=#{id}]").text()
    $("div.selected-cards").append(get_a_tag(id, word))
