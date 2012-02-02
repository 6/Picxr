window.PicMixr =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    return if $("html").data("controller") in ["static", "pictures"]
    UT.p "PicMixr.init()"
    PicMixr.router = new PicMixr.Routers.PicMixrRouter()
    Backbone.history.start pushState:true

$ -> PicMixr.init()
