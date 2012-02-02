class PicMixr.Routers.PicMixrRouter extends Backbone.Router
  initialize: ->
    # Need to apply a custom regex for routes with non-alphanumeric params
    @route.apply @, [/edit\/([^\s]+)/, 'edit', @edit]
    @route.apply @, [/\?([^\s]+)/, 'index', @index]
  
  routes:
    "upload/:type": "upload"
    "": "index"

  edit: (url_or_id) =>
    @_set_active()
    @destroy_view()
    if url_or_id.substring(0, 2) is "p/"
      url = url_or_id
    else
      clean = decodeURIComponent(url_or_id).replace(/@/g, ".")
      url = encodeURIComponent clean.replace(/\./g, '@')
    url = "#{UT.default_cb_href()}iproxy/#{url}"
    UT.p "Route EDIT"
    UT.loading()
    pic = new Image()
    pic.onload = =>
      @view = new PicMixr.Views.Edit pic: pic
      @view.render().init_libraries().show_draw()
      url_start = url_or_id.substring(0,7)
      if url_start is "http://" or url_start is "https:/"
        @view.original_url = clean
      else
        @view.original_id = url_or_id
    pic.onerror = =>
      UT.message "Error loading image."
    pic.src = url
    
  upload: (type) ->
    @_set_active("#nav-upload")
    @destroy_view()
    @view = new PicMixr.Views.Upload(type: type).render()
  
  index: () =>
    UT.p "Route INDEX"
    @_set_active("#nav-home")
    @destroy_view()
    @view = new PicMixr.Views.Landing().render()
  
  destroy_view: ->
    UT.p "destroy view if active:", @view
    @view.destroy() if @view? and @view.destroy?
    @view = null
    
  _set_active: (id) ->
    $(".nav .active").removeClass("active")
    $(id).addClass("active") if id?
