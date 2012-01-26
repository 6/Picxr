class PicMixr.Models.Picture extends Backbone.Model
  get_count: ->
    "#{@get('count')} pic#{if @get('count') > 1 then 's' else ''}"
