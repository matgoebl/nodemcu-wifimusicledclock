if cfg.mqhost==nil then return end

mqsub={}
local mq_tmr=4

mqid = cfg.mqid or "esp8266_"..wifi.sta.getmac()
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

--local mqpubstatus=function()
-- if not status.mq_on then return end
-- status.heap=node.heap()
-- status.uptime_s=tmr.time()
-- status.counter_us=tmr.now()
-- local ssid, password, bssid_set, bssid = wifi.sta.getconfig()
-- status.wifi={ssid,bssid}
-- local ip,mask,gw = wifi.sta.getip()
-- status.ip={ip,mask,gw}
-- mqc:publish(mqid.."/status", cjson.encode(status), 0, 1)
--end

mqc:lwt(mqid.."/conn", "offline", 0, 1)

mqc:on("offline", function(conn)
 status.mq_on = false
 print("mqtt offline")
 tmr.alarm(mq_tmr, 5000, 0, mqconnect)
end)

mqc:on("message", function(m,t,d)
 print("mqtt msg:",t,d or "nil")
 if d~=nil and mqsub[t] then
  mqsub[t](m,t,d)
 end
end)

mqconnect=function()
 print("mqtt connecting to "..cfg.mqhost..":"..cfg.mqport.." ssl:"..cfg.mqtls)  
 collectgarbage()
 mqc:connect(cfg.mqhost, cfg.mqport and tonumber(cfg.mqport) or 1883, cfg.mqtls=="1" and 1 or 0, 0,
  function(m)
   print("mqtt connected")
   local s={}
   for t,f in pairs(mqsub) do
    s[t]=0
   end
   mqc:subscribe(s, function(m)
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
