# Initialize and start our game
define ['crafty'], (Crafty) ->

  scoreEl = document.getElementById("inGameScore")
  levelEl = document.getElementById("inGameLevel")

  upgradeViewEl = $("#upgradePlayer")
  upgradeBtnEl = $("#upgradeAction")

  particleOptions =
    maxParticles: 255
    size: 2
    sizeRandom: 8
    speed: 1
    speedRandom: 1
    #lifeSpan: 8
    #lifeSpanRandom: 8
    angle: 90
    angleRandom: 360
    #startColour: [ 0, 255, 0, 1 ]
    #startColourRandom: [255, 0, 0, 1]
    endColour: [ 255, 255, 255, 0 ]
    #endColourRandom: [ 32, 0, 0, 0 ]
    #spread: 8
    duration: -1
    fastMode: true
    gravity: x: -1, y: 0
    #jitter: 0

  makeParticle = (x, y, options)->
    newOptions = particleOptions
    if options? then for key, value of options then newOptions[key] = value

    Crafty.e("2D, Canvas, Particles")
      .particles(newOptions)
      .bind("EnterFrame", -> @t++; if @t>1000 then @destroy())
      .attr x:x, y:y, t:0

  addScore = (score)->
    score = score+Crafty.PlayerRock.score
    lvl = Crafty.PlayerRock.level
    lvlNew = ~~(score/500)
    if lvl isnt lvlNew then app.snd.play(1, "fx1", 500, true)
    Crafty.PlayerRock.score = scoreEl.value = score
    Crafty.PlayerRock.level = levelEl.value = lvlNew

  Crafty.c "Base",
    init: ->
      @stiff = 25
      @movX = 0
      @movY = 0
      @targetX = Crafty.viewport._width/2
      @targetY = Crafty.viewport._height/2
      @requires("2D").findTarget().origin("center")
    findTarget: -> @bind("EnterFrame", ->
      diffX= @targetX-@x-@w/2
      diffY= @targetY-@y-@w/2
      @x += diffX/@stiff
      @y += diffY/@stiff
    )

  Crafty.c "PlayerRock",
    init: ->
            #-----STATS-----#
      @score = 0
      @level = 0
      @nextLevel = 0
      @live = 100
      @maxLive = 120
      @xp = 10
      #---------------#
      @requires("Base, Collision, Mouse, Canvas, Color, Multiway")
      .bind("Click", (e)-> alert e)
      .color("#f00")
      .multiway({W: -90, S: 90, D: 0, A: 180})
      .onHit("Enemy", (e)->
          len = e.length
          while len--
            trg = e[len].obj
            @live -= 10
            trg.destroy()
            if @live<0
              @destroy()
              opts =
                duration: 1300
                liveSpan: 1300
                startColour: [255,0,0,0.6]
              makeParticle @_x, @_y, opts
      )
      .bind("EnterFrame", -> Rock.startSwarm())
      .bind "Remove", ->
        $(@._element).off()
        app.snd.play(0, "musikDeath", "InfinityTime", "noReset")
        $(Crafty.stage.elem).off()
        $(Crafty.stage.elem).children().off()


  Crafty.c "Enemy",
    init: ->
      #@colors = ["#1F8FFF","#211FFF","#FF2A1F","#FF6B1F","#E0FF1F","#41FF1F"]
      @live= 1
      @t= 0
      @speedX = 4*Math.random()+1
      @y = @Y =  Math.random()*(Crafty.viewport.height-50) + 50
      @COLOR= "#1F8FFF"
      col= @COLOR.split("#").pop()
      @colorArr= [
        parseInt(col.slice(0,2), 16)
        parseInt(col.slice(2,4), 16)
        parseInt(col.slice(4,6), 16)
        0.9
      ]
      @requires("2D, Collision, Canvas, Color")
        .origin("center")
        .color(@COLOR)
        .onHit("Bullet", (e)->
          if @live>0
            for i, trg of e
              damage = trg.obj.damage
              @live -= damage
              addScore ~~(damage*3.3)
              trg.obj.destroy() if @lvl>4
          else
            opts =
              duration: 10
              speed: 2
              liveSpan: 8
              startColour: @colorArr
              spread: @w
            makeParticle @_x, @_y, opts
            @destroy()
            app.snd.play(1, "fx3", 200, true)
        ).bind("EnterFrame", ->@moveIt())
      @moveIt= ->
        @t+=@speedX
        @w=@h = 70+Math.sin((@t)/96)*48
        @x -= @speedX+Math.sin((@t)/80)
        @y = @Y-@w/2
        if @x < -@w then @destroy() 
        #@y += 10

  Crafty.c "EnemyMad",
    init: ->
      @requires("Enemy")
      @color("#E0FF1F")
      @swingY = 100
      @w = @h = 40
      @Y= @y = (@swingY+@w)+(Crafty.viewport.height - (@swingY+@w)*2)*Math.random()
      @moveIt= ->
        @t+=@speedX
        @x -= @speedX
        add= (Math.sin(@t/60)*(@swingY))
        @y = @Y+add
        if @x < -@w then @destroy()

  Crafty.c "EnemyCircle",
    init: ->
      @requires("Enemy")
      @color("#211FFF")
      @moveIt= ->
        @t+=@speedX
        @w=@h = 70
        @x -= @speedX-Math.sin(180+(@t)/60)*5
        @y += Math.sin((@t)/60)*5
        if @x < -@w then @destroy()   

  Crafty.c "EnemyBackAttack",
    init: ->
      @requires("Enemy")
      @color("#FF2A1F")
      @moveIt= ->
        @t+=@speedX
        @w=@h = 20
        @x = @x-@speedX-((1-(@t&1023)/512)*4)
        #@y = @y+((1-(@t&1023)/512)*4)
        if @x < -@w then @destroy()

  Crafty.c "EnemySquirlyS",
    init: ->
      @requires("Enemy")
      @color("#41FF1F")
      @mH = 100
      @w=@h = 20
      @moveIt= ->
        @t+=@speedX

        @x -= 2-Math.sin(180+(@t)/60)*5
        @y += Math.sin((@t)/30)*10
        c.l Math.sin((@t)/30)*10
        if @x < -@w then @destroy() 

  Crafty.c "EnemyJumper",
    init: ->
      @requires("Enemy")
      @color("#FF6B1F")
      @moveIt= ->
        @t+=@speedX
        @w=@h = 20
        @x -= @speedX
        @y -= @speedX*((127-(@t)%255)/127)
        if @x < -@w then @destroy()  

  Crafty.c "Bullet",
    init: ->
      @speed = 10
      @vel = 1 # 1 is no speedUP 
      @stiff = 1 # 1 is no speedDown
      @requires("2D, Canvas, Color")
        .color("black")
        .bind("EnterFrame", ->
          if @_x>Crafty.viewport.width+@w then @destroy()
          @speed = @speed / @vel * @stiff
          @x += @speed
        )

  # Game scene
  # -------------
  # Runs the core gameplay loop
  Crafty.scene "Rock", ->
    @time = 0
    @PlayerRock = Crafty.e("PlayerRock")
      .attr(
        x: Crafty.viewport._width/2-25
        y: Crafty.viewport._height/2-15
        w: 50, h: 30, z: 900
      ).attach(
        Crafty.e("2D, Canvas, Particles")
         .particles(particleOptions)
         .attr x:Crafty.viewport._width/2-30, y:Crafty.viewport._height/2, w:30, h:30, z:0
      ).attach(
        Crafty.e("2D, Canvas, Color").color("#000")
         .attr x:Crafty.viewport._width/2+23, y:Crafty.viewport._height/2-10, w:20, h:20, z:999
      )


  Rock =
    makeEnemy: (lvl)->
      x = Crafty.viewport.width
      len = ~~(lvl/4+4)
      while len--
        y = Math.random()*Crafty.viewport.width 
        Crafty.e("Enemy")
          .attr
            y: y
            x: x+(1000*Math.random())
            z: 10
            targetX: -100
            targetY: Crafty.PlayerRock.y
            lvl: ~~(Math.random()*lvl/3)

    startSwarm: ()->
      Crafty.time += 1
      if Crafty.time%80==0 
        lvl = Crafty.PlayerRock.level
        #@makeEnemy(lvl)
        Crafty.e("EnemyMad")
          .attr
            x: Crafty.viewport.width+200
            z: 10

    start: ->
      Crafty.background "rgb(179, 179, 179)"
      Crafty.scene 'Rock'
      app.snd.play(0, "landDefault", false, false)

      mousePos = {x: 0, y: 0}
      bulletOnProcess = false

      player = Crafty.PlayerRock
      timerId = 0
      
      shipSpeed = 0
      shipLive = 0

      bullets = 0
      bulletSpeed = 0
      bulletInterval = 0
      bulletPower = 0

      makeBullet = (newOne)->
        if newOne isnt false then bulletOnProcess = true else bulletOnProcess = false
        pl = Crafty.PlayerRock
        size = 3*(bullets+1)
        Crafty.e("Bullet").attr
          speed: 10
          w: size, h: size
          x: pl.x+pl.w-size/2
          y: pl.y+pl.h/2-size/2
          z: 999

      shootBullet = (e, turnOff)->
        lvl = Crafty.PlayerRock.level
        if turnOff==true then window.clearInterval(timerId); timerId = -1
        else
          if timerId>0 then window.clearInterval(timerId)
          if bulletOnProcess is true then return
          bulletOnProcess = true
          makeBullet(false)
          timerId = window.setInterval (makeBullet), 600*(1-bulletInterval/10)

      mouseMove = (e)->
        mousePos = {x: e.pageX, y: e.pageY}
        player.targetX = e.pageX
        player.targetY = e.pageY
        enemys = Crafty("Enemy").get()
        len = enemys.length
        while len-- then enemys[len].targetY = e.pageY

      upgradePlayer = ->
        pl = Crafty.PlayerRock

        Crafty.pause()
        upgradeViewEl.toggle().empty()
        upgradeable = ["ship-speed", "bullets", "bullet-speed", "bullet-interval", "ship-live"]
        inputs = $("<div></div>")

        inputs.append $('<input type="button" value="ship-speed: '+shipSpeed+'" />').on("mousedown", ->
            shipSpeed += 1
            pl.xp -= 1
            pl.stiff *= 0.8
            @value="ship-speed: "+shipSpeed
        )
        inputs.append $('<input type="button" value="ship-live: '+shipLive+'" />').on("mousedown", ->
            shipLive += 1
            pl.xp -= 1
            pl.maxLive += 20
            pl.live += 20
            if pl.live > pl.maxLive then pl.live = pl.maxLive
            @value="ship-live: "+shipLive
        )
        inputs.append $('<input type="button" value="bullets: '+bullets+'" />').on("mousedown", ->
            bullets += 1
            pl.xp -= 1
            @value="bullets: "+bullets
        )
        inputs.append $('<input type="button" value="bullet-speed: '+bulletSpeed+'" />').on("mousedown", ->
            bulletSpeed += 1
            pl.xp -= 1
            @value="bullet-speed: "+bulletSpeed
        )
        inputs.append $('<input type="button" value="bullet-interval: '+bulletInterval+'" />').on("mousedown", ->
            bulletInterval += 1
            pl.xp -= 1
            @value="bullet-interval: "+bulletInterval
        )
        upgradeViewEl.append inputs
          


      upgradeBtnEl.on "mousedown", upgradePlayer

      $(Crafty.stage.elem).on "mousedown", shootBullet
      $(Crafty.stage.elem).on "mousemove", mouseMove.bind(@)
      $(Crafty.stage.elem).on "dragmove", mouseMove.bind(@)

      $(Crafty.stage.elem).on "mouseup", -> dragActive = false; shootBullet null, true

      #$(Crafty.stage.elem).on "mouseout", -> shootBullet null, true; c.l "offout"
    stop: -> null



      #player._element.addEventListener "dragstart", -> dragActive = true
