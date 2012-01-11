class PicMixr.Views.Edit extends Backbone.View
  el: '#main-wrap'
  template: JST['edit']
  events:
    'click .route-bb': 'back'
    'click .save': 'save'
    'click #eyedropper': 'eyedropper'
  
  initialize: ->
    @pic = arguments[0].pic
    UT.p "PicMixr.Views.Edit -> initialize", @pic
  
  render: ->
    UT.p "PicMixr.Views.Edit -> render"
    @size = UT.fit_dimensions(@pic.width, @pic.height, 558, 600)
    $(@el).html @template(width: @size.width, height: @size.height)
    $("#toolbox-wrap").html JST['toolbox']()
    @base_ctx = $("#base-image")[0].getContext('2d')
    @draw_ctx = $("#draw")[0].getContext('2d')
    UT.poorman_image_resize(@pic, @base_ctx, @size.width, @size.height)
    @
  
  show_draw: ->
    default_color = "#22ee55"
    default_radius = 10
    min_radius = 2
    $("#tool-well").html JST['tools/draw'](default_color: default_color)
    # brush
    @brush = new CanvasDrawing "draw",
      color: default_color
      lineWidth: default_radius * 2
      "background-color": "rgba(0,0,0,0)"
    # brush preview
    paper = Raphael "raphael-brush-preview", $("#raphael-brush-preview").width(), 60
    @preview = paper.circle(Math.round($("#raphael-brush-preview").width()/2), 30, default_radius).attr
      fill: default_color
      stroke: 'none'
    # brush size slider
    $("#brush-size-slider").slider
        range: "min"
        min: 0
        max: 25
        value: default_radius - min_radius
        slide: (e, ui) =>
          @preview.attr r: ui.value + min_radius
          @brush.setOption "lineWidth", (ui.value * 2) + min_radius
    # brush color selector
    $ =>
      $("#brush-color-selector").spectrum
        flat: true
        theme: 'sp-light'
        move: (color) =>
          @preview.attr fill: color.toHexString()
          @brush.setOption "color", color.toHexString()
    @
  
  eyedropper: (e) ->
    e.preventDefault()
    if $("#eyedropper").hasClass("primary")
      @brush.disableEyedropper()
      $("#eyedropper").removeClass("primary")
      $("#draw").attr("style", "")
    else
      $("#eyedropper").addClass("primary")
      $("#draw").attr("style", "cursor:crosshair")
      @brush.enableEyedropper (x, y) =>
        $("#eyedropper").removeClass("primary")
        $("#draw").attr("style", "")
        pixel = UT.get_pixel(@draw_ctx, x, y)
        if pixel.a is 0
          pixel = UT.get_pixel(@base_ctx, x, y)
        #TODO take into account if alpha transparency (calc lower layers)
        rgb = "rgb(#{pixel.r},#{pixel.g},#{pixel.b})"
        @preview.attr fill: rgb
        @brush.setOption "color", rgb
        $("#brush-color-selector").spectrum("set", rgb)
      @

  save: (e) ->
    e.preventDefault()
    UT.merge_layers @base_ctx, $("#draw")[0], @size.width, @size.height
    data = $("#base-image")[0].toDataURL("image/jpeg")
    # remove "data:image/jpeg;base64,"
    data = data.substr(data.indexOf(',') + 1).toString()
    UT.non_ajax_post '/save-image', [{name: 'imgdata', value: data}]
    @

  back: (e) ->
    UT.route_bb "/", e
    @
