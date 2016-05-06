local rgb_tmr=1
-- rgb_pin=1 -- GPIO 5
rgb_pin=4 -- GPIO 2
local rgb_pos=0
--rgb_max=60 -- 240
--rgb_max=300
rgb_max=24
local rgb_step=1
local rgb_pattern=string.char(0):rep(rgb_max*3)
local rgb_ms=0

-- rgb_brights={0, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64, 90, 128, 181, 255}
local rgb_brights={0, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64, 90, 90, 90, 90}

-- init pwm: setup and blank
gpio.mode(5,gpio.OUTPUT)
gpio.mode(6,gpio.OUTPUT)
gpio.mode(7,gpio.OUTPUT)
pwm.setup(5,1000,0)
pwm.setup(6,1000,0)
pwm.setup(7,1000,0)
pwm.start(5)
pwm.start(6)
pwm.start(7)

local rgb_pwm=false

-- init ws2812: blank
--ws2812.writergb(rgb_pin,string.char(0):rep(rgb_max*3))
ws2812.writergb(rgb_pin,string.char(0))

local function rgb_out()
 collectgarbage()
-- local s=tmr.now()
 ws2812.writergb(rgb_pin,string.sub(rgb_pattern:rep(2),rgb_pos+1,rgb_pos+rgb_pattern:len()))
-- status.ws_us=tmr.now()-s
-- status.ws_cnt=rgb_pattern:len()
-- status.ws_pos=rgb_pos
 if rgb_pwm then
  pwm.setduty(5,rgb_pattern:byte(rgb_pos+2)*4)
  pwm.setduty(6,rgb_pattern:byte(rgb_pos+1)*4)
  pwm.setduty(7,rgb_pattern:byte(rgb_pos+3)*4)
 end
 rgb_pos=(rgb_pos-3*rgb_step) % rgb_pattern:len()
 if rgb_ms > 0 then
  tmr.alarm(rgb_tmr, rgb_ms, 0, rgb_out)
 end
end

rgb_out()


function rgbset(c,p)
  tmr.stop(rgb_tmr)
  if p.pwm then
   rgb_pwm= p.pwm=="1"
  end
  if p.step then
   rgb_step= tonumber(p.step) or 1
  end
  if p.pattern then
   local s=tmr.now()
   local t={}
   for r,g,b in p.pattern:gmatch("(%x)(%x)(%x)") do table.insert(t,string.char(rgb_brights[tonumber(r,16)+1])..string.char(rgb_brights[tonumber(g,16)+1])..string.char(rgb_brights[tonumber(b,16)+1])) end
   p.pattern=nil
   rgb_pattern=table.concat(t)
   t=nil
   status.ws_conv=tmr.now()-s
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
  rgb_out()
  return ({})
end

url_handlers["/rgb"] = rgbset
