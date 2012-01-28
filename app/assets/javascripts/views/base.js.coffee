class PicMixr.Views.BaseView extends Backbone.View
    
  events: ->
    'click .route-bb': 'route_bb'
    'click .route-default': 'route_default'
  
  route_bb: (e) ->
    UT.p "PicMixr.Views.BaseView -> route_bb #{e.target.pathname}"
    leave = @_confirm_leave_if_enabled e
    return @ unless leave
    UT.route_bb e.target.pathname, e
    @
  
  route_default: (e) ->
    UT.p "PicMixr.Views.BaseView -> route_default"
    leave = @_confirm_leave_if_enabled e
    return @ unless leave
    UT.route_default e
    @
  
  destroy: ->
    $(@el).removeData().unbind()
  
  _confirm_leave_if_enabled: (e) =>
    if @confirm_leave?
      r = confirm @confirm_leave
      e.preventDefault() unless r
      r
    else true
