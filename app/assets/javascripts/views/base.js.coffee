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
    if Face.active()
      UT.route_bb Face.default_route(), e
    else
      UT.route_bb '/', e
    @
  
  destroy: ->
    $(@el).removeData().unbind()
