class PicMixr.Views.Upload extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['upload']
  
  initialize: (@opts) ->

  render: =>
    UT.p "PicMixr.Views.Upload -> render"
    $(@el).html @template(type: @opts.type)
    if @opts.type is "url"
      $("#upload-form-wrap").html JST['forms/url_upload']()
    else
      $("#upload-form-wrap").html JST['forms/desktop_upload']()
    @
