if cfg.mqhost==nil then return end

mqsub={}
local mq_tmr=4

mqid = cfg.mqid or "esp8266_"..wifi.sta.getmac()
mqc = mqtt.Client(mqid, 60, cfg.mquser or "", cfg.mqpass or "")
status.mq_on = false

local mqsub=mqid.."/cmd/+"

mqc:lwt(mqid.."/conn", "offline", 0, 1)

mqc:on("offline", function(conn)
 status.mq_on = false
 print("mqtt offline")
 tmr.alarm(mq_tmr, 5000, 0, mqconnect)
end)

mqc:on("message", function(m,t,d)
 print("mqtt msg:",t,d or "nil")
 local u=t:sub(#mqsub)
 local ok,p=pcall(function() return cjson.decode(d) end)
 if ok and cmd[u] then
  local r=cmd[u](p)
  if r then
   mqc:publish(mqid.."/res/"..u, cjson.encode(r), 0, 1)
  end
 end
end)

mqconnect=function()
 print("mqtt connecting to ",cfg.mqhost,":",cfg.mqport," ssl:",cfg.mqtls)
 collectgarbage()
 mqc:connect(cfg.mqhost, cfg.mqport and tonumber(cfg.mqport) or 1883, cfg.mqtls=="1" and 1 or 0, 0,
  function(m)
   print("mqtt connected")
   mqc:subscribe({[mqsub]=0}, function(m)
    print("mqtt online")
    status.mq_on = true
    mqc:publish(mqid.."/conn", "online", 0, 1)
--    mqpubstatus()
--    tmr.alarm(mq_tmr, 60000, 1, mqpubstatus)
   end)
  end,
  function(m,e)
   status.mq_on = false
   print("mqtt error "..e)
   tmr.alarm(mq_tmr, 5000, 0, mqconnect)
  end
 )
end

tmr.alarm(mq_tmr, 5000, 0, mqconnect)
