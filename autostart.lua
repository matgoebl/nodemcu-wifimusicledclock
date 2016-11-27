cmd={}
status={}
status.version="2.3"
tmp_tmr=0

dofile("compile.lua")
dofile("http.lc")
dofile("rgb.lc")
dofile("melody.lc")
dofile("clock.lc")
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
  modeset(0)
  print("heap",node.heap())
 end)

 pcall(function() dofile("user.lua") end)

end)
