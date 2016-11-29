cmd={}
status={}
status.version="3.0"
tmp_tmr=0

rgb_brights={0, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64, 90, 90, 90, 90} -- 128, 181, 255}
rgb_max=cfg.lednum or 24
rgb_dim=cfg.leddim or 90
ws2812.init()
function rgbstr(s)
 local t={}
 for g,r,b in s:gmatch("(%x)(%x)(%x)") do table.insert(t,string.char(rgb_brights[tonumber(r,16)+1])..string.char(rgb_brights[tonumber(g,16)+1])..string.char(rgb_brights[tonumber(b,16)+1])) end
 return table.concat(t)
end
function rgb(s)
 ws2812.write(rgbstr(s)..string.char(0,0,0):rep(rgb_max))
end

local beep_pin=2 -- GPIO4
beep_tmr=2
function beep(freq,length,callback)
 if not freq then
  tmr.stop(beep_tmr)
  pwm.stop(beep_pin)
  gpio.mode(beep_pin,gpio.INPUT)
  return
 end
 if not length then length=100 end
 if freq > 0 then
  pwm.setup(beep_pin,freq,512)  
  pwm.start(beep_pin)  
 end
 tmr.alarm(beep_tmr, length, 0, function()
  pwm.stop(beep_pin)
  if callback then
   callback()
  else
   gpio.mode(beep_pin,gpio.INPUT)
  end
 end)
end

dofile("compile.lua")
dofile("http.lc")
--dofile("rgb.lc")
--dofile("melody.lc")
--dofile("clock.lc")
dofile("modes.lc")
dofile("cfgedit.lc")
dofile("twokeys.lc")

rgb("770070")

tmr.alarm(tmp_tmr,8000,1, function()
 local ip = wifi.sta.getip()
 local a,b,c=string.match(ip or "","%d+.%d+.%d+.(%d)(%d?)(%d?)")
 local p="700700700700"
 local n
 n=tonumber(a)
 if n ~= nil then
  local ssid, password, bssid_set, bssid = wifi.sta.getconfig()
  print("wifi connected",ssid,ip)
  p="000"..string.rep("070",n)
  n=tonumber(b)
  if n ~= nil then
   p=p.."000"..string.rep("770",n)
   n=tonumber(c)
   if n ~= nil then
    p=p.."000"..string.rep("007",n)
   end
  end
 end
 rgb(p)

 dofile("mqtt.lc")

 tmr.alarm(tmp_tmr,10000,0, function()
  collectgarbage()
  modeset("clock")
  print("heap",node.heap())
 end)

 pcall(function() dofile("user.lua") end)

end)
