class PicMixr.Views.BrowseThumbnail extends Backbone.View
  tagName: 'li'
  template: JST['browse_thumbnail']
  events:
    'click .route-bb': 'clicked'
  render: ->
    $(@el).html @template(pic: @model)
    @
  
  clicked: (e) ->
    UT.p "Clicked", @model
    UT.route_bb @model.get("href"), e
