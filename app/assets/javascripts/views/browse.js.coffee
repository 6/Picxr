class PicMixr.Views.Browse extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['browse']
  
  initialize: ->
    @title = arguments[0].title
    UT.p "PicMixr.Views.Browse -> initialize", @title
    @collection.bind 'reset', @render, @
    @collection.bind 'add', @render, @
    @collection.bind 'change', @render, @
    @collection.bind 'remove', @render, @
  
  render: ->
    UT.p "PicMixr.Views.Browse -> render"
    $(@el).html @template(title: @title)
    @collection.each (pic) =>
      view = new PicMixr.Views.BrowseThumbnail model: pic
      @$('#fb-photos').append(view.render().el)
    @
