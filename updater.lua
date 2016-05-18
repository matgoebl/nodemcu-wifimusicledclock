update_files={'cfgedit.lua','clock.lua','compile.lua','http.lua','melody.lua','modes.lua','mqtt.lua','nettime.lua','rgb.lua','twokeys.lua','wifiautoconnect.lua','index.html','api.js','rgb.js','autostart.lua','init.lua','update.lua'}
-- normally excluded: 'config.lua','init.lua','update.lua','updater.lua'

function download_files(filelist,count)
 local remaining=#filelist
 ws2812_write(string.char(brg,brg,0):rep(count-remaining)..string.char(0,0,brg):rep(remaining))
 print("count:",count-remaining,remaining)
 local filename=table.remove(filelist,1)
 if filename~=nil then
  tmr.alarm(0, 1000, 0, function()
   print("download:",update_base_url..filename)
   http.get(update_base_url..filename, nil, function(code,data)
    if (code ~= 200) then
      print("http error:",code)
      ws2812_write(string.char(brg,brg,0):rep(count-remaining)..string.char(brg,0,0)..string.char(0,0,brg):rep(remaining-1))
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

file.remove('autostart.lua')
download_files(update_files,#update_files)
