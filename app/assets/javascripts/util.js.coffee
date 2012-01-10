# globally accessible utilities object
window.UT = {}

UT.is_dev = ->
  $("html").data("is-dev") is "yes"

UT.p = (args...) ->
  console.log args... if UT.is_dev()

UT.redirect = (path) ->
  top.location.href = "#{UT.top_href()}#{path}"
  
UT.is_framed = ->
  self isnt top

UT.top_href = ->
  $("html").data("fb-cb-#{if UT.is_framed() then 'frame' else 'default'}")

UT.route_bb = (href, e) ->
  # remove preceding "/" if it exists
  href = href.substring(1) if href.substring(0 ,1) is "/"
  UT.p "route_bb -> #{href}"
  PicMixr.router.navigate(href, true)
  if UT.is_framed()
    # update Facebook URL
    UT.p "TODO: update FB URL to #{UT.top_href()}#{href} ? need to hijack history"
  e.preventDefault() if e?
  
UT.fit_dimensions = (width, height, max_width, max_height) ->
  if width <= max_width or height <= max_height
    #TODO should this stretch to fill?
    {width: width, height: height}
  ratio = Math.min max_width / width, max_height / height
  width = Math.min max_width, Math.ceil(width * ratio)
  height = Math.min max_height, Math.ceil(height * ratio)
  {width: width, height: height}

UT.poorman_image_resize = (image, receiving_ctx, new_width, new_height) ->
  temp_canvas = document.createElement("canvas")
  temp_canvas.width = image.width
  temp_canvas.height = image.height
  temp_ctx = temp_canvas.getContext("2d")
  temp_ctx.drawImage(image, 0, 0)
  receiving_ctx.drawImage(temp_canvas, 0, 0, new_width, new_height)
  
UT.merge_layers = (base_ctx, layer_canvas, layer_width, layer_height) ->
  base_ctx.drawImage(layer_canvas, 0, 0, layer_width, layer_height)

UT.loading = (text) ->
  $("#main-wrap").html JST['loading']({text: text})
