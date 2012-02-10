$ ->
  init_bootstrap()
  $(".on-focus-highlight").mouseup ->
    $(@).focus().select()
  $(".route-default").click UT.route_default
  $(".route-bb").click (e) ->
    UT.route_bb e.target.pathname, e
  
init_bootstrap = ->
  $(".alert-message").alert()
  $(".tabs").button()
  $(".carousel").carousel()
  $(".collapse").collapse()
  $(".dropdown-toggle").dropdown()
  $(".modal").modal()
  $("a[rel=popover]").popover()
  $(".navbar").scrollspy()
  $(".tab").tab "show"
  $(".tooltip").tooltip()
  $(".typeahead").typeahead()
  $("a[rel=tooltip]").tooltip()
