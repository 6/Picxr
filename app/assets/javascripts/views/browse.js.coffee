class PicMixr.Views.Browse extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['browse']
  
  initialize: ->
    @info = arguments[0].info
    UT.p "PicMixr.Views.Browse -> initialize", @info
    @collection.bind 'reset', @render, @
    @collection.bind 'add', @render, @
    @collection.bind 'change', @render, @
    @collection.bind 'remove', @render, @
    $(@el).html @template(info: @info)
  
  render: ->
    UT.p "PicMixr.Views.Browse -> render"
    $("#fb-photos").html("")
    @collection.each (pic) =>
      view = new PicMixr.Views.BrowseThumbnail model: pic
      @$('#fb-photos').append(view.render().el)
    @
