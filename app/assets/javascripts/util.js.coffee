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

UT.bb_navigate = (href, e) ->
  # remove preceding "/" if it exists
  href = href.substring(1) if href.substring(0 ,1) is "/"
  PicMixr.router.navigate(href, true)
  e.preventDefault() if e?
