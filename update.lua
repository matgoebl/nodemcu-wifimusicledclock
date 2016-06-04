update_base_url=cfg.updateurl or "https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/"
updater_url=update_base_url.."updater.lua"
brg=31  -- brightness

ws2812.init()

ws2812.write(string.char(0,0,0))
ws2812.write(string.char(0,0,brg)..string.char(0,0,0)..string.char(brg,0,0)..string.char(0,0,0):rep(21))

tmr.alarm(0,1000,1, function()
 if(wifi.sta.getip()==nil) then
  print("waiting for wifi..")
 else
  print("wifi connected:", wifi.sta.getip())
  tmr.stop(0)
  print("download updater:",updater_url)
  ws2812.write(string.char(0,0,brg)..string.char(0,0,0)..string.char(0,0,brg))
  http.get(updater_url, nil, function(code,data)
   if (code ~= 200) then
     print("http error:",code)
     ws2812.write(string.char(brg,0,0)..string.char(0,0,0)..string.char(brg,0,0))
   else
    print("body size:",#data)
    pcall(loadstring(data))
   end
  end)
 end
end)
