class PicMixr.Views.Edit extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['edit']
  
  events: ->
    _.extend super,
      # global events
      'click .save': 'save'
      'click #undo': 'undo'
      'click #redo': 'redo'
      'click #show-draw': 'show_draw'
      'click #show-fx': 'show_fx'
      # specific to partials
      'click #eyedropper': 'eyedropper'
      'click #grayscale': 'grayscale'
      'click #invert': 'invert'
  
  initialize: ->
    @confirm_leave = "Are you sure you want to leave without saving?"
    @pic = arguments[0].pic
    @saved_states = []
    @cur_state_idx = null
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
      img.toDataURL (data) =>
        # grab image DataURL to store in memory
        temp_img = document.createElement('img')
        temp_img.src = data
        temp_img.onload = =>
          dimg = new fabric.Image(temp_img)
          dimg.scaleToWidth(@size.width).set(selectable:no, top: @size.height / 2, left: @size.width / 2, isBgImage: yes)
          @canvas.add dimg
          @_save_state()
          @_after_state_change()
    @
    
  show_fx: (e) ->
    e.preventDefault() if e?
    return @ if $("#show-fx").hasClass("disabled")
    #TODO need a better way to stopObserving ALL events and change modes
    @canvas.isDrawingMode = no
    $("#eyedropper").click() if @canvas.isEyedropperMode
    @canvas.stopObserving 'drawing:completed', @_on_drawing_completed
    #END TODO
    $("#tool-well").html JST['tools/fx']()
      
    # brightness slider
    $("#brightness-slider").slider
        range: "min"
        min: -25
        max: 25
        value: 0
        slide: (e, ui) =>
          @_apply_filter 3, new fabric.Image.filters.Brightness(delta:ui.value * 3), no
        stop: (e, ui) =>
          @_save_state()
          @_after_state_change()
    
    $("#tool-selector-well > .btn").removeClass("disabled")
    $("#show-fx").addClass("disabled")
    @
  
  grayscale: (e) ->
    e.preventDefault()
    @_apply_filter 0, new fabric.Image.filters.Grayscale()
    @
  
  invert: (e) ->
    e.preventDefault()
    @_apply_filter 1, new fabric.Image.filters.Invert()
    @
  
  show_draw: (e) ->
    e.preventDefault() if e?
    return @ if $("#show-draw").hasClass("disabled")
    default_color = "#22ee55"
    default_radius = 10
    min_radius = 2
    $("#tool-well").html JST['tools/draw'](default_color: default_color)
    # brush
    @canvas.isDrawingMode = yes
    @canvas.freeDrawingColor = default_color
    @canvas.freeDrawingLineWidth = default_radius * 2
    @canvas.observe 'drawing:completed', @_on_drawing_completed
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
    $("#tool-selector-well > .btn").removeClass("disabled")
    $("#show-draw").addClass("disabled")
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
  
  undo: (e) ->
    e.preventDefault()
    return if $("#undo").hasClass("disabled")
    @_restore_state(-1)
    @_after_state_change()
  
  redo: (e) ->
    e.preventDefault()
    return if $("#redo").hasClass("disabled")
    @_restore_state(1)
    @_after_state_change()

  save: (e) ->
    e.preventDefault()
    data = @canvas.toDataURL("png")
    # remove "data:image/png;base64,"
    data = data.substr(data.indexOf(',') + 1).toString()
    $.post '/save', {imgdata: data}, (id) ->
      UT.redirect "/#{id}"
    @
  
  _save_state: =>
    if @cur_state_idx? and @cur_state_idx < @saved_states.length - 1
      # overwrite (remove) existing "redo" states
      @saved_states.splice(@cur_state_idx + 1)
    @saved_states.push @canvas.toJSON()
    @cur_state_idx = if @cur_state_idx? then @cur_state_idx + 1 else 0
    
  _restore_state: (idx_delta) =>
    new_idx = @cur_state_idx + idx_delta
    unless new_idx < 0 or new_idx > @saved_states.length - 1
      @cur_state_idx = new_idx
      @canvas.loadFromDatalessJSON @saved_states[@cur_state_idx], =>
        @canvas.forEachObject((obj) =>
          if obj.get('type') is 'image'
            obj.applyFilters(@canvas.renderAll.bind(@canvas))
        , @canvas)
    
  _after_state_change: =>
    # toggle whether or not undo/redo button is clickable
    if !@cur_state_idx? or @cur_state_idx is 0
      $("#undo").addClass("disabled")
    else
      $("#undo").removeClass("disabled")
    if !@cur_state_idx? or @cur_state_idx is @saved_states.length - 1
      $("#redo").addClass("disabled")
    else
      $("#redo").removeClass("disabled")
  
  _apply_filter: (filter_idx, filter, is_save_state = yes) =>
    @canvas.forEachObject((obj) =>
      if obj.get('type') is 'image'
        obj.filters[filter_idx] = filter
        obj.applyFilters(@canvas.renderAll.bind(@canvas))
    , @canvas)
    if is_save_state
      @_save_state()
      @_after_state_change()
    
  _on_eyedropper: (e) =>
    @canvas.stopObserving 'mouse:up', @_on_eyedropper
    location = @canvas.getPointer(e.memo.e)
    pixel = UT.get_pixel @ctx, location.x, location.y
    rgb = "rgb(#{pixel.r},#{pixel.g},#{pixel.b})"
    @preview.attr fill: rgb
    @canvas.freeDrawingColor = rgb
    $("#brush-color-selector").spectrum("set", rgb)
    $("#eyedropper").click()
  
  _on_drawing_completed: (e) =>
    temp_img = document.createElement('img')
    temp_img.src = @draw_canvas.toDataURL("image/png")
    temp_img.onload = =>
      img = new fabric.Image(temp_img)
      img.set(selectable:no, width:@size.width, height:@size.height, top: @size.height / 2, left: @size.width / 2)
      @canvas.add img
      @_save_state()
      @_after_state_change()
