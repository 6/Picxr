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
      'click #show-text': 'show_text'
      # specific to partials
      'click #eyedropper': 'eyedropper'
      'click #insert-text': 'insert_text'
      'click #change-text': 'change_text'
  
  initialize: ->
    @pic = arguments[0].pic
    @saved_states = []
    @cur_state_idx = null
    @edit_mode = {draw: no, fx: no}
    @size = UT.fit_dimensions(@pic.width, @pic.height, 561, 600)
    @merge_canvas = document.createElement('canvas')
    $(@merge_canvas).attr("width", @size.width).attr("height", @size.height).attr("style", "width:#{@size.width}px;height:#{@size.height}px")
    @merge_ctx = @merge_canvas.getContext('2d')
    @current_color = "#22ee55"
    @current_opacity = 1
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
    $("#canvas-wrap").attr("style", "width:#{@size.width}px;height:#{@size.height}px")
    @restore_state_placeholder = $("#restore-state-placeholder")[0].getContext('2d')
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
    $(@canvas.wrapperEl).attr("id", "fabric-wrap").removeAttr("class").removeAttr("style")
    @lower_canvas = $("#fabric")[0]
    @lower_ctx = @lower_canvas.getContext('2d')
    @draw_canvas = $(".upper-canvas")[0]
    @draw_ctx = @draw_canvas.getContext('2d')
    @draw_canvas.onselectstart = () -> return false # prevent text cursor on drag
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
    
  show_draw: (e) ->
    e.preventDefault() if e?
    return @ if $("#show-draw").hasClass("disabled")
    @_set_edit_mode "draw"
    default_radius = 7
    min_radius = 2
    $("#tool-well").html JST['tools/draw'](default_color: @current_color)
    # brush
    @canvas.isDrawingMode = yes
    @canvas.freeDrawingLineWidth = default_radius * 2
    @canvas.observe 'drawing:completed', @_on_drawing_completed
    # brush preview
    @brush_preview = new fabric.Canvas 'brush-preview-canvas', {selection: no}
    tl = Math.round($("#brush-preview-canvas").width()/2)
    @brush_preview.add new fabric.Circle
      top: tl
      left: tl
      radius: default_radius
      selectable: no
    # brush size slider
    $("#brush-size-slider").slider
        range: "min"
        min: 0
        max: 18
        value: default_radius - min_radius
        slide: (e, ui) =>
          @brush_preview.item(0).set 'radius', ui.value + min_radius
          @brush_preview.renderAll()
          @canvas.freeDrawingLineWidth = (ui.value * 2) + min_radius
    $("#brush-opacity-slider").slider
        range: "min"
        min: 5
        max: 50
        value: @current_opacity * 50
        slide: (e, ui) =>
          @current_opacity = ui.value / 50
          @_set_color @current_color
    # brush color selector
    $("#brush-color-selector").spectrum
      flat: no
      theme: 'sp-light'
      move: (color) => @_set_color color.toHexString(), no
    
    @_set_color @current_color
    @
  
  eyedropper: (e) ->
    e.preventDefault()
    if $("#eyedropper").hasClass("primary-down")
      @canvas.isDrawingMode = yes
      @canvas.isEyedropperMode = no
      $("#eyedropper").removeClass("primary-down")
      @canvas.stopObserving 'mouse:up', @_on_eyedropper
      @canvas.stopObserving 'mouse:move', @_on_eyedropper_move
      $(@draw_canvas).unbind('mouseenter mouseleave')
    else
      $("#eyedropper").addClass("primary-down")
      @canvas.isDrawingMode = no
      @canvas.isEyedropperMode = yes
      @canvas.observe 'mouse:up', @_on_eyedropper
      @canvas.observe 'mouse:move', @_on_eyedropper_move
      $(@draw_canvas).mouseleave @_on_eyedropper_leave
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
    return @ if $("#save-button").hasClass("disabled")
    $("#save-button").addClass("disabled")
    $("input[name=privacy]").attr("disabled", true)
    window.onbeforeunload = null
    @canvas.deactivateAll()
    @canvas.renderAll()
    data = @canvas.toDataURL("png")
    # remove "data:image/png;base64,"
    post_data = {imgdata: data.substr(data.indexOf(',') + 1)}
    post_data.private = "yes" if $("#privacy-private").is(':checked')
    post_data.original = @original_id if @original_id?
    post_data.original_url = @original_url if @original_url?
    $.post('/save', post_data, (id) ->
      UT.redirect "/#{id}"
    ).error () ->
      alert("Error saving the image. Try pressing the save button again.")
      $("#save-button").removeClass("disabled")
      $("input[name=privacy]").attr("disabled", false)
    @
  
  _save_state: =>
    UT.p "SAVE STATE"
    if @cur_state_idx? and @cur_state_idx < @saved_states.length - 1
      # overwrite (remove) existing "redo" states
      @saved_states.splice(@cur_state_idx + 1)
    @saved_states.push JSON.stringify(@canvas)
    @cur_state_idx = if @cur_state_idx? then @cur_state_idx + 1 else 0
    @_after_state_change()
    
  _restore_state: (idx_delta) =>
    new_idx = @cur_state_idx + idx_delta
    UT.p "RESTORE STATE #{idx_delta} -> #{new_idx}" 
    unless new_idx < 0 or new_idx > @saved_states.length - 1
      @cur_state_idx = new_idx
      $("#text-edit-wrap").hide(0)
      @restore_state_placeholder.drawImage(@lower_canvas, 0, 0, @size.width, @size.height)
      $("#fabric-wrap").hide(0)
      $("#restore-state-placeholder").show(0)
      @canvas.loadFromJSON @saved_states[@cur_state_idx], () =>
        $("#fabric-wrap").show(0)
        $("#restore-state-placeholder").hide(0)
        @restore_state_placeholder.clearRect(0, 0, @size.width, @size.height)
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
      window.onbeforeunload ?= UT.onbeforeunload
  
  _set_edit_mode: (key) =>
    # destruct/unbind events
    if @edit_mode.draw
      $("#eyedropper").click() if @canvas.isEyedropperMode
      @canvas.stopObserving 'drawing:completed', @_on_drawing_completed
      @canvas.isDrawingMode = no
    #remove any active selections
    @canvas.deactivateAll()
    @canvas.renderAll()
    # set the new edit mode
    for k, v of @edit_mode
      @edit_mode[k] = no
    @edit_mode[key] = yes
    $("#tool-selector-well > .btn").removeClass("disabled primary-down")
    $("#show-#{key}").addClass("disabled primary-down")
  
  _on_eyedropper_move: (e) =>
    location = @canvas.getPointer(e.memo.e)
    pixel = UT.get_pixel @lower_ctx, location.x, location.y
    @_set_color "rgb(#{pixel.r},#{pixel.g},#{pixel.b})", yes, no
    
  _on_eyedropper_leave: (c) =>
    @_set_color @current_color if @current_color?
     
  _on_eyedropper: (e) =>
    $("#eyedropper").click()
    location = @canvas.getPointer(e.memo.e)
    pixel = UT.get_pixel @lower_ctx, location.x, location.y
    @_set_color "rgb(#{pixel.r},#{pixel.g},#{pixel.b})"
  
  _set_color: (color_string, set_spectrum = yes, set_current_color = yes) ->
    color_string = UT.change_color_opacity(color_string, @current_opacity)
    @brush_preview.item(0).set 'fill', color_string
    @brush_preview.renderAll()
    @canvas.freeDrawingColor = color_string
    $("#brush-color-selector").spectrum("set", color_string) if set_spectrum
    @current_color = @canvas.freeDrawingColor if set_current_color
  
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
