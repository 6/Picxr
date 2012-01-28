class PicMixr.Views.TopbarFbImport extends PicMixr.Views.BaseView
  el: '#cta'
  template: JST['topbar/fb_import']
  events: ->
    _.extend super,
      'click #fb-auth': 'fb_auth'
    
  render: ->
    UT.p "PicMixr.Views.TopbarFbImport -> render"
    $(@el).html @template()
    @

  fb_auth: (e) ->
    e.preventDefault()
    $(@el).html JST['tween/loading']()
    Face.fb_login()
