local M={}

local rgb_presets={
 "F0080080440800800F0080480840800F0080480840800",
 "F000000000000F000000000000F000000000",
-- "F00800400200",
 "F00000000000",
 "0F0000000000",
 "00F000000000",
 "FFF000000000000000"}

local rgb_preset_current=0

local rgb_pos=0
local rgb_step=1
local rgb_ms=0
local rgb_fade=4
local rgb_pattern=string.char(0):rep(3)

local rgb_buf=ws2812.newBuffer(rgb_max,3)
rgb_buf:fill(0,0,0)

local function rgb_update()
 collectgarbage()
 if rgb_fade==0 then rgb_buf:fill(0,0,0) else rgb_buf:fade(rgb_fade) end
 for i=1,#rgb_pattern,3 do
  if rgb_fade==0 or rgb_pattern:byte(i)+rgb_pattern:byte(i+1)+rgb_pattern:byte(i+2) > 0 then
   rgb_buf:set(((rgb_pos+i-1)/3)%rgb_buf:size()+1,rgb_pattern:byte(i),rgb_pattern:byte(i+1),rgb_pattern:byte(i+2))
  end
 end
 rgb_buf:write()
 rgb_pos=(rgb_pos-3*rgb_step) % rgb_pattern:len()
 if rgb_ms > 0 then
  tmr.alarm(mod_tmr, rgb_ms, 0, rgb_update)
 end
end

local function rgbset(p)
  tmr.stop(mod_tmr)
  if p.step then
   rgb_step= tonumber(p.step) or 1
  end
  rgb_fade= tonumber(p.fade) or 0
  if p.p then
   rgb_pattern=rgbstr(p.p)
   collectgarbage()
   if p.rep=="1" then
    rgb_pattern=rgb_pattern:rep(((rgb_max*3-1)/rgb_pattern:len())+1)
   else
    rgb_pattern=rgb_pattern..string.char(0):rep(rgb_max*3-rgb_pattern:len())
   end
   rgb_pos=0
  end
  if p.pos then
   rgb_pos= ( (tonumber(p.pos) or 0) * -3 ) % rgb_pattern:len()
  end
  if p.ms then
   rgb_ms=tonumber(p.ms)
  end
  rgb_update()
  return ({})
end

function M.key(n)
 if n == 1 or n == -1 then
  rgb_preset_current = (rgb_preset_current + n + #rgb_presets) % #rgb_presets
 end
 local p = rgb_presets[rgb_preset_current+1]
 if n == 0 then
  rgbset({p=p.."000000000",ms=10,step=-1,fade=2})
 else
  rgbset({p=p,ms=50,step=1,rep="1"})
 end
end

M.cmd = rgbset

function M.stop()
 tmr.stop(mod_tmr)
end

M.start=function()
 ws2812.init()
 rgb_buf:write()
 M.key()
end

return M
