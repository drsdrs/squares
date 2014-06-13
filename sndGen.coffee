SndGen =
  t0: 0
  t1: 0
  t2: 0
  dt: 8000 / pico.samplerate

  f0: () -> 128

  mainTheme3: (t) ->(t>>5)*(((t>>8*Math.tan(t>>7))/Math.sin(t>>8))*(t>>7/Math.sin(t>>9)))/t*t>>8
  mainTheme: (t) ->  16*(Math.sin(t>>3)*((156&t>>8)%11)&(t&(t>>8)%255))&64
  mainTheme5: (t) ->  (((t&t%4096+t>>6)+((56&t>>8)%14)-(t&(t>>3)%255))&15)<<1
  landDefault: (t) -> Math.sin((t) * (Math.sin((t>>8)))&63)*50
  dangerMassive: (t) -> ((((t<<3)%255.5)&(t<<2))^((t<<1)%255.5)&(t<<1))^((((t%8000)>>10)*(t%8000)>>9))^((3399999/ ((t%16000)-4000))^(439999/((t%8000))))&255
  musikDeath: (t) -> ( (t|t%255)^t&((t%8000)-((t>>1)&t>>1)) )&127

  fx1: (t) -> (1999/t*Math.sin(t))&t>>2
  fx2: (t) -> ((9999/t*Math.sin(t>>1)*Math.cos(t<<1)))&t>>3
  fx3: (t) -> (t<<5^t<<2^t>>1)&(59999/t)
  fx4: (t) -> (99999/t)

  functCh0: "f0"
  functCh1: "f0"
  functCh2: "f0"

  fadeTo: (ch, functEnd, time) ->
    functStart = @['functCh'+ch]
    @['mix'+ch]: (t)->
      ( @fx1(t)*(0.5) + @fx2(t)*(0.5) ) / 2
    @['functCh'+ch] = @['mix'+ch]

  play: (ch, functName, time, resetT) ->
    if resetT is true then @["t"+ch] = 0
    @["functCh"+ch] = functName
    self = @
    if typeof time is "number" then window.setTimeout (-> self["functCh"+ch]="f0"), time

  process: (L, R) ->
    i = 0
    while i < L.length
      smpl = (@[@functCh0](@t0)+(@[@functCh1](@t1))+(@[@functCh2](@t2)))/3
      L[i] = R[i] = (smpl % 256) / 512 *0
      @t0 += @dt
      @t1 += @dt
      @t2 += @dt
      i++

pico.setup(
  samplerate: 44100
  cellsize: 32
)

pico.play SndGen
SndGen