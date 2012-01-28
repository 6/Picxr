class PicMixr.Routers.PicMixrRouter extends Backbone.Router
  initialize: ->
    # Need to apply a custom regex for routes with non-alphanumeric params
    @route.apply @, [/edit\/([^\s]+)/, 'edit', @edit]
    @route.apply @, [/\?([^\s]+)/, 'index', @index]
  
  routes:
    "albums/:user_id": "user_albums"
    "album/:album_id": "album"
    "tags/:user_id": "tags"
    "upload/:type": "upload"
    "": "index"
  
  user_albums: (user_id) ->
    @_set_active("#nav-home")
    if Face.active()
      UT.p "Route ALBUMS for user #{user_id}"
      @destroy_view()
      albums = new PicMixr.Collections.Pictures
      Face.get_user_info user_id, (info) =>
        @view = new PicMixr.Views.Browse collection: albums, info: info, mode: 'albums'
        Face.user_albums user_id, (albums_models) =>
          albums.add albums_models
          @view.render()
    else
      if UT.first_page then @index(no) else UT.loading()
      Face.update_status_cb = -> PicMixr.router.user_albums(user_id)
  
  tags: (user_id) ->
    @_set_active("#nav-home")
    if Face.active()
      UT.p "Route TAGS for user #{user_id}"
      @destroy_view()
      pics = new PicMixr.Collections.Pictures
      Face.get_user_info user_id, (info) ->
        @view = new PicMixr.Views.Browse collection: pics, info: info, mode: 'tags'
        Face.tagged_photos user_id, (pics_models) ->
          pics.add pics_models
          @view.render()
    else
      if UT.first_page then @index(no) else UT.loading()
      Face.update_status_cb = -> PicMixr.router.tags(user_id)
    
  album: (album_id) ->
    @_set_active("#nav-home")
    if Face.active()
      UT.p "Route ALBUM for album #{album_id}"
      @destroy_view()
      pics = new PicMixr.Collections.Pictures
      Face.get_album_info album_id, (info) =>
        @view = new PicMixr.Views.Browse collection: pics, info: info, mode: 'album'
        Face.album_photos album_id, (pics_models) =>
          pics.add pics_models
          @view.render()
    else
      if UT.first_page then @index(no) else UT.loading()
      Face.update_status_cb = -> PicMixr.router.album(album_id)

  edit: (url) ->
    @_set_active()
    @destroy_view()
    clean_url = decodeURIComponent(url).replace(/@/g, ".")
    url = "#{UT.default_cb_href()}iproxy/#{encodeURIComponent clean_url.replace(/\./g, '@')}"
    UT.p "Route EDIT", clean_url, "through", url
    UT.loading()
    pic = new Image()
    pic.onload = =>
      @view = new PicMixr.Views.Edit pic: pic
      @view.render().init_libraries().show_draw()
    pic.onerror = =>
      UT.message "Error loading image."
    pic.src = url
    
  upload: (type) ->
    @_set_active("#nav-upload")
    @destroy_view()
    @view = new PicMixr.Views.Upload(type: type).render()
  
  index: (override_update_status_cb = yes) =>
    UT.p "Route INDEX"
    @_set_active("#nav-home")
    if Face.active()
      UT.loading()
      UT.route_bb Face.default_route()
    else
      @destroy_view()
      if override_update_status_cb
        Face.update_status_cb = -> PicMixr.router.index()
      @view = new PicMixr.Views.Landing().render()
  
  destroy_view: ->
    UT.p "destroy view if active:", @view
    @view.destroy() if @view? and @view.destroy?
    @view = null
    
  _set_active: (id) ->
    $(".nav .active").removeClass("active")
    $(id).addClass("active") if id?
