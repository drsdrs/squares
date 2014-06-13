define (require)->
  window.c = console; window.c.l = c.log;
  app = {}
  window.app = app
  $ = require 'jquery'
  Crafty = require 'crafty'
  
  SndGen = require 'cs!./sndGen'
  app.snd = SndGen
  app.snd.functCh0 = "mainTheme"


  style = require 'less!./style/main.less'

  games =
    water: require 'cs!./games/water.coffee'
    land: require 'cs!./games/land.coffee'
    rock: require 'cs!./games/rock.coffee'

  app.games = games

  mainView = document.getElementById "mainView"
  playLvlBtn = document.getElementById "playLevel"
  exitLvlBtn = document.getElementById "exitLevel"
  inGameStats = document.getElementById "inGameStats" 
  worldEl = document.getElementById "world"
  bodyEl = document.body

  resize = ->
    w = window.innerWidth
    h = window.innerHeight
    size = if w>h then h else w
    worldEl.style.width = size*0.8+"px"
    worldEl.style.height = size*0.8+"px"

  window.onresize = resize
  resize()

  # fill with 100 boxes
  fillWorld = (length)->
    terrains = {a:["water","land","rock","gras"]}
    rndTerrain = (side)->
      terr = Math.floor(Math.random()*terrains[side].length)
      terrains[side][terr]

    container = ""
    boxPercent = 100/length
    margin = boxPercent/10
    boxPercent -= margin
    rowCnt = 0

    startLen = Math.round(length/3.4)
    diffLen = startLen
    diff = (length-startLen)/2
    while rowCnt<length
      #if rowCnt==0||rowCnt==length-1 then diffLen= length
      #else if rowCnt<(length/2) then diffLen+= 1
      #else  diffLen-= 1
      colCnt = length+1

      container += '<div class="worldRow" style="height:'+boxPercent+'%; margin: '+margin+'% 0">'
      while colCnt--
        type = rndTerrain("a")
        info = "Type: "+type+"<br> PosX: "+(length-colCnt)+"<br> PosY: "+rowCnt+"<br>"
        container+='<div stats="'+info+'" class="'+type+' box" style="width:'+boxPercent+'%; margin: 0 '+(margin/2)+'%"></div>'
        if colCnt==1 then container += '</div'
      rowCnt++
    worldEl.innerHTML = container

  fillWorld(22)


  worldPos = {}
  rotatePos = {x:0, y:0}
  rotationActive = false;

  rotateWorld = (e)->
    if rotationActive=="right"
      rotZ = (worldPos.x-e.pageX)%360
      #rotY = (worldPos.y-e.pageY)%360
      worldEl.style.webkitTransform = worldEl.style.transform =
        "rotateZ("+rotZ+"deg)"

  startRotateWorld = (e)->
    worldPos = {x:e.pageX, y:e.pageY}
    if e.button==2 then rotationActive = "right"
    else
      rotationActive = "left"
      false

  stopRotateWorld = (e)-> rotationActive = false

  makeActive = (e)->
    if $(@).hasClass("active")
      $(@).removeClass("active")
      $("#stats").removeClass("show")
    else
      $(".active").removeClass("active")
      app.activeStage = @className.split(" ")[0]
      $(@).addClass("active")
      $("#stats").addClass("show").find(".info").html($(@).attr("stats"))

  Crafty.init()
  Crafty.canvas.init()
  Crafty.pause()
  #Crafty.defineScene "square", -> null

  
  playLvl = (e)->
    if !Crafty.isPaused() then return false
    else #Crafty.init(); Crafty.canvas.init()
    Crafty.pause()
    c.l app.activeStage
    games[app.activeStage].start()
    $(mainView).slideUp(1000)
    $(inGameStats).show(1000)
    $("#cr-stage").slideDown(1000)

  exitLvl = (e)->
    app.snd.functCh0 = "mainTheme"
    if games[app.activeStage].stop? then games[app.activeStage].stop()
    if Crafty.isPaused() then return false
    #Crafty.scene("square")
    Crafty.pause()
    $(mainView).slideDown(1000)
    $(inGameStats).hide(1000)
    $("#cr-stage").slideUp(1000, -> null )

  app.activeStage = "rock"
  playLvl()

  $(".box").mousedown makeActive

  playLvlBtn.addEventListener "mousedown", playLvl
  exitLvlBtn.addEventListener "mousedown", exitLvl

  mainView.addEventListener "mousemove", rotateWorld
  mainView.addEventListener "mousedown", startRotateWorld
  mainView.addEventListener "mouseup", stopRotateWorld

