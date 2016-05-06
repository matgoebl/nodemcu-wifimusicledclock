local beep_pin=2 -- GPIO4
local beep_tmr=2

-- http://tnotes.de/NotenFrequenzen http://rechneronline.de/note/ 
local tones={
  BV= 246,
  C = 261,
 XC = 277,
  D = 294,
 XD = 311,
  E = 329,
  F = 349,
 XF = 369,
  G = 391,
 XG = 415,
  A = 440,
 XA = 466,
  B = 493,
  c = 523,
 xc = 554,
  d = 587,
 xd = 622,
  e = 659,
  f = 698,
 xf = 740,
  g = 784,
 xg = 830,
  a = 880,
 xa = 932,
  b = 987,
  z = 0
}

-- "F00","0F0","00F","FFF","888","333","111","000"
local tonecolor={
  BV= "F08000003000000",
  C = "F00000FF0000000",
 XC = "F0000FFF0000000",
  D = "F0F0000F0D00000",
 XD = "F0F00F0F0FF0000",
  E = "000F00000FF0000",
  F = "0000F0000F0D000",
 XF = "000F0F00F0F0FF0",
  G = "000000F00000FF0",
 XG = "000000F0000FFF0",
  A = "00000D000FF0D0D",
 XA = "00000D00F000D0D",
  B = "FF00F000000F000",
  Z = "000000000000000",
}


function play(s,p,m,b,i,o)
 -- s: tone length  p: inter-tone pause  m: music string in abc format  b: visualize tones with rgb leds
 tmr.stop(beep_tmr)
 status.playing=true
 if i == nil then  -- init
  gpio.mode(beep_pin,gpio.OUTPUT)
  i=1  -- tone number, for blinking
  o=1  -- offset within music string
 else
  pwm.stop(beep_pin)
 end
 if m==nil then m="" end
 local t,q,v,z=m:match("^([xX]?%a[vV]?)(/?)(%d*)([^a-zA-Z0-9]*)",o)
 if t == nil then  -- end of melody
  pwm.stop(beep_pin)  
  gpio.mode(beep_pin,gpio.INPUT)  
  status.playing=false
  return
 end
 -- print(t,q,v)
 local d=s
 if v and v~="" then
  if q=="/" then
   d=s/v
  else
   d=s*v
  end
 end
 local f=tones[t]
 if not f then f=0 end
 if f > 0 then
  pwm.setup(beep_pin,f,512)  
  pwm.start(beep_pin)  
 end
 -- print(f,d)
 if b == "1" then
  local tc=tonecolor[t:upper()]
  local p="000"
  if tc ~= nil then
   rgbset(nil,{pattern=p:rep(i%2)..tc,ms=0})
   i=i+1
  end
 end
 o=o+#t+#q+#v+#z
 tmr.alarm(beep_tmr, d, 0, function()
  pwm.stop(beep_pin)
  tmr.alarm(beep_tmr, p, 0, function()
   play(s,p,m,b,i,o)
  end)
 end)
end

url_handlers["/melody"] = function(c,p)
 play(tonumber(p.s),tonumber(p.p),p.m,p.b)
 return ({})
end
