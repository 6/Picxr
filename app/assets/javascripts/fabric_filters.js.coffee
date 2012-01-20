fabric.Image.filters.Brightness = fabric.util.createClass
  type: "Brightness"

  initialize: (options) ->
    @delta = options.delta

  applyTo: (canvasEl) ->
    context = canvasEl.getContext('2d')
    imageData = context.getImageData(0, 0, canvasEl.width, canvasEl.height)
    data = imageData.data

    for i in [0..data.length - 1]
      data[i] = Math.min(255, Math.max(0, data[i] + @delta))

    context.putImageData(imageData, 0, 0)

  toJSON: ->
    {type: @type, delta: @delta}

fabric.Image.filters.Brightness.fromObject = (obj) ->
  new fabric.Image.filters.Brightness(obj)
