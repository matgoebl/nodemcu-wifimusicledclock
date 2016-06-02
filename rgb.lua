local rgb_tmr=1
local rgb_pos=0
local rgb_step=1
local rgb_ms=0
local rgb_fade=4
local rgb_pattern=string.char(0):rep(3)
rgb_max=cfg.lednum or 24
rgb_dim=cfg.leddim or 90

-- rgb_brights={0, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64, 90, 128, 181, 255}
local rgb_brights={0, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64, 90, 90, 90, 90}

ws2812.init()
rgb_buf=ws2812.newBuffer(rgb_max,3)
rgb_buf:fill(0,0,0)
rgb_buf:write()

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
  tmr.alarm(rgb_tmr, rgb_ms, 0, rgb_update)
 end
end

function rgbset(c,p)
  tmr.stop(rgb_tmr)
  if p.step then
   rgb_step= tonumber(p.step) or 1
  end
--  if p.fade then
   rgb_fade= tonumber(p.fade) or 0
--  end
  if p.pattern then
   local t={}
   for g,r,b in p.pattern:gmatch("(%x)(%x)(%x)") do table.insert(t,string.char(rgb_brights[tonumber(r,16)+1])..string.char(rgb_brights[tonumber(g,16)+1])..string.char(rgb_brights[tonumber(b,16)+1])) end
   p.pattern=nil
   rgb_pattern=table.concat(t)
   t=nil
   collectgarbage()
   if p.norepeat then
    rgb_pattern=rgb_pattern..string.char(0):rep(rgb_max*3-rgb_pattern:len())
   else
    rgb_pattern=rgb_pattern:rep(((rgb_max*3-1)/rgb_pattern:len())+1)
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

url_handlers["/rgb"] = rgbset
