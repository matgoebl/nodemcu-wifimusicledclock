cmd={}
status={}
status.version="2.2"

dofile("compile.lua")
dofile("http.lc")
dofile("rgb.lc")
dofile("melody.lc")
dofile("clock.lc")
dofile("modes.lc")
dofile("cfgedit.lc")
dofile("twokeys.lc")

rgb("770070")

tmr.alarm(0,8000,1, function()
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

 local wifi_tmr=6
 local wifi_int=10000
 tmr.alarm(wifi_tmr, wifi_int, 1, function()
  if(wifi.sta.getip()==nil) then
   dofile("wifiautoconnect.lc")
  end
  if status.mode == 0 then
   status.temp = dofile("owtemp.lc")
  else
   status.temp = nil
  end
 end)

 tmr.alarm(0,10000,1, function()
  collectgarbage()
  modeset(0)
 end)

 pcall(function() dofile("user.lua") end)

end)
