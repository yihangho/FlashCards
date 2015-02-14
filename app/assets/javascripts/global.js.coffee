String.prototype.capitalize = -> this.charAt(0).toUpperCase() + this.slice(1)

Array.prototype.bsearch = (needle) ->
  start = 0
  end = this.length - 1
  while start <= end
    mid = Math.floor((start + end) / 2)
    if needle == this[mid]
      return true
    else if needle < this[mid]
      end = mid - 1
    else
      start = mid + 1
  return false

monster.set("timezone-offset", moment().utcOffset(), 20 * 365);

$(document).on "page:fetch", ->
  $(".spinner-container").removeClass("hidden")
  $(".spinner-container").spin()

$(document).on "page:receive", ->
  $(".spinner-container").addClass("hidden")
  $(".spinner-container").spin(false)
