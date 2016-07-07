dofile("compile.lua")
dofile("http.lc")
dofile("rgb.lc")
dofile("melody.lc")
dofile("nettime.lc")
dofile("clock.lc")
dofile("modes.lc")
dofile("cfgedit.lc")
dofile("twokeys.lc")
dofile("wifiautoconnect.lc")
dofile("mqtt.lc")

rgbset(nil,{p="770070",ms=0})

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
 rgbset(nil,{p=p,ms=0})
 tmr.alarm(0,10000,1, function()
  modeset(0)
 end)
end)
