function cmd.cfg(p)
 if not cfg.ssid then
  cfg.ssid,cfg.key = wifi.sta.getconfig()
 end
 for k,v in pairs(p) do
  if v == "" then v = nil end
  cfg[k] = v
 end
 if file.open("config.lua","w+") then
  file.write('cfg={\n')
   for k,v in pairs(cfg) do
    file.write(k..'="'..v..'",\n')
   end
  file.write("m=1}\n")
  file.close()
 end
 return cfg
end
