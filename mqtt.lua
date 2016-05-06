if cfg.mqhost==nil then return end

mqsub={}
local mq_tmr=4

local mqid = cfg.mqid or "esp8266_"..wifi.sta.getmac()
mqc = mqtt.Client(mqid, 60, cfg.mquser or "", cfg.mqpass or "")
status.mq_on = false

mqsub[mqid.."/rgb"]=function(m,t,d)
 modeset(nil)
 rgbset(nil,cjson.decode(d))
end
mqsub[mqid.."/play"]=function(m,t,d)
 modeset(nil)
 local p=cjson.decode(d)
 play(tonumber(p.s),tonumber(p.p),p.m,p.b)
end

mqc:lwt(mqid.."/status", "offline", 0, 1)

mqc:on("offline", function(conn)
 status.mq_on = false
 print("mqtt offline")
end)

mqc:on("message", function(m,t,d)
 print("mqtt msg:",t,d or "nil")
 if d~=nil and mqsub[t] then
  mqsub[t](m,t,d)
 end
end)

mqc:connect(cfg.mqhost, cfg.mqport and tonumber(cfg.mqport) or 1883, cfg.mqtls=="1" and 1 or 0, 1,
 function(m)
  print("mqtt connected")
  local s={}
  for t,f in pairs(mqsub) do
   s[t]=0
  end
  mqc:subscribe(s, function(m)
   status.mq_on = true
   mqc:publish(mqid.."/status", "online", 0, 1)
   print("mqtt online")
  end)
 end,
 function(m,e)
  status.mq_on = false
  print("mqtt error")
 end
)

--tmr.alarm(mq_tmr, 10000, 1, function()
-- if status.mq_on then
--  mqc:publish(mqid.."/uptime",tmr.time(),0,0)
-- end
--end)
