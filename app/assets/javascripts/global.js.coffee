String.prototype.capitalize = -> this.charAt(0).toUpperCase() + this.slice(1);

$(document).on "page:fetch", ->
  $(".spinner-container").removeClass("hidden")
  $(".spinner-container").spin()

$(document).on "page:receive", ->
  $(".spinner-container").addClass("hidden")
  $(".spinner-container").spin(false)
