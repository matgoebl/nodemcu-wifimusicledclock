local listURL="https://api.github.com/repos/matgoebl/nodemcu-wifimusicledclock/git/trees/master"
local dataHOST="raw.githubusercontent.com"
local dataPATH="/matgoebl/nodemcu-wifimusicledclock/master/"
local dataSSL=1

local rgb_pin=4 -- GPIO 2

tmr.alarm(0,1000,1, function()
 if(wifi.sta.getip()==nil) then
  print("waiting for wifi..")
 else
  print("wlan connected:", wifi.sta.getip())
  tmr.stop(0)
  print("get list:",listURL)
  ws2812.writergb(rgb_pin,string.char(0,0,255)..string.char(0,0,0)..string.char(0,0,255))
  http.get(listURL, nil, function(code,data)
   if (code ~= 200) then
     print("http error:",code)
   else
    print("body size:",#data)
    local content=cjson.decode(data)
    data=nil
    collectgarbage()
    if content and content.tree then
     print("files:",#content.tree)
     local filelist={}
     for n,item in ipairs(content.tree) do
      filename=item.path
      if filename:match("%lua$") or filename:match("%.html$") or filename:match("%.js$") then
       if filename~="init.lua" and filename~="config.lua" then
        table.insert(filelist,filename)
       end
      end
     end
     download_files(filelist,#filelist)
    else
     print("content error")
    end
   end
  end)
 end
end)

function download_files(filelist,count)
 local remaining=#filelist
 ws2812.writergb(rgb_pin,string.char(255,255,0):rep(count-remaining)..string.char(0,0,255):rep(remaining))
 print("count:",count-remaining,remaining)
 local filename=table.remove(filelist)
 if filename~=nil then
  tmr.alarm(0, 1000, 0, function()
   print("file:",filename)
   print("download:",dataHOST..dataPATH..filename)
   file.remove(filename)
   file.open(filename,"w")

   local sk = net.createConnection(net.TCP, dataSSL)
   local in_body = true
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
    file.write(d)
   end)
   sk:on("connection", function(sk)
    print("connected")
    sk:send("GET "..dataPATH..filename.." HTTP/1.1\r\n"..
            "Host: "..dataHOST.."\r\n"..
            "User-Agent: ESP8266\r\n"..
            "Accept: */*\r\n"..
            "Connection: close\r\n\r\n")
   print("sent")
   end)
   sk:on("disconnection", function(sk)
    print("disconnected")
    sk:close()
    file.close()
    collectgarbage()
    download_files(filelist,count)
   end)
   sk:connect(dataSSL==1 and 443 or 80, dataHOST)
  end)
 else
  node.restart()
 end
end
