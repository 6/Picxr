class PicMixr.Views.Edit extends Backbone.View
  el: '#main-wrap'
  template: JST['edit']
  events:
    'click .route-bb': 'back'
  
  initialize: ->
    @pic = arguments[0].pic
    UT.p "PicMixr.Views.Edit -> initialize", @pic
  
  render: ->
    UT.p "PicMixr.Views.Edit -> render"
    size = UT.fit_dimensions(@pic.width, @pic.height, 558, 600)
    $(@el).html @template(width: size.width, height: size.height)
    $("#toolbox-wrap").html JST['toolbox']()
    @base_ctx = $("#base-image")[0].getContext('2d')
    UT.poorman_image_resize(@pic, @base_ctx, size.width, size.height)
    @

  back: (e) ->
    UT.route_bb "/", e
