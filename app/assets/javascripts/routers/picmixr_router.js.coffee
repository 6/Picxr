class PicMixr.Routers.PicMixrRouter extends Backbone.Router
  initialize: ->
    # Need to apply a custom regex for routes with non-alphanumeric params
    @route.apply @, [/edit\/([^\s]+)/, 'edit', @edit]
  
  routes:
    "user-albums/:user_id": "user_albums"
    "album/:album_id": "album"
    "": "index"
  
  user_albums: (user_id) ->
    if Face.active()
      UT.p "Route ALBUMS for user #{user_id}"
      albums = new PicMixr.Collections.Pictures
      view = new PicMixr.Views.Browse collection: albums, title: "[TODO: #{user_id}'s name]'s albums (fetch only once)"
      Face.user_albums user_id, (albums_models) ->
        albums.add albums_models
    else
      UT.loading "Loading photos"
      Face.update_status_cb = -> PicMixr.router.user_albums(user_id)
    
  album: (album_id) ->
    if Face.active()
      UT.p "Route ALBUM for album #{album_id}"
      pics = new PicMixr.Collections.Pictures
      view = new PicMixr.Views.Browse collection: pics
      Face.album_photos album_id, (pics_models) ->
        pics.add pics_models
    else
      UT.loading "Loading album"
      Face.update_status_cb = -> PicMixr.router.album(album_id)

  edit: (url) ->
    clean_url = decodeURIComponent url.replace(/@/g, ".")
    url = "#{UT.default_cb_href()}image-proxy/#{encodeURIComponent(clean_url).replace(/\./g, '@')}"
    UT.p "Route EDIT", clean_url, "through", url
    UT.loading "Loading"
    pic = new Image()
    #TODO handle onerror, onabort
    pic.onload = ->
      view = new PicMixr.Views.Edit pic: pic
      view.render().show_draw()
    pic.src = url
  
  index: ->
    UT.p "Route INDEX"
    $("#main-wrap").html JST['home']()
    $("#toolbox-wrap").html JST['toolbox']()
    Face.update_status_cb = "default"
