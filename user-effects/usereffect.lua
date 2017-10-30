local M={}

local effect=0
local colorpreset=0
local effects=4
local col_r=64
local col_g=64
local col_b=64
local col2_r=16
local col2_g=16
local col2_b=16
local fade=2
local duration=-1
local sound="0"

local delay=30
local rgb_buf=ws2812.newBuffer(rgb_max,3)
rgb_buf:fill(0,0,0)

local effectstep=0

local function effect_update()
 collectgarbage()
 local freq=nil
 
 if effect == 0 then
  if effectstep == 0 then
   rgb_buf:fill(col_g,col_r,col_b)
  else
   rgb_buf:fade(fade)
  end
  freq=440+440*effectstep/rgb_max
  effectstep = effectstep + 1
  if effectstep > 20 then
   effectstep = 0
  end
 end

 if effect == 1 then
  if effectstep == 0 then
   rgb_buf:fill(0,0,0)
  else
   rgb_buf:fade(fade)
   rgb_buf:set(effectstep,col_g,col_r,col_b)
  end
  freq=440+440*effectstep/rgb_max
  effectstep = effectstep + 1
  if effectstep > rgb_max then
   effectstep = 0
  end
 end

 if effect == 2 then
  if effectstep == 0 then
   rgb_buf:fill(0,0,0)
  else
   rgb_buf:fade(fade)
   rgb_buf:set(effectstep,col_g,col_r,col_b)
   rgb_buf:set(rgb_max-effectstep+1,col_g,col_r,col_b)
  end
  freq=440+440*effectstep/rgb_max
  effectstep = effectstep + 1
  if effectstep > rgb_max/2 then
   effectstep = 0
  end
 end

 if effect == 3 then
  rgb_buf:fade(fade)
  if effectstep == 0 then
   rgb_buf:fill(0,0,0)
  elseif effectstep <= rgb_max/2 then
   rgb_buf:set(effectstep,col_g,col_r,col_b)
   rgb_buf:set(rgb_max-effectstep+1,col_g,col_r,col_b)
   freq=440+440*2*effectstep/rgb_max
  else
   rgb_buf:set(effectstep,col2_g,col2_r,col2_b)
   rgb_buf:set(rgb_max-effectstep+1,col2_g,col2_r,col2_b)
   freq=440+440*2*(rgb_max-effectstep)/rgb_max
  end
  effectstep = effectstep + 1
  if effectstep > rgb_max then
   effectstep = 0
  end
 end

 if effect == 4 then
  rgb_buf:fade(fade)
  if effectstep == 0 then
   rgb_buf:fill(0,0,0)
  else
   rgb_buf:set(effectstep,col_g,col_r,col_b)
   rgb_buf:set(rgb_max-effectstep+1,col_g,col_r,col_b)
   rgb_buf:set((rgb_max/4+effectstep-1) % rgb_max + 1,col_g,col_r,col_b)
   rgb_buf:set((rgb_max-rgb_max/4-effectstep) % rgb_max + 1,col_g,col_r,col_b)
  end
  effectstep = effectstep + 1
  if effectstep > rgb_max then
   effectstep = 0
  end
 end

 if sound == "1" then
  beep(freq,delay*2)
 end
 rgb_buf:write()
 if duration == 0 then
  beep(nil)
  modeset("clock")
  return
 end
 if duration > 0 then
  duration = duration - 1
 end
 if delay > 0 then
  tmr.alarm(mod_tmr, delay, 0, effect_update)
 end
end

local function starteffect(p)
  tmr.stop(mod_tmr)
  if p then
   if p.n then effect=tonumber(p.n) end
   if p.ms then delay=tonumber(p.ms) end
   if p.duration then duration=tonumber(p.duration) end
   if p.fade then fade=tonumber(p.fade) end
   if p.sound then sound=p.sound end
   if p.color and p.color:len() == 3 then
    col_r=rgb_brights[tonumber(p.color:sub(1,1),16)+1]
    col_g=rgb_brights[tonumber(p.color:sub(2,2),16)+1]
    col_b=rgb_brights[tonumber(p.color:sub(3,3),16)+1]
    if not p.color2 then p.color2=p.color end
   end
   if p.color2 and p.color2:len() == 3 then
    col2_r=rgb_brights[tonumber(p.color2:sub(1,1),16)+1]
    col2_g=rgb_brights[tonumber(p.color2:sub(2,2),16)+1]
    col2_b=rgb_brights[tonumber(p.color2:sub(3,3),16)+1]
   end
  end
  effectstep=0
  ws2812.init()
  effect_update()
  return ({})
end

function M.key(n)
 if n == 1 then
  effect = (effect + 1) % effects
 end
 if n == -1 then
  colorpreset = (colorpreset + 1) % 4
  if colorpreset == 0 then col_r,col_g,col_b,col2_r,col2_g,col2_b=64,64,64,16,16,16 end
  if colorpreset == 1 then col_r,col_g,col_b,col2_r,col2_g,col2_b=128,0,0,0,0,128 end
  if colorpreset == 2 then col_r,col_g,col_b,col2_r,col2_g,col2_b=0,128,0,128,128,0 end
  if colorpreset == 3 then col_r,col_g,col_b,col2_r,col2_g,col2_b=0,0,128,0,16,0 end
 end
 if n == 0 then
  if sound=="1" then sound="0" else sound="1" end
 end
 starteffect()
end

M.cmd = starteffect

function M.stop()
 tmr.stop(mod_tmr)
end

M.start=function()
 M.key()
end

return M
