class PicMixr.Views.Edit extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['edit']
  
  events: ->
    _.extend super,
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
    @
  
  init_fabric: ->
    @canvas = new fabric.Canvas 'fabric', {selection: no}
    @ctx = $("#fabric")[0].getContext('2d')
    @draw_canvas = $(".upper-canvas")[0]
    fabric.Image.fromURL @pic.src, (img) =>
      centered = img.scaleToWidth(@size.width).set(top: @size.height / 2, left: @size.width / 2)
      centered.set 'selectable', no
      @canvas.add centered
    @
  
  show_draw: ->
    default_color = "#22ee55"
    default_radius = 10
    min_radius = 2
    $("#tool-well").html JST['tools/draw'](default_color: default_color)
    # brush
    @canvas.isDrawingMode = yes
    @canvas.freeDrawingColor = default_color
    @canvas.freeDrawingLineWidth = default_radius * 2
    @canvas.observe 'drawing:completed', (e) =>
      temp_img = document.createElement('img')
      temp_img.src = @draw_canvas.toDataURL("image/png")
      temp_img.onload = =>
        img = new fabric.Image(temp_img)
        img.set(selectable:no, width:@size.width, height:@size.height, top: @size.height / 2, left: @size.width / 2)
        @canvas.add img
      
    @canvas.observe 'path:created', (e) =>
      e.memo.path.set 'selectable', no
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
          @canvas.freeDrawingLineWidth = (ui.value * 2) + min_radius
    # brush color selector
    $ =>
      $("#brush-color-selector").spectrum
        flat: true
        theme: 'sp-light'
        move: (color) =>
          @preview.attr fill: color.toHexString()
          @canvas.freeDrawingColor = color.toHexString()
    @
  
  eyedropper: (e) ->
    e.preventDefault()
    if $("#eyedropper").hasClass("primary")
      @canvas.isDrawingMode = yes #TODO go back to previous mode
      @canvas.isEyedropperMode = no
      $("#eyedropper").removeClass("primary")
    else
      $("#eyedropper").addClass("primary")
      @canvas.isDrawingMode = no #TODO disable current mode
      @canvas.isEyedropperMode = yes
      @canvas.observe 'mouse:up', @_on_eyedropper
      @

  save: (e) ->
    e.preventDefault()
    data = @canvas.toDataURL("png")
    # remove "data:image/jpeg;base64,"
    data = data.substr(data.indexOf(',') + 1).toString()
    UT.non_ajax_post '/save-image', [{name: 'imgdata', value: data}]
    @
    
  _on_eyedropper: (e) =>
    @canvas.stopObserving 'mouse:up', @_on_eyedropper
    location = @canvas.getPointer(e.memo.e)
    pixel = UT.get_pixel @ctx, location.x, location.y
    rgb = "rgb(#{pixel.r},#{pixel.g},#{pixel.b})"
    @preview.attr fill: rgb
    @canvas.freeDrawingColor = rgb
    $("#brush-color-selector").spectrum("set", rgb)
    $("#eyedropper").click()
