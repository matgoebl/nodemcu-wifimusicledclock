local base_url="https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/"
local update_files={'compile.lua','handle_http_basic.lua','rgb.lua','melody.lua','nettime.lua','clock.lua','modes.lua','cfgedit.lua','twokeys.lua','index.html','api.js','rgb.js','autostart.lua'}
-- excluded: 'config.lua','init.lua','update.lua','updater.lua'
local rgb_pin=4 -- GPIO 2
local brg=31 -- brightness
file.remove('autostart.lua')

function download_files(filelist,count)
 local remaining=#filelist
 ws2812.writergb(rgb_pin,string.char(brg,brg,0):rep(count-remaining)..string.char(0,0,brg):rep(remaining))
 print("count:",count-remaining,remaining)
 local filename=table.remove(filelist,1)
 if filename~=nil then
  tmr.alarm(0, 1000, 0, function()
   print("download:",base_url..filename)
   http.get(base_url..filename, nil, function(code,data)
    if (code ~= 200) then
      print("http error:",code)
      ws2812.writergb(rgb_pin,string.char(brg,brg,0):rep(count-remaining)..string.char(brg,0,0)..string.char(0,0,brg):rep(remaining-1))
    else
     print("ok,size:",#data)
     file.remove(filename)
     file.open(filename,"w")
     file.write(data)
     file.close()
     download_files(filelist,count)
    end
   end)
  end)
 else
  node.restart()
 end
end

download_files(update_files,#update_files)
