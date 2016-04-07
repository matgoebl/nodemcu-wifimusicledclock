beep_pin=2 -- GPIO4
beep_tmr=2

-- http://tnotes.de/NotenFrequenzen http://rechneronline.de/note/ 
tones={
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
tonecolor={
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

playco=nil
function playctrl(o,s,p,m,b)
 local r,d=coroutine.resume(o,s,p,m,b)
 if r and d then 
  tmr.alarm(beep_tmr, d, 0, function() playctrl(o,true) end)
 end
end

function play(s,p,m,b)
 if playco then
  coroutine.resume(playco,false)
 end
 if not s then return end
 playco=coroutine.create(player)
 playctrl(playco,s,p,m,b)
end

function player(s,p,m,b)
 status.playing=true
 gpio.mode(beep_pin,gpio.OUTPUT)
 local i=0
 for t,q,v in m:gmatch("([xX]?%a[vV]?)(/?)(%d*) *") do
 -- print(t,q,v)
  if v and v~="" then
   if q=="/" then
    d=s/v
   else
    d=s*v
   end
  else
   d=s
  end
  local f=tones[t]
  if not f then f=0 end
  if f > 0 then
   pwm.setup(beep_pin,f,512)  
   pwm.start(beep_pin)  
  end
  if b == "1" then
   local tc=tonecolor[t:upper()]
   local p="000"
   if tc ~= nil then
    rgbset(nil,{pattern=p:rep(i%2)..tc,ms=0})
    i=i+1
   end
  end
  if not coroutine.yield(d) then break end
  pwm.stop(beep_pin)
--  if b == "1" then
--   rgbset(nil,{pattern="000",ms=0})
--  end
  if not coroutine.yield(p) then break end
 end
 pwm.stop(beep_pin)  
 gpio.mode(beep_pin,gpio.INPUT)  
 status.playing=false
end

url_handlers["/melody"] = function(c,p)
 play(tonumber(p.s),tonumber(p.p),p.m,p.b)
 return ({})
end
