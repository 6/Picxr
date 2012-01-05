window.console = {} unless window.console?
window.console.p = (args...) -> console.log args... if window.is_dev

window.redirect = (path) ->
  top.location.href = "#{window.top_href}#{path}"
