class PicMixr.Views.Browse extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['browse']
  
  initialize: ->
    @info = arguments[0].info
    @mode = arguments[0].mode
    UT.p "PicMixr.Views.Browse -> initialize", @info
    @collection.bind 'reset', @render, @
    @collection.bind 'change', @render, @
    @collection.bind 'remove', @render, @
    $(@el).html @template()
    $("#pics").html JST['tween/loading']()
  
  render: ->
    UT.p "PicMixr.Views.Browse -> render"
    $("#pics").html("")
    if @collection.length is 0
      $("#pics").html JST['tween/message'](text: 'No photos found')
    @collection.each (pic) =>
      view = new PicMixr.Views.BrowseThumbnail model: pic
      @$('#pics').append(view.render().el)
    @
