class PicMixr.Views.TopbarFbUserInfo extends PicMixr.Views.BaseView
  el: '#cta-row'
  template: JST['topbar/fb_user_info']
  events: ->
    _.extend super,
      'click #fb-logout': 'fb_logout'

  render: (info) ->
    UT.p "PicMixr.Views.TopbarFbUserInfo -> render_fb_user"
    $(@el).html @template(info)
    @
    
  fb_logout: (e) ->
    e.preventDefault()
    $(@el).html JST['tween/loading']()
    Face.fb_logout()
