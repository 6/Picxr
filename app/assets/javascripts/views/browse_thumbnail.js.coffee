class PicMixr.Views.BrowseThumbnail extends PicMixr.Views.BaseView
  tagName: 'li'
  template: JST['browse_thumbnail']
  events: ->
    _.extend super,
      'click .thumb-href': 'clicked'

  render: ->
    $(@el).html @template(pic: @model)
    @
  
  clicked: (e) ->
    UT.p "Clicked", @model
    UT.route_bb @model.get("href"), e
