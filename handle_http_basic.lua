-- handler for http requests via init_wifi_telnethttpd.lua

-- simple registry for custom handlers by url
if not url_handlers then
 url_handlers={}
end


status={info={node.info()},chipid=node.chipid(),flashid=node.flashid(),ver="1.2"}

http_tmr=0


sendfile = function(c,f)
 local pos=0
 local run=coroutine.yield()
 while run do
  collectgarbage()
  file.open(f,"r")
  file.seek("set",pos)
  local l=file.read(256)
  file.close()
  if l==nil then c:close() return end
  pos=pos+l:len()
  c:send(l)
  l=nil
  collectgarbage()
  run=coroutine.yield()
 end
end


handle_http = function(c,m,u,p)
-- print("request for "..m.." "..u)
 collectgarbage()
 local r = nil

 if u == "/" then u="/index.html" end

 if u:match("^/%w*%.%w*$") then
  c:send("HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n")
  local o=coroutine.create(sendfile)
  c:on("sent", function(c) coroutine.resume(o,true) end)
  c:on("disconnection", function(c) coroutine.resume(o,false) o=nil end)
  coroutine.resume(o,c,u:gsub("[^.%w]",""))
  return true

 elseif u == "/status" then
--  if p.measure then
--   tmr.alarm(http_tmr, 1000, 0, function()
--    wifi.sta.disconnect();
--    tmr.alarm(http_tmr, tonumber(p.measure) or 1000, 0, function()
--     status.vdd={vdd_ms=adc.readvdd33(),uptime_s=tmr.time()}
--     wifi.sta.connect(1);
--    end)
--   end)
--  end
  status.heap_byte=node.heap()
  status.uptime_s=tmr.time()
  status.counter_us=tmr.now()
  r=status

 elseif u == "/reset" then
  tmr.alarm(http_tmr, 1000, 0, function()
   node.restart()
  end)
  r={}

 elseif url_handlers[u] then
  -- custom url handler must return table for jsonification or nil for error message
  r = url_handlers[u](c,p)
 end

 collectgarbage()
 if r then
  c:send("HTTP/1.0 200 OK\r\nContent-type: application/json\r\n\r\n"..cjson.encode(r).."\n")
 else
  c:send("HTTP/1.0 400 ERROR\r\n\r\n")
 end
end
