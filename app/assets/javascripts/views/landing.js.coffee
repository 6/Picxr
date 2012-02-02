class PicMixr.Views.Landing extends PicMixr.Views.BaseView
  el: '#main-wrap'
  template: JST['home']
  
  render: ->
    $(@el).html @template()
