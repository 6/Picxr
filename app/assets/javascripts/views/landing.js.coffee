class PicMixr.Views.Landing extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['home']
  events: ->
    _.extend super,
      'click #fb-auth2': 'fb_auth'
  
  render: ->
    $(@el).html @template()
    
  fb_auth: (e) ->
    e.preventDefault()
    Face.fb_login()
