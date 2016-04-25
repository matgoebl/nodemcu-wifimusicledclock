update_base_url=cfg.updateurl or "https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/"
updater_url=update_base_url.."updater.lua"
rgb_pin=4  -- GPIO 2
brg=31  -- brightness

ws2812.writergb(rgb_pin,string.char(0,0,0))
ws2812.writergb(rgb_pin,string.char(0,0,brg)..string.char(0,0,0)..string.char(brg,0,0)..string.char(0,0,0):rep(21))

http={
 get=function(url,header,callback)
   collectgarbage()
   local proto,host,port,path = url:match("^([^:]+)://([^:/]+):?([0-9]*)(.*)$")
   local sk = net.createConnection(net.TCP, proto=="https" and 1 or 0)
   local data = ""
   local in_body = false
   sk:on("receive", function(sk, d)
    if not in_body then
     local p=d:find("\r\n\r\n")
     if p~=nil then
      d=d:sub(p+4)
      in_body=true
     else
      d=""
     end
    end
    print("received:",#d)
    data = data .. d
   end)
   sk:on("connection", function(sk)
    print("connected")
    sk:send("GET "..path.." HTTP/1.0\r\n"..
            "Host: "..host.."\r\n"..
            "User-Agent: ESP8266\r\n"..
            "Accept: */*\r\n"..
            "Connection: close\r\n\r\n")
    print("request sent:",path)
   end)
   sk:on("disconnection", function(sk)
    print("disconnected")
    sk:close()
    collectgarbage()
    callback(200,data)  -- ignores status code
    data = nil
    collectgarbage()
   end)
   sk:connect(port, host)
   print("connect:",host,port)
 end
}

tmr.alarm(0,1000,1, function()
 if(wifi.sta.getip()==nil) then
  print("waiting for wifi..")
 else
  print("wifi connected:", wifi.sta.getip())
  tmr.stop(0)
  print("download updater:",updater_url)
  ws2812.writergb(rgb_pin,string.char(0,0,brg)..string.char(0,0,0)..string.char(0,0,brg))
  http.get(updater_url, nil, function(code,data)
   if (code ~= 200) then
     print("http error:",code)
     ws2812.writergb(rgb_pin,string.char(brg,0,0)..string.char(0,0,0)..string.char(brg,0,0))
   else
    print("body size:",#data)
    pcall(loadstring(data))
   end
  end)
 end
end)
