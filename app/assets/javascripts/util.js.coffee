window.console = {} unless window.console?
window.console.p = (args...) -> console.log args... if window.is_dev
