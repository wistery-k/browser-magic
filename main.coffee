cardWidth = 81
cardHeight = 118

imgPool = {}

getImage = (str) ->
        if str of imgPool
                return imgPool[str]
        img = new Image()
        img.src = str
        imgPool[str] = img
        return img

getCardImage = (card) ->
        return getImage("http://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=" + encodeURI(card))

parseMWDeck = (str) ->
        deck = []
        lines = str.split("\n")
        for line in lines
                ix = line.indexOf("//")
                if ix != -1
                        line = line.substr(0, line.indexOf("//"))
                line = line.trim()
                if line.length == 0
                        continue
                st = line.split(" ")
                if st[0] == "SB:"
                        continue
                cardName = ""
                for i in [2..(st.length-1)]
                        if st[i][0] == "("
                                break
                        if i != 2
                                cardName += " "
                        cardName += st[i]

                for i in [1..parseInt(st[0])]
                        deck.push(cardName)
        return deck

mwdeck = """
// Deck file for Magic Workstation (http://www.magicworkstation.com)

// Lands
    1 [THS] Unknown Shores
    3 [THS] Plains (1)
    11 [THS] Forest (1)
    1 [THS] Nykthos, Shrine to Nyx

// Creatures
    1 [THS] Opaline Unicorn
    2 [THS] Staunch-Hearted Warrior
    1 [THS] Sylvan Caryatid
    2 [THS] Nylea's Disciple
    2 [THS] Voyaging Satyr
    2 [THS] Vulpine Goliath
    1 [THS] Centaur Battlemaster
    1 [THS] Chronicler of Heroes
    1 [THS] Fleecemane Lion
    1 [THS] Leafcrown Dryad
    2 [THS] Nessian Asp
    1 [THS] Nessian Courser

// Spells
    1 [THS] Time to Feed
    1 [THS] Savage Surge
    1 [THS] Traveler's Amulet
    1 [THS] Dauntless Onslaught
    1 [THS] Divine Verdict
    2 [THS] Feral Invocation

// Sideboard
SB: 1 [THS] Nylea's Presence
SB: 2 [THS] Shredding Winds
SB: 1 [THS] Fade into Antiquity
SB: 2 [THS] Commune with the Gods
SB: 1 [THS] Defend the Hearth
SB: 1 [THS] Hunt the Hunter
"""

state = {
    "hand": ["Island", "Nightveil Specter", "Domestication"],
    "field1": ["Cloudfin Raptor", "Mutavault", "Island", "Island", "Island", "Island", "Mountain", "Hall of Triumph", "Bident of Thassa"],
    "field2": ["Young Pyromancer", "Chandra's Phoenix", "Elemental", "Elemental", "Mutavault", "Mutavault", "Sacred Foundry", "Sacred Foundry", "Mountain"]
}

test = (canvas) ->
        CanvasW.init(canvas)

        CanvasW.addChild(new CanvasW.UIObject.Rect("rgb(222,222,222)",0,0,canvas.width,canvas.height))

        len = 0
        for area, cards of state
                len += cards.length

        cnt = 0
        for area, cards of state
                for card in cards
                        x = canvas.width * cnt / len #
                        y = canvas.height * cnt / len
                        ui = new CanvasW.UIObject.Image(getCardImage(card), x, y, cardWidth, cardHeight, 0)
                        ui.addEventListener("click", (self) -> self.rotation = (self.rotation + 90) % 180)
                        ui.draggable = true
                        if cnt is 0
                                ui.rotation = 90
                        CanvasW.addChild(ui)
                        cnt += 1

        cnt = new CanvasW.UIObject.Counter(0, 0, 100)
        cnt.draggable = true
        CanvasW.addChild(cnt)

        contextMenu = new CanvasW.UIObject.ContextMenu(["hoge", "moja", "テスト"], 200,300)
        CanvasW.addChild(contextMenu)

deck = null

shuffle = (deck) ->
        n = deck.length
        for i in [(n-1)..1]
                j = ~~(Math.random() * i)
                tmp = deck[i]
                deck[i] = deck[j]
                deck[j] = tmp

drawCard = ->
        if deck.length == 0
                alert("library out!!!")
                return
        card = deck.pop()
        console.log(card)
        img = new CanvasW.UIObject.Image(getCardImage(card), 200, 600, cardWidth, cardHeight, 0)
        img.draggable = true
        img.addEventListener("click", (self) -> self.rotation = (self.rotation + 90) % 180)
        CanvasW.addChild(img)

untapAll = ->
        for o in CanvasW.displayObjects # TODO! add a class Container extends UIObject.Base to deal with a group of UIObjects.
                o.rotation = 0 if o.rotation?

init = (canvas) ->
        CanvasW.init(canvas)

        deck = parseMWDeck(mwdeck)
        shuffle(deck)

        CanvasW.addChild(new CanvasW.UIObject.Rect("rgb(222,222,222)",0,0,canvas.width,canvas.height))

        deckImg = new CanvasW.UIObject.Image(getCardImage("null"), 10, 600, cardWidth, cardHeight, 0)
        deckImg.addEventListener("click", (self, x, y) -> drawCard())
        deckImg.addEventListener("rightclick", (self, x, y) ->
                contextMenu = new CanvasW.UIObject.ContextMenu(["Draw"], self.x + x + 10, self.y + y + 10)
                contextMenu.addEventListener("click", (self, index) ->
                        if index == 0
                                drawCard()
                )
                CanvasW.showContextMenu(contextMenu)
        )
        CanvasW.addChild(deckImg)

        CanvasW.addKeyListener((keycode) -> drawCard() if keycode == 68)
        CanvasW.addKeyListener((keycode) -> untapAll() if keycode == 70)

window.addEventListener("load", ->
        container = document.getElementById("container")
        canvas = document.getElementById("canvas")
        ctx = canvas.getContext("2d")

        init(canvas)

        setInterval( ->
                CanvasW.paint(canvas, ctx)
        , 33)

        console.log("デッキをクリック(D): ドロー")
        console.log("(F): アンタップ")
        console.log("カードをクリック: タップ")
        console.log("カードをドラッグ: カードを移動")
        console.log("デッキを右クリック: コンテキストメニューも出せます")
        console.log("ソースコード: https://github.com/wistery-k/browser-magic")
        
        if not ("first_time" of localStorage)
                alert("README: Ctrl+Shift+J")
                localStorage.setItem("first_time", "")
, false)