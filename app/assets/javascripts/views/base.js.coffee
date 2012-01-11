class PicMixr.Views.BaseView extends Backbone.View
  events:
    'click .route-bb': 'route_bb'
  
  route_bb: (e) ->
    UT.p "PicMixr.Views.BaseView -> route_bb #{e.target.pathname}"
    UT.route_bb e.target.pathname, e
    @
