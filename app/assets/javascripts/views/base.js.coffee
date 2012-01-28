class PicMixr.Views.BaseView extends Backbone.View
    
  events: ->
    'click .route-bb': 'route_bb'
    'click .route-default': 'route_default'
  
  route_bb: (e) ->
    UT.p "PicMixr.Views.BaseView -> route_bb #{e.target.pathname}"
    UT.route_bb e.target.pathname, e
    @
  
  route_default: (e) ->
    UT.p "PicMixr.Views.BaseView -> route_default"
    UT.route_default e
    @
  
  destroy: ->
    $(@el).removeData().unbind()
