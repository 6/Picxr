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
    $(@el).html @template(info: @info, mode: @mode)
    $("#fb-photos").html JST['tween/loading']()
    if Face.finished_fetch_friends
      @show_friends()
    else
      Face.fetch_friends_cb = @show_friends
  
  render: ->
    UT.p "PicMixr.Views.Browse -> render"
    $("#fb-photos").html("")
    if @collection.length is 0
      $("#fb-photos").html JST['tween/message'](text: 'No public photos found')
    @collection.each (pic) =>
      view = new PicMixr.Views.BrowseThumbnail model: pic
      @$('#fb-photos').append(view.render().el)
    @
  
  show_friends: ->
    $.each Face.people, (uid, person) ->
      $("#friends-select").append("<option value='#{uid}'>#{person.name}</option>")
    $("#friends-select").show(0).chosen().change (e) ->
      uid = $(@).val()
      UT.p "Selected #{Face.people[uid]}"
      UT.route_bb "/albums/#{uid}"
