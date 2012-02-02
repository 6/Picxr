# globally accessible utilities object
window.UT =
  first_page: yes
  debug: if $("html").data("debug") is "yes" then yes else no

UT.p = (args...) ->
  console.log args... if UT.debug and console?

UT.redirect = (path) ->
  path = path.substring(1) if path.substring(0 ,1) is "/"
  top.location.href = "#{UT.top_href()}#{path}"
  
UT.is_framed = ->
  self isnt top

UT.framed_cb_href = ->
  $("html").data("fb-cb-frame")

UT.default_cb_href = ->
  $("html").data("fb-cb-default")

UT.top_href = ->
  if UT.is_framed() then UT.framed_cb_href() else UT.default_cb_href()

UT.route_bb = (href, e) ->
  UT.first_page = no
  # remove preceding "/" if it exists
  href = href.substring(1) if href.substring(0 ,1) is "/"
  UT.p "route_bb -> #{href}"
  PicMixr.router.navigate(href, true)
  e.preventDefault() if e?

UT.route_default = (e) ->
  UT.route_bb '/', e
  
UT.fit_dimensions = (width, height, max_width, max_height) ->
  if width <= max_width or height <= max_height
    #TODO should this stretch to fill?
    {width: width, height: height}
  ratio = Math.min max_width / width, max_height / height
  width = Math.min max_width, Math.ceil(width * ratio)
  height = Math.min max_height, Math.ceil(height * ratio)
  {width: width, height: height}
  
UT.merge_layers = (base_ctx, layer_canvas, layer_width, layer_height) ->
  base_ctx.drawImage(layer_canvas, 0, 0, layer_width, layer_height)

UT.get_pixel = (ctx, x, y) ->
  data = ctx.getImageData(x, y, 1, 1).data
  {r: data[0], g: data[1], b: data[2], a: data[3]}

UT.loading = (text) ->
  $("#main-wrap").html JST['tween/loading']({text: text})

UT.message = (text) ->
  $("#main-wrap").html JST['tween/message']({text: text})
  
UT.has_webgl = ->
  try
    canvas = document.createElement('canvas')
    !!(window.WebGLRenderingContext && (canvas.getContext('webgl') || canvas.getContext('experimental-webgl')))
  catch e
    no

UT.onbeforeunload = ->
  "Are you sure you want to leave? All your changes will be lost."
