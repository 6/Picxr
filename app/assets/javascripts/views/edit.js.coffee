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
      'click #show-text': 'show_text'
      # specific to partials
      'click #eyedropper': 'eyedropper'
      'click #grayscale': 'grayscale'
      'click #invert': 'invert'
      'click #grungy': 'grungy'
      'click #lomo': 'lomo'
      'click #vintage': 'vintage'
      'click #hazyDays': 'hazyDays'
      'click #swirl': 'swirl'
      'click #bulge': 'bulge'
      'click #insert-text': 'insert_text'
      'click #change-text': 'change_text'
  
  initialize: ->
    @pic = arguments[0].pic
    @saved_states = []
    @cur_state_idx = null
    @edit_mode = {draw: no, fx: no}
    @size = UT.fit_dimensions(@pic.width, @pic.height, 558, 600)
    @merge_canvas = document.createElement('canvas')
    $(@merge_canvas).attr("width", @size.width).attr("height", @size.height).attr("style", "width:#{@size.width}px;height:#{@size.height}px")
    @merge_ctx = @merge_canvas.getContext('2d')
    @sliders = []
    # keyboard shortcuts
    $(document).bind 'keydown', 'ctrl+z', @undo
    $(document).bind 'keydown', 'meta+z', @undo
    $(document).bind 'keydown', 'ctrl+y', @redo
    $(document).bind 'keydown', 'meta+shift+z', @redo
    UT.p "PicMixr.Views.Edit -> initialize", @pic
  
  render: ->
    UT.p "PicMixr.Views.Edit -> render"
    $(@el).html @template(width: @size.width, height: @size.height)
    $("#toolbox-wrap").html JST['toolbox']()
    @
  
  destroy: =>
    UT.p "PicMixr.Views.Edit -> destroy"
    # unbind keyboard shortcuts
    $(document).unbind('keydown', @undo)
    $(document).unbind('keydown', @redo)
    # remove onbeforeunload alert
    window.onbeforeunload = null
    @
  
  init_libraries: ->
    @canvas = new fabric.Canvas 'fabric', {selection: no}
    @lower_canvas = $("#fabric")[0]
    @lower_ctx = @lower_canvas.getContext('2d')
    @draw_canvas = $(".upper-canvas")[0]
    @draw_ctx = @draw_canvas.getContext('2d')
    @glfx_fx = null
    placeholder = document.getElementById('glfx-placeholder')
    try
      @glfx = fx.canvas()
      @glfx.replace(placeholder)
      $("#glfx-wrap > canvas").attr("id", "glfx-canvas")
    catch e
      placeholder.innerHTML = e
    fabric.Image.fromURL @pic.src, (img) =>
      img.toDataURL (data) =>
        # grab image DataURL to store in memory
        temp_img = document.createElement('img')
        $(temp_img).attr("width", @size.width).attr("height", @size.height)
        temp_img.onload = =>
          dimg = new fabric.Image(temp_img)
          dimg.set(selectable:no, top: @size.height / 2, left: @size.width / 2, isBgImage: yes)
          @canvas.add dimg
          @glfx_texture = @glfx.texture temp_img
          @glfx.draw(@glfx_texture).update()
          @_save_state()
        temp_img.src = data
    @canvas.observe 'object:modified', @_on_object_modified
    @canvas.observe 'object:selected', @_on_object_selected
    @canvas.observe 'selection:cleared', @_on_selection_cleared
    @
    
  show_text: (e, cb) =>
    e.preventDefault() if e?      
    if $("#show-text").hasClass("disabled")
      cb() if cb?
      return @
    @_set_edit_mode "text"
    $("#tool-well").html JST['tools/text']()
    $("#text-color-selector").spectrum
      flat: no
      theme: 'sp-light'
      show: (color) => @color_before = color.toHexString()
      move: (color) =>
        @canvas.getActiveObject().set 'fill', color.toHexString()
        @canvas.renderAll()
      hide: (color) => @_save_state() if @color_before isnt color.toHexString()
    $("#tool-selector-well > .btn").removeClass("disabled")
    $("#show-text").addClass("disabled")
    cb() if cb?
    
  insert_text: (e) ->
    e.preventDefault()
    text = $.trim($('#text-to-insert').val())
    return unless text.length > 0
    text_obj = new fabric.Text text,
      left: Math.round(@size.width/2)
      top: Math.round(@size.height/2)
      fontFamily: 'CA_BND_Web_Bold_700'
      fill: "#fff"
      fontSize: 50
      strokeWidth: 5
      strokeStyle: "#000"
    @canvas.add text_obj
    @canvas.setActiveObject text_obj
    $("#text-to-insert").val("")
    @_save_state()
  
  change_text: (e) =>
    e.preventDefault()
    text = $.trim($('#text-to-edit').val())
    text_obj = @canvas.getActiveObject()
    return if text_obj.text is text or text.length is 0
    text_obj.text = text
    @_after_edit_text yes
    
  _edit_text: =>
    text_obj = @canvas.getActiveObject()
    return unless text_obj?
    $("#text-to-edit").val(text_obj.text)
    $("#text-edit-wrap").show(0)
  
  _after_edit_text: (is_save_state) =>
    @canvas.renderAll()
    @_save_state() if is_save_state

  show_fx: (e) ->
    e.preventDefault() if e?
    return @ if $("#show-fx").hasClass("disabled")
    @_set_edit_mode "fx"
    $("#tool-well").html JST['tools/fx']()
      
    #TODO reduce duplicate slider code
    $("#brightness-slider").slider
        range: "min"
        min: -5
        max: 5
        value: 0
        slide: (e, ui) =>
          global_this = @
          @_prepare_filter () ->
            Caman "#caman-img", () ->
              @brightness(ui.value).render () ->
                global_this._after_filter(no)
        stop: @_save_state
      
    @sliders.push("#brightness-slider")
    $("#contrast-slider").slider
        range: "min"
        min: -5
        max: 5
        value: 0
        slide: (e, ui) =>
          global_this = @
          @_prepare_filter () ->
            Caman "#caman-img", () ->
              @contrast(ui.value).render () ->
                global_this._after_filter(no)
        stop: @_save_state
      @sliders.push("#contrast-slider")
      $("#saturation-slider").slider
          range: "min"
          min: -100
          max: 100
          value: 0
          slide: (e, ui) =>
            global_this = @
            @_prepare_filter () ->
              Caman "#caman-img", () ->
                @saturation(ui.value).render () ->
                  global_this._after_filter(no)
          stop: @_save_state
      @sliders.push("#saturation-slider")
      $("#hue-slider").slider
          range: "min"
          min: 0
          max: 100
          value: 0
          slide: (e, ui) =>
            global_this = @
            @_prepare_filter () ->
              Caman "#caman-img", () ->
                @hue(ui.value).render () ->
                  global_this._after_filter(no)
          stop: @_save_state
      @sliders.push("#hue-slider")
    
    $("#tool-selector-well > .btn").removeClass("disabled")
    $("#show-fx").addClass("disabled")
    @
  
  grayscale: (e) ->
    e.preventDefault()
    global_this = @
    @_prepare_filter () ->
      Caman "#caman-img", () ->
        @greyscale().render global_this._after_filter
    @
  
  invert: (e) ->
    e.preventDefault()
    global_this = @
    @_prepare_filter () ->
      Caman "#caman-img", () ->
        @invert().render global_this._after_filter
    @
    
  grungy: (e) ->
    e.preventDefault()
    global_this = @
    @_prepare_filter () ->
      Caman "#caman-img", () ->
        @grungy().render global_this._after_filter
    @
    
  lomo: (e) ->
    e.preventDefault()
    global_this = @
    @_prepare_filter () ->
      Caman "#caman-img", () ->
        @lomo().render global_this._after_filter
    @
    
  vintage: (e) ->
    e.preventDefault()
    global_this = @
    @_prepare_filter () ->
      Caman "#caman-img", () ->
        @vintage().render global_this._after_filter
    @

  hazyDays: (e) ->
    e.preventDefault()
    global_this = @
    @_prepare_filter () ->
      Caman "#caman-img", () ->
        @hazyDays().render global_this._after_filter
    @
    
  _glfx_start_stop: (id, e, hide = yes) =>
    e.preventDefault() if e?
    if $(id).hasClass("primary")
      @glx_fx = null
      $(id).removeClass("primary")
      $("#glfx-canvas").mousefu_unbind()
      # hide glfx if shown
      if hide and $("#glfx-wrap").is(":visible")
        $(".canvas-container").show(0)
        $("#glfx-wrap").hide(0)
    else
      @_glfx_start_stop(@glx_fx, null, no) if @glx_fx?
      @glx_fx = id
      $(id).addClass("primary")
      # show glfx if not shown
      unless $("#glfx-wrap").is(":visible")
        @_load_img @lower_canvas.toDataURL("png"), (img) =>
          @glfx_texture = @glfx.texture img
          @glfx.draw(@glfx_texture).update()
          $("#glfx-wrap").show(0)
          $(".canvas-container").hide(0)
    
  swirl: (e) ->
    @_glfx_start_stop "#swirl", e
    $("#glfx-canvas").mousefu 'downleft move', (c) =>
      @glfx.draw(@glfx_texture).swirl(c.move.x, c.move.y, 150, 3).update()
    $("#glfx-canvas").mousefu 'upleft',
      start: (c) =>
        data = @glfx.toDataURL('image/png')
        @_load_img data, (img) =>
          @glfx_texture = @glfx.texture img
          @_replace_fabric_image_from_canvas data, yes
    
  bulge: (e) ->
    @_glfx_start_stop "#bulge", e
    $("#glfx-canvas").mousefu 'downleft move', (c) =>
      @glfx.draw(@glfx_texture).bulgePinch(c.move.x, c.move.y, 150, 3).update()
    $("#glfx-canvas").mousefu 'upleft',
      start: (c) =>
        data = @glfx.toDataURL('image/png')
        @_load_img data, (img) =>
          @glfx_texture = @glfx.texture img
          @_replace_fabric_image_from_canvas data, yes
    
  _prepare_filter: (cb) =>
    #$("#hidden-elements").html("")
    caman_img = document.createElement('img')
    $(caman_img).attr("id", "caman-img").data("camanwidth", @size.width).data("camanheight", @size.height).appendTo("#hidden-elements")
    caman_img.onload = => cb()
    caman_img.src = @lower_canvas.toDataURL("image/png")
  
  _after_filter: (is_save_state = yes) =>
    @_replace_fabric_image_from_canvas $("canvas#caman-img")[0].toDataURL("image/png"), is_save_state
    
  show_draw: (e) ->
    e.preventDefault() if e?
    return @ if $("#show-draw").hasClass("disabled")
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
  
  undo: (e) =>
    e.preventDefault()
    return if $("#undo").hasClass("disabled")
    @_restore_state(-1)
  
  redo: (e) =>
    e.preventDefault()
    return if $("#redo").hasClass("disabled")
    @_restore_state(1)

  save: (e) ->
    e.preventDefault()
    window.onbeforeunload = null
    @canvas.deactivateAll()
    @canvas.renderAll()
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
    @saved_states.push JSON.stringify(@canvas)
    @cur_state_idx = if @cur_state_idx? then @cur_state_idx + 1 else 0
    @_after_state_change()
    
  _restore_state: (idx_delta) =>
    new_idx = @cur_state_idx + idx_delta
    unless new_idx < 0 or new_idx > @saved_states.length - 1
      @cur_state_idx = new_idx
      $("#text-edit-wrap").hide(0)
      @canvas.loadFromJSON @saved_states[@cur_state_idx], () =>
        if $("#glfx-wrap").is(":visible")
          # restore glfx canvas as well, since it's visible
          @_load_img @lower_canvas.toDataURL("png"), (img) =>
            @glfx_texture = @glfx.texture img
            @glfx.draw(@glfx_texture).update()
        @_after_state_change()
    
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
    # confirm leave page alert only after at least one edit
    if @cur_state_idx >= 1
      window.onbeforeunload ?= @_onbeforeunload
      @confirm_leave = @_onbeforeunload()
  
  _set_edit_mode: (key) =>
    # destruct/unbind events
    if @edit_mode.draw
      $("#eyedropper").click() if @canvas.isEyedropperMode
      @canvas.stopObserving 'drawing:completed', @_on_drawing_completed
      @canvas.isDrawingMode = no
    else if @edit_mode.fx
      $("#swirl").click() if $("#swirl").hasClass("primary")
    #remove any active selections
    @canvas.deactivateAll()
    @canvas.renderAll()
    # destroy sliders
    $(slider_el).slider("destroy") for slider_el in @sliders
    # set the new edit mode
    for k, v of @edit_mode
      @edit_mode[k] = no
    @edit_mode[key] = yes
    
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
    @_replace_fabric_image_from_canvas @merge_canvas.toDataURL("image/png"), yes
    
  _replace_fabric_image_from_canvas: (data, is_save_state, cb=null) =>
    @_load_img data, (temp_img) =>
      img = new fabric.Image temp_img
      img.set(selectable:no, width:@size.width, height:@size.height, top: @size.height / 2, left: @size.width / 2)
      @canvas.add img
      @canvas.remove @canvas.item(0)
      @_save_state() if is_save_state
      cb() if cb?
  
  _load_img: (src, cb) =>
    temp_img = document.createElement('img')
    temp_img.onload = => cb(temp_img)
    temp_img.src = src
    
  _on_object_modified: (e) =>
    @_save_state() if e.memo.target.type is "text"
  
  _on_object_selected: (e) =>
    if e.memo.target.type is "text"
      @show_text null, @_edit_text
  
  _on_selection_cleared: (e) =>
    $("#text-edit-wrap").hide(0) if @edit_mode.text
  
  _onbeforeunload: () => "Are you sure you want to leave? All your changes will be lost."
