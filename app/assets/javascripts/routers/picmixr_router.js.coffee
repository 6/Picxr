class PicMixr.Routers.PicMixrRouter extends Backbone.Router
  initialize: ->
    # Need to apply a custom regex for routes with non-alphanumeric params
    @route.apply @, [/edit\/([^\s]+)/, 'edit', @edit]
    @route.apply @, [/\?([^\s]+)/, 'index', @index]
  
  routes:
    "albums/:user_id": "user_albums"
    "album/:album_id": "album"
    "upload/:type": "upload"
    "": "index"
  
  user_albums: (user_id) ->
    if Face.active()
      UT.p "Route ALBUMS for user #{user_id}"
      @destroy_view()
      albums = new PicMixr.Collections.Pictures
      @view = new PicMixr.Views.Browse collection: albums, title: "[TODO: #{user_id}'s name]'s albums (fetch only once)"
      Face.user_albums user_id, (albums_models) ->
        albums.add albums_models
    else
      UT.loading()
      Face.update_status_cb = -> PicMixr.router.user_albums(user_id)
    
  album: (album_id) ->
    if Face.active()
      UT.p "Route ALBUM for album #{album_id}"
      @destroy_view()
      pics = new PicMixr.Collections.Pictures
      @view = new PicMixr.Views.Browse collection: pics, title: "[TODO album title]"
      Face.album_photos album_id, (pics_models) ->
        pics.add pics_models
    else
      UT.loading()
      Face.update_status_cb = -> PicMixr.router.album(album_id)

  edit: (url) ->
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
    if type is "url"
      @view = new PicMixr.Views.UrlUpload
      @view.render()
    else
      $("#main-wrap").html JST['forms/desktop_upload']()
  
  index: ->
    UT.p "Route INDEX"
    if Face.active()
      UT.loading()
      UT.route_bb Face.default_route()
    else
      @destroy_view()
      Face.update_status_cb = -> PicMixr.router.index()
      $("#main-wrap").html JST['home']()
      $("#toolbox-wrap").html JST['toolbox']()
  
  destroy_view: ->
    UT.p "destroy view if active:", @view
    @view.destroy() if @view? and @view.destroy?
    @view = null
