class PicMixr.Views.BrowseThumbnail extends Backbone.View
  tagName: 'li'
  template: JST['browse_thumbnail']
  events:
    'click .bb-link': 'clicked'
  render: ->
    $(@el).html @template(pic: @model)
    @
  
  clicked: (e) ->
    UT.p "Clicked", @model
    UT.bb_navigate @model.get("href")
    e.preventDefault()
