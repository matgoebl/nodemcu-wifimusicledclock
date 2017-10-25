update_files={'cfgedit.lua','clock.lua','compile.lua','http.lua','melody.lua','modes.lua',
 'owtemp.lua','mqtt.lua','rgb.lua','twokeys.lua','wifiautoconnect.lua','timer.lua',
 'index.html','api.js','rgb.js','init.lua','update.lua','autostart.lua'}
delete_files={'nettime.lc'}
-- normally excluded: 'config.lua','init.lua','update.lua','updater.lua'

function download_files(filelist,count)
 local remaining=#filelist
 ws2812.write(string.char(brg,0,0):rep(count-remaining)..string.char(0,0,brg):rep(remaining))
 print("count:",count-remaining,remaining)
 local filename=table.remove(filelist,1)
 if filename~=nil then
  tmr.alarm(0, 1000, 0, function()
   print("download:",update_base_url..filename)
   http.get(update_base_url..filename, nil, function(code,data)
    if (code ~= 200) then
      print("http error:",code)
      ws2812.write(string.char(brg,0,0):rep(count-remaining)..string.char(0,brg,0)..string.char(0,0,brg):rep(remaining-1))
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
  for i,filename in ipairs(delete_files) do
   file.remove(filename)
  end
  node.restart()
 end
end

file.open("autostart.lua","w+") file.write('dofile("update.lua")') file.close()
file.rename("user.lua","user.lua.old")
download_files(update_files,#update_files)
