class PicMixr.Routers.PicMixrRouter extends Backbone.Router
  routes:
    #TODO make controllers for each of these that pass appropriate data to views
    "/albums/:user_id": "albums"
    "/album/:album_id": "album"
    "/edit/?:params": "edit"
    "": "index"
  
  albums: (user_id) ->
    UT.p "Route ALBUMS"
    
  album: (album_id) ->
    UT.p "Route ALBUM"

  edit: (params) ->
    UT.p "Route EDIT",params,params.url
  
  index: ->
    UT.p "TODO only do something here if already logged into fb? (put FB data in session)"
