-- Uses the https://en.wikipedia.org/wiki/Time_Protocol
-- Request: 29 bytes
-- Response: 32 bytes
-- Traffic per day: 60*24*(29+32) = 87840

--local ts = 0 -- timestamp
local tc = nil -- time connection

function nettime(cb)
 if tc ~= nil then
  tc:close()
 end
 tc = net.createConnection(net.UDP,0)
 tc:on("receive", function(tc,d)
  local ts=((d:byte(1)*256+d:byte(2))*256+d:byte(3))*256+d:byte(4) - 1208988800 - 1000000000  -- unix epoch begins 70 years later, offset value must be split because it is too big for integer type
  local tz=1 -- normal/wintertime
  -- Daylight-Saving Times 2016-2027 for Europe
  if ( ts > 1459040400 and ts < 1477789200 ) or  ( ts > 1490490000 and ts < 1509238800 ) or  ( ts > 1521939600 and ts < 1540688400 ) or
     ( ts > 1553994000 and ts < 1572138000 ) or  ( ts > 1585443600 and ts < 1603587600 ) or  ( ts > 1616893200 and ts < 1635642000 ) or
     ( ts > 1648342800 and ts < 1667091600 ) or  ( ts > 1679792400 and ts < 1698541200 ) or  ( ts > 1711846800 and ts < 1729990800 ) or
     ( ts > 1743296400 and ts < 1761440400 ) or  ( ts > 1774746000 and ts < 1792890000 ) or  ( ts > 1806195600 and ts < 1824944400 ) then
   tz=2  -- summertime
  end
  local t = (ts+tz*3600) % 86400
  local h,m,s = math.floor(t/3600),math.floor((t%3600)/60),math.floor(t%60)
  -- print("nettime:",ts,h,m,s)
  if cb ~= nil then
   cb(ts,h,m,s)
  end
  tc:close()
  tc = nil
 end)
 tc:connect(37,"192.53.103.108") -- ntp1.ptb.de
 tc:send("\n")
 -- print("nettime: request sent")
end

--function printtime(t,h,m,s)
-- print(h,m,s)
--end

--nettime(printtime)
