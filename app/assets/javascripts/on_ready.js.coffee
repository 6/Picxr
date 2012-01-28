$ ->
  init_bootstrap()
  $(".on-focus-highlight").mouseup ->
    $(@).focus().select()
  $(".route-default").click UT.route_default
  $(".route-bb").click (e) ->
    UT.route_bb e.target.pathname, e
  
init_bootstrap = ->
  $("body > .topbar").scrollSpy()
  $(".tabs").tabs()
  $("a[rel=twipsy]").twipsy live: true
  $("a[rel=popover]").popover offset: 10
  $(".topbar-wrapper").dropdown()
  $(".alert-message").alert()
  domModal = $(".modal").modal(
    backdrop: true
    closeOnEscape: true
  )
  $(".open-modal").click ->
    domModal.toggle()
