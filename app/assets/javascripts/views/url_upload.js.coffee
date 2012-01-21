class PicMixr.Views.UrlUpload extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['forms/url_upload']
  events:
    'click #submit-url': 'upload'
    'keypress #url': 'upload_on_enter'
    
  render: ->
    UT.p "PicMixr.Views.UrlUpload -> render"
    $(@el).html @template()
    @
  
  upload: (e) ->
    e.preventDefault()
    url = $("#url").val()
    UT.p "PicMixr.Views.UrlUpload -> #{url}"
    UT.route_bb "edit/#{encodeURIComponent(url).replace(/\./g, '@')}"
    
  upload_on_enter: (e) ->
    @upload e if e.keyCode is 13
