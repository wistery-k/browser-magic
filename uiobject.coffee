@CanvasW or= {}
@CanvasW.UIObject or= {}

class CanvasW.UIObject.Base
        constructor: ->
                @listenerFunction = {}
                @draggable = false
                @visible = true
        
        addEventListener: (eventName, f) ->
                if eventName of @listenerFunction
                        @listenerFunction[eventName].push(f)
                else
                        @listenerFunction[eventName] = [f]

        onClick: (x, y) ->
                if "click" of @listenerFunction
                        for f in @listenerFunction["click"]
                                f(@, x, y)

        onRightClick: (x, y) ->
                if "rightclick" of @listenerFunction
                        for f in @listenerFunction["rightclick"]
                                f(@, x, y)


class CanvasW.UIObject.Rect extends CanvasW.UIObject.Base
        constructor: (@color, @x, @y, @width, @height) ->
                super()

        paint: (ctx, mouseX, mouseY) ->
                ctx.fillStyle = @color
                ctx.fillRect(@x, @y, @width, @height)

        hit: (x, y) ->
                return x >= 0 and y >= 0 and x < @width and y < @height

class CanvasW.UIObject.Image extends CanvasW.UIObject.Base
        constructor: (@img, @x, @y, @width, @height, @rotation = 0) ->
                super()
        
        paint: (ctx, mouseX, mouseY) ->
                ctx.save()
                centerX = @x + @width / 2 #
                centerY = @y + @height / 2
                ctx.translate(centerX, centerY)
                ctx.rotate(@rotation * Math.PI / 180)
                ctx.drawImage(@img, -@width/2, -@height/2, @width, @height);
                ctx.restore()

        hit: (x, y) ->
                theta = @rotation * Math.PI / 180
                centerX = @width / 2
                centerY = @height / 2
                x1 = x - centerX
                y1 = y - centerY
                x2 = Math.cos(-theta) * x1 - Math.sin(-theta) * y1
                y2 = Math.sin(-theta) * x1 + Math.cos(-theta) * y1
                x3 = x2 + centerX
                y3 = y2 + centerY
                return x3 >= 0 && y3 >= 0 && x3 < @width && y3 < @height

class CanvasW.UIObject.Counter extends CanvasW.UIObject.Base
        constructor: (@count, @x, @y) ->
                super()
                
        paint: (ctx, mouseX, mouseY) ->
                ctx.fillStyle = "rgba(255,255,255,128)"
                ctx.fillRect(@x, @y, 50, 30)
                ctx.fillStyle = "black"
                ctx.font = "32px sans-serif"
                ctx.fillText(String(@count), @x + 15, @y + 26)

                ctx.beginPath()
                ctx.moveTo(@x + 40, @y + 10)
                ctx.lineTo(@x + 50, @y + 10)
                ctx.lineTo(@x + 45, @y)
                ctx.closePath()
                ctx.fill()
                
                ctx.beginPath()
                ctx.moveTo(@x + 40, @y + 20)
                ctx.lineTo(@x + 50, @y + 20)
                ctx.lineTo(@x + 45, @y + 30)
                ctx.closePath()
                ctx.fill()

        hit: (x, y) ->
                console.log(x)
                console.log(y)
                console.log(x >= 0 and y >= 0 and x < 50 and y < 30)
                return x >= 0 and y >= 0 and x < 50 and y < 30

        onClick: (x, y) ->
                if x >= 40
                        if y < 15
                                @count += 1
                        else
                                @count -= 1
                else
                        super(x, y)

class CanvasW.UIObject.ContextMenu extends CanvasW.UIObject.Base
        constructor: (@menuList, @x, @y) ->
                super()

        paint: (ctx, mouseX, mouseY) ->
                ctx.strokeStyle = "rgb(128,128,128)"
                ctx.fillStyle = "rgb(240,240,240)"

                ctx.shadowBlur = 4
                ctx.shadowColor = "gray"
                ctx.shadowOffsetX = 4
                ctx.shadowOffsetY = 4

                ctx.strokeRect(@x, @y, 180, 200)
                ctx.fillRect(@x, @y, 180, 200)

                ctx.shadowBlur = 0
                ctx.shadowOffsetX = 0
                ctx.shadowOffsetY = 0

                ctx.font = "24px MS UI Gothic"

                hoverIndex = -1
                if mouseX >= 0 and mouseX < 180
                        hoverIndex = ~~(mouseY / 28)

                if hoverIndex >= 0 and hoverIndex < @menuList.length
                        ctx.fillStyle = "rgb(39,23,88)"
                        ctx.fillRect(@x, @y + hoverIndex * 28, 180, 28)

                for s, i in @menuList
                        ctx.fillStyle = if (i is hoverIndex) then "white" else "black"
                        ctx.fillText(s, @x + 15, @y + 20 + i * 28)

                        ctx.beginPath()
                        ctx.moveTo(@x + 5, @y + 26 + i * 28)
                        ctx.lineTo(@x  + 175, @y + 26 + i * 28)
                        ctx.stroke()

        hit: (x, y) ->
                return x >= 0 && y >= 0 && x < 180 && y < 200

        onClick: (x, y) ->
                if "click" of @listenerFunction
                        for f in @listenerFunction["click"]
                                f(@, ~~(y / 28))

        onRightClick: (x, y) ->
                if "rightclick" of @listenerFunction
                        for f in @listenerFunction["rightclick"]
                                f(@, ~~(y / 28))