class PicMixr.Routers.PicMixrRouter extends Backbone.Router
  routes:
    "albums/:user_id": "albums"
    "album/:album_id": "album"
    "edit/?:params": "edit"
    "": "index"
  
  albums: (user_id) ->
    UT.p "Route ALBUMS for user #{user_id}"
    
  album: (album_id) ->
    UT.p "Route ALBUM for album #{album_id}"

  edit: (params) ->
    UT.p "Route EDIT",params,params.url
  
  index: ->
    UT.p "TODO only do something here if already logged into fb? (put FB data in session)"
