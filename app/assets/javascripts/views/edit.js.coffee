class PicMixr.Views.Edit extends Backbone.View
  el: '#main-wrap'
  template: JST['edit']
  events:
    'click .route-bb': 'back'
  
  initialize: ->
    @pic = arguments[0].pic
    UT.p "PicMixr.Views.Edit -> initialize", @pic
  
  render: ->
    UT.p "PicMixr.Views.Edit -> render"
    size = UT.fit_dimensions(@pic.width, @pic.height, 558, 600)
    $(@el).html @template(width: size.width, height: size.height)
    $("#toolbox-wrap").html JST['toolbox']()
    @base_ctx = $("#base-image")[0].getContext('2d')
    UT.poorman_image_resize(@pic, @base_ctx, size.width, size.height)
    @
  
  show_draw: ->
    $("#tool-well").html JST['tools/draw']()
    default_color = "#0f0"
    default_radius = 10
    min_radius = 2
    # brush
    brush = new CanvasDrawing "draw",
      color: default_color
      lineWidth: default_radius * 2
      clearRect: true
    # brush preview
    paper = Raphael "raphael-brush-preview", $("#raphael-brush-preview").width(), 60
    preview = paper.circle(Math.round($("#raphael-brush-preview").width()/2), 30, default_radius).attr
      fill: default_color
      stroke: 'none'
    # brush size slider
    $("#brush-size-slider").slider
        range: "min"
        min: 0
        max: 25
        value: default_radius - min_radius
        slide: (e, ui) ->
          preview.attr r: ui.value + min_radius
          brush.setOption "lineWidth", (ui.value * 2) + min_radius
    # TODO brush color selector
    @

  back: (e) ->
    UT.route_bb "/", e
