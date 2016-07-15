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
 if s==nil then s=125 end
 if p==nil then p=20 end
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
 if not f then f=0 end  -- pause if note not found
 if f > 0 then
  pwm.setup(beep_pin,f,512)  
  pwm.start(beep_pin)  
 end
 -- print(f,d)
 if b == "1" then
  local tp=t:upper():gsub("[XV]","")
  local tn=string.find("CDEFGAB",tp)
  if tn ~= nil then
   rgb_buf:fade(2)
   for n=0,4 do
    rgb_buf:set((tn+5*n)%rgb_buf:size()+1,rgb_dim*(i%3==0 and 1 or 0),rgb_dim*(i%3==1 and 1 or 0),rgb_dim*(i%3==2 and 1 or 0))
   end
   rgb_buf:write()
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

function cmd.melody(p)
 play(tonumber(p.s),tonumber(p.p),p.m,p.b)
 return ({})
end
