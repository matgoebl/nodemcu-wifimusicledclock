c=function()
 for f in pairs(file.list()) do
  if f:match("%.lua$") and f~="init.lua" and f~="autostart.lua" and f~="config.lua" and f~="compile.lua" and f~="updater.lua" then
   if file.open(f) then
    file.close()
     print("compile "..f)
     node.compile(f)
     file.remove(f)
     collectgarbage()
   end
  end
 end
end

c()
c=nil
collectgarbage()
