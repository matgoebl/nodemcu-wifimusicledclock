-- ======== init.lua V2.0 ========
-- Failsafe Start of WiFi and combined Telnet/HTTP Service
-- Tested on NodeMCU custom build dev on 2016-05-10 20:59 (8705b9e5)

key1_pin=3  -- GPIO0 "MODE"
key1_on=gpio.LOW
key2_pin=8  -- GPIO15 "SELECT"
key2_on=gpio.HIGH
gpio.mode(key1_pin,gpio.INPUT,gpio.PULLUP)
gpio.mode(key2_pin,gpio.INPUT,gpio.PULLDOWN)

ws2812.init()
ws2812.write(string.char(128,128,0))

cfg={}
pcall(function() dofile("config.lua") end)

-- Start telnet/http service on port 8266
print("start telnet/httpd")
--function srv()
 sv=net.createServer(net.TCP, 30)
 sv:listen(8266, function(c)
  sv_telnet=false
  sv_conn=c
  c:on("sent",function() end)
  c:on("disconnection", function(c) node.output(nil) end)
  c:on("receive", function(c,d)
   collectgarbage()
   if cfg.auth and sv_telnet == false and d:find(cfg.auth,1,true) == nil then
    c:close()
    return
   end
   if handle_http ~= nil and sv_telnet == false and d ~= nil then
    local m,u,q=d:match("^([^ ]*)[ ]+([^? ]*)\??([^ ]*)[ ]+[Hh][Tt][Tt][Pp]/")
    if m ~= nil and u ~= nil then
     d=nil
     c:on("receive",function() end)
     local r=handle_http(c,m,u,q)
     if r~=true then c:close() end
     return
    end
   end
   sv_telnet = true
   node.output(function(s) if c~=nil then c:send(s) end end, 0)
   node.input(d)
  end)
 end)
--end
--srv()

tmr.alarm(0, 1000, 0, function()
 -- Press button 2 within 1000ms for enduser setup
 if gpio.read(key2_pin) == key2_on then
  print("enduser setup")
  ws2812.write(string.char(0,0,128))
  wifi.sta.config("","")
  enduser_setup.start( function()
    print("wifi:",wifi.sta.getip(),wifi.sta.getconfig())
    file.remove('config.lua')
    node.restart()
   end, function(err,str)
    print("error:",err,str)
   end)
 else
  print("station mode")
  wifi.setmode(wifi.STATION)
  if cfg.ssid then wifi.sta.config(cfg.ssid,cfg.key) end
 end
-- Press button 1 within 1000ms to skip autostart
  if gpio.read(key1_pin) ~= key1_on and gpio.read(key2_pin) ~= key2_on then
   print("autostart")
   ws2812.write(string.char(128,0,0))
   pcall(function() dofile("autostart.lua") end)
  else
-- Hold button 1 for 6000ms total to start an remote update
   tmr.alarm(0, 5000, 0, function()
    if gpio.read(key1_pin) == key1_on then
     dofile("update.lua")
    end
   end)
  end
-- end)
end)
