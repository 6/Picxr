window.PicMixr =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    UT.p "PicMixr.init()"
    PicMixr.router = new PicMixr.Routers.PicMixrRouter()
    Backbone.history.start pushState:true

$ -> PicMixr.init()
