class PicMixr.Views.UrlUpload extends Backbone.View
  el: '#main-wrap'
  template: JST['forms/url_upload']
  events:
    'click #submit-url': 'upload'
    
  render: ->
    UT.p "PicMixr.Views.UrlUpload -> render"
    $(@el).html @template()
    @
  
  upload: (e) ->
    e.preventDefault()
    url = $("#url").val()
    UT.p "PicMixr.Views.UrlUpload -> #{url}"
    UT.route_bb "edit/#{url.replace(/\./g, '@')}"
