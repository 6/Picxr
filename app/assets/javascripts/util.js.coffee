# globally accessible utilities object
window.UT = {}

UT.is_dev = ->
  $("html").data("is-dev") is "yes"

UT.p = (args...) ->
  console.log args... if UT.is_dev()

UT.redirect = (path) ->
  top.location.href = "#{UT.top_href()}#{path}"
  
UT.is_framed = ->
  self is not top

UT.top_href = ->
  $("html").data("fb-cb-#{if UT.is_framed() then 'frame' else 'default'}")

UT.route_bb = (href, e) ->
  # remove preceding "/" if it exists
  href = href.substring(1) if href.substring(0 ,1) is "/"
  UT.p "route_bb -> #{href}"
  PicMixr.router.navigate(href, true)
  e.preventDefault() if e?

UT.loading = (text) ->
  $("#canvas-wrap").html JST['loading']({text: text})
