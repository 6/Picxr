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
      #TODO loading
      Face.update_status_cb = -> PicMixr.router.user_albums(user_id)
    
  album: (album_id) ->
    if Face.active()
      UT.p "Route ALBUM for album #{album_id}"
      pics = new PicMixr.Collections.Pictures
      view = new PicMixr.Views.Browse collection: pics
      Face.album_photos album_id, (pics_models) ->
        pics.add pics_models
    else
      #TODO loading
      Face.update_status_cb = -> PicMixr.router.album(album_id)

  edit: (url) ->
    # don't need Facebook permissions to load image
    Face.update_status_cb = -> null
    url = decodeURIComponent url.replace(/@/g, ".")
    UT.p "Route EDIT", url
  
  index: ->
    UT.p "TODO convert to backbone"
