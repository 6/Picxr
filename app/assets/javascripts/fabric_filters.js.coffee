fabric.Image.filters.Brightness = fabric.util.createClass
  type: "Brightness"

  initialize: (options) ->
    @delta = options.delta

  applyTo: (canvasEl) ->
    context = canvasEl.getContext('2d')
    imageData = context.getImageData(0, 0, canvasEl.width, canvasEl.height)
    data = imageData.data
    console.log data[0]

    for i in [0..data.length - 1]
      #console.log i,"f",data[i],  "->", Math.min(255, Math.max(0, data[i] + @delta))
      data[i] = Math.min(255, Math.max(0, data[i] + @delta))

    context.putImageData(imageData, 0, 0)

  toJSON: ->
    {type: @type, delta: @delta}

fabric.Image.filters.Brightness.fromObject = (obj) ->
  new fabric.Image.filters.Brightness(obj)
