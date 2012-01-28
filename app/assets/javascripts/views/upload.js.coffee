class PicMixr.Views.Upload extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['upload']
  
  initialize: (@opts) ->

  render: =>
    UT.p "PicMixr.Views.Upload -> render"
    $(@el).html @template(type: @opts.type)
    if @opts.type is "url"
      new PicMixr.Views.UrlUpload().render()
    else
      $("#upload-form-wrap").html JST['forms/desktop_upload']()
    @
