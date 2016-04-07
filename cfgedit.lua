function savecfg(k,v)
 if k then cfg[k] = v end
 if file.open("config.lua","w+") then
  file.write("cfg={")
   for k,v in pairs(cfg) do
    file.write(k..'="'..v..'",')
   end
  file.write("m=1}\n")
  file.close()
 end
 return cfg
end

url_handlers["/cfg"] = function(c,p)
 return savecfg(p.k,p.v)
end
