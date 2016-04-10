local updater_url="https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/updater.lua"
local rgb_pin=4  -- GPIO 2
local brg=31  -- brightness

ws2812.writergb(rgb_pin,string.char(0,0,0))
ws2812.writergb(rgb_pin,string.char(0,0,brg)..string.char(0,0,0)..string.char(brg,0,0)..string.char(0,0,0):rep(21))

tmr.alarm(0,1000,1, function()
 if(wifi.sta.getip()==nil) then
  print("waiting for wifi..")
 else
  print("wifi connected:", wifi.sta.getip())
  tmr.stop(0)
  print("download updater:",updater_url)
  ws2812.writergb(rgb_pin,string.char(0,0,brg)..string.char(0,0,0)..string.char(0,0,brg))
  http.get(updater_url, nil, function(code,data)
   if (code ~= 200) then
     print("http error:",code)
     ws2812.writergb(rgb_pin,string.char(brg,0,0)..string.char(0,0,0)..string.char(brg,0,0))
   else
    print("body size:",#data)
    pcall(loadstring(data))
   end
  end)
 end
end)
