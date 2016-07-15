cmd={}
status={}
status.version="2.1"

dofile("compile.lua")
dofile("http.lc")
dofile("rgb.lc")
dofile("melody.lc")
dofile("nettime.lc")
dofile("clock.lc")
dofile("modes.lc")
dofile("cfgedit.lc")
dofile("twokeys.lc")
--dofile("wifiautoconnect.lc")
 local wifi_tmr=6
 local wifi_int=10000
 tmr.alarm(wifi_tmr, wifi_int, 1, function()
  if(wifi.sta.getip()==nil) then
   dofile("wifiautoconnect.lc")
  end
 end)

dofile("mqtt.lc")

rgb("770070")
h1=node.heap()

tmr.alarm(0,5000,1, function()
 local ip = wifi.sta.getip()
 local a,b,c=string.match(ip or "","%d+.%d+.%d+.(%d)(%d?)(%d?)")
 local p="700700700700"
 local n
 n=tonumber(a)
 if n ~= nil then
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
 tmr.alarm(0,10000,1, function()
  collectgarbage()
  h3=node.heap()
  modeset(0)
 end)
end)
h2=node.heap()
