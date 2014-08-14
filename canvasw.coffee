@CanvasW or= {}

class CanvasW

        @dragging: null
        @dragOffsetX: 0
        @dragOffsetY: 0
        @mouseDownX: null
        @mouseDownY: null
        @mouseX: 0
        @mouseY: 0

        @displayObjects: []
        @contextMenu: null

        @keyListeners: []

        @addKeyListener = (f) ->
                @keyListeners.push(f)

        @addChild: (obj) ->
                @displayObjects.push(obj)

        @showContextMenu = (contextMenu) ->
                @contextMenu = contextMenu

        @paint: (canvas, ctx) ->
                ctx.clearRect(0, 0, canvas.width, canvas.height)
                for o in @displayObjects
                        if o.visible
                                o.paint(ctx, window.scrollX + @mouseX - o.x, window.scrollY + @mouseY - o.y)

                if @contextMenu?
                        @contextMenu.paint(ctx, @mouseX - @contextMenu.x, @mouseY - @contextMenu.y)

        @init: (canvas) ->
                document.oncontextmenu = (e) =>
                        e.preventDefault()
                        return false

                canvas.onmousedown = (e) =>
                       
                        ex = e.x + window.scrollX
                        ey = e.y + window.scrollY

                        if @mouseDownX? or @mouseDownY?
                                return

                        if @contextMenu?.hit(ex - @contextMenu.x, ey - @contextMenu.y)
                                return

                        @contextMenu = null
                        
                        if e.button is 0
                                @mouseDownX = ex
                                @mouseDownY = ey
                                                
                        for i in [(@displayObjects.length-1)..0]
                                o = @displayObjects[i]
                                if o.visible and o.hit(ex - o.x, ey - o.y)
                                        if e.button is 0
                                                @dragging = o
                                                @dragOffsetX = ex - o.x
                                                @dragOffsetY = ey - o.y
                                        else if e.button is 2
                                                o.onRightClick(ex - o.x, ey - o.y)
                                        break

                canvas.onmouseup = (e) =>
                        ex = e.x + window.scrollX
                        ey = e.y + window.scrollY

                        if @contextMenu?.hit(ex - @contextMenu.x, ey - @contextMenu.y)
                                @contextMenu.onClick(ex - @contextMenu.x, ey - @contextMenu.y)
                                @contextMenu = null
                                @mouseDownX = null
                                @mouseDownY = null
                                return     
                        
                        if e.button is 0
                                if @dragging?
                                        if Math.abs(@mouseDownX - ex) + Math.abs(@mouseDownY - ey) < 10
                                                @dragging.onClick(ex - @dragging.x, ey - @dragging.y)
                                                @dragging.x = @mouseDownX - @dragOffsetX
                                                @dragging.y = @mouseDownY - @dragOffsetY
                                        @dragging = null
                                @mouseDownX = null
                                @mouseDownY = null                                

                canvas.onmousemove = (e) =>

                        ex = e.x + window.scrollX
                        ey = e.y + window.scrollY
                        
                        @mouseX = ex
                        @mouseY = ey
                        if @dragging?.draggable
                                if Math.abs(@mouseDownX - ex) + Math.abs(@mouseDownY - ey) >= 10
                                        @displayObjects.splice(@displayObjects.indexOf(@dragging), 1)
                                        @displayObjects.push(@dragging)
                                @dragging.x = ex - @dragOffsetX
                                @dragging.y = ey - @dragOffsetY

                document.onkeydown = (e) =>
                        for f in @keyListeners
                                f(e.keyCode)