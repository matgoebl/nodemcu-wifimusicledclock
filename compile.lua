local compileall=function()
 for f in pairs(file.list()) do
  if f:match("%.lua$") and f~="init.lua" and f~="autostart.lua" and f~="config.lua" and f~="compile.lua" and f~="update.lua" and f~="user.lua" then
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

compileall()
compileall=nil
collectgarbage()
