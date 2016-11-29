local M={}

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

local presets={
"A4A4A4F3c1.A4F3c1A8.e4e4e4f3c1,XG4F3c1A8.a4A3A1a4xg2g.xffxf2z2XA2xd4d2xc2.c1B1c2z2F1XG4F3A1.c4A3c1e8.a4A3A1a4xg2g,xffxf2z2XA2xd4d2xc2.cBc2z2FXG4F3c.A4F3cA8",
"E4.G3E2EA2.E2D2.E4.B3E2Ec2.B2G2.E2B2.e2ED2DBV2.XF2E2",
"C3C1D4C4F4E8.C3C1D4C4G4F8.C3C1c4A4F4E4D8.XA3XA1A4F4G4F8",
"c2A2A4XA2G2G4F2G2A2XA2c2c2c4.c2A2A4XA2G2G4F2A2c2c2F4p2.G2G2G2G2G2A2XA4A2A2A2A2A2XA2c4.c2A2A4XA2G2G4F2A2c2c2F4p2" -- Haenschen klein
}
local preset=0

local rgb_buf=ws2812.newBuffer(rgb_max,3)
rgb_buf:fill(0,0,0)
rgb_buf:write()

local function play(s,p,m,b,i,o)
 -- s: tone length  p: inter-tone pause  m: music string in abc format  b: visualize tones with rgb leds
 if i == nil then  -- init
  i=1  -- tone number, for blinking
  o=1  -- offset within music string
 end
 if s==nil then s=125 end
 if p==nil then p=20 end
 if m==nil then m="" end
 local t,q,v,z=m:match("^([xX]?%a[vV]?)(/?)(%d*)([^a-zA-Z0-9]*)",o)
 if t == nil then  -- end of melody
  beep(nil)
  if tonumber(cfg.returnmain) then
   tmr.alarm(beep_tmr,tonumber(cfg.returnmain),0, function()
    modeset("clock")
   end)
  end
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
 beep(f,d, function()
   tmr.alarm(beep_tmr, p, 0, function()
    play(s,p,m,b,i,o)
   end)
 end)
end

function M.cmd(p)
 play(tonumber(p.s),tonumber(p.p),p.m,p.b)
 return ({})
end

function M.key(n)
 if n == 1 or n == -1 or n == 0 then
  preset = (preset + n + #presets) % #presets
 end
 local p = presets[preset+1]
 play(125,20,p,"1")
end

function M.stop()
 beep(nil)
end

M.start=M.key

return M
