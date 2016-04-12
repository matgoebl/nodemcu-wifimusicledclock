dofile("compile.lua")
dofile("handle_http_basic.lc")
dofile("rgb.lc")
dofile("melody.lc")
dofile("nettime.lc")
dofile("clock.lc")
dofile("modes.lc")
dofile("cfgedit.lc")
dofile("twokeys.lc")
modeset(0)

tmr.alarm(0,1000,1, function()
 if(wifi.sta.getip()~=nil) then
  tmr.stop(0)
  modeset(0)
  if mqtt ~= nil then
   dofile("mqtt.lc")
   tmr.alarm(0,1000,0, function()
    modeset(0)
   end)
  end
 end
end)

