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
    @edit_mode = {draw: no, fx: no}
    UT.p "PicMixr.Views.Edit -> initialize", @pic
  
  render: ->
    UT.p "PicMixr.Views.Edit -> render"
    @size = UT.fit_dimensions(@pic.width, @pic.height, 558, 600)
    $(@el).html @template(width: @size.width, height: @size.height)
    $("#toolbox-wrap").html JST['toolbox']()
    @merge_canvas = document.createElement('canvas')
    $(@merge_canvas).attr("width", @size.width).attr("height", @size.height).attr("style", "width:#{@size.width}px;height:#{@size.height}px")
    @merge_ctx = @merge_canvas.getContext('2d')
    @
  
  init_fabric: ->
    @canvas = new fabric.Canvas 'fabric', {selection: no}
    @lower_canvas = $("#fabric")[0]
    @lower_ctx = @lower_canvas.getContext('2d')
    @draw_canvas = $(".upper-canvas")[0]
    @draw_ctx = @draw_canvas.getContext('2d')
    fabric.Image.fromURL @pic.src, (img) =>
      img.toDataURL (data) =>
        # grab image DataURL to store in memory
        temp_img = document.createElement('img')
        $(temp_img).attr("width", @size.width).attr("height", @size.height)
        temp_img.onload = =>
          dimg = new fabric.Image(temp_img)
          dimg.set(selectable:no, top: @size.height / 2, left: @size.width / 2, isBgImage: yes)
          @canvas.add dimg
          @_save_state()
          @_after_state_change()
        temp_img.src = data
    @
    
  show_fx: (e) ->
    e.preventDefault() if e?
    return @ if $("#show-fx").hasClass("disabled")
    @_destruct_events()
    @_set_edit_mode "fx"
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
    @_destruct_events()
    @_set_edit_mode "draw"
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
    @brush_preview = new fabric.Canvas 'brush-preview-canvas', {selection: no}
    tl = Math.round($("#brush-preview-canvas").width()/2)
    @brush_preview.add new fabric.Circle
      top: tl
      left: tl
      radius: default_radius
      fill: default_color
      selectable: no
    # brush size slider
    $("#brush-size-slider").slider
        range: "min"
        min: 0
        max: 25
        value: default_radius - min_radius
        slide: (e, ui) =>
          @brush_preview.item(0).set 'radius', ui.value + min_radius
          @brush_preview.renderAll()
          @canvas.freeDrawingLineWidth = (ui.value * 2) + min_radius
    # brush color selector
    $ =>
      $("#brush-color-selector").spectrum
        flat: true
        theme: 'sp-light'
        move: (color) =>
          @brush_preview.item(0).set 'fill', color.toHexString()
          @brush_preview.renderAll()
          @canvas.freeDrawingColor = color.toHexString()
    $("#tool-selector-well > .btn").removeClass("disabled")
    $("#show-draw").addClass("disabled")
    @
  
  eyedropper: (e) ->
    e.preventDefault()
    if $("#eyedropper").hasClass("primary")
      @canvas.isDrawingMode = yes
      @canvas.isEyedropperMode = no
      $("#eyedropper").removeClass("primary")
      @canvas.stopObserving 'mouse:up', @_on_eyedropper
    else
      $("#eyedropper").addClass("primary")
      @canvas.isDrawingMode = no
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
  
  _destruct_events: =>
    if @edit_mode.draw
      $("#eyedropper").click() if @canvas.isEyedropperMode
      @canvas.stopObserving 'drawing:completed', @_on_drawing_completed
      @canvas.isDrawingMode = no
  
  _set_edit_mode: (key) =>
    for k, v of @edit_mode
      @edit_mode[k] = no
    @edit_mode[key] = yes
  
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
    pixel = UT.get_pixel @lower_ctx, location.x, location.y
    rgb = "rgb(#{pixel.r},#{pixel.g},#{pixel.b})"
    @brush_preview.item(0).set 'fill', rgb
    @brush_preview.renderAll()
    @canvas.freeDrawingColor = rgb
    $("#brush-color-selector").spectrum("set", rgb)
    $("#eyedropper").click()
  
  _on_drawing_completed: (e) =>
    @merge_ctx.clearRect(0, 0, @size.width, @size.height)
    @merge_ctx.drawImage(@lower_canvas, 0, 0, @size.width, @size.height)
    @merge_ctx.drawImage(@draw_canvas, 0, 0, @size.width, @size.height)
    
    temp_img = document.createElement('img')
    temp_img.onload = =>
      img = new fabric.Image temp_img
      img.set(selectable:no, width:@size.width, height:@size.height, top: @size.height / 2, left: @size.width / 2)
      @canvas.add img
      @canvas.remove @canvas.item(0)
      @_save_state()
      @_after_state_change()
    temp_img.src = @merge_canvas.toDataURL("image/png")
