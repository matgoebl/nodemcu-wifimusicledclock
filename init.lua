-- ======== init.lua V1.2 ========
-- Failsafe Start of WiFi and combined Telnet/HTTP Service
-- Tested on NodeMCU 0.9.6 build 20150704
-- and on NodeMCU 1.5.1 build 20160121 powered by Lua 5.1.4 on SDK 1.5.1(e67da894)

-- Press button while power-on to boot into UART downloader mode
--button_pin=3  -- GPIO0, button to GND
--button2_pin=8  -- GPIO15, button to Vss
key1_pin=3  -- GPIO0 "MODE"
key1_on=gpio.LOW
key2_pin=8  -- GPIO15 "SELECT"
key2_on=gpio.HIGH
gpio.mode(key1_pin,gpio.INPUT,gpio.PULLUP)
gpio.mode(key2_pin,gpio.INPUT,gpio.PULLDOWN)

led_pin=4     -- GPIO2, led to Vss

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

-- Led on for 1000ms
gpio.mode(led_pin,gpio.OUTPUT)
gpio.write(led_pin,gpio.LOW)

tmr.alarm(0, 1000, 0, function()
 -- Press button for standalone ap mode (WIFI AP, DHCP, telnet running, wifi key from config.lua or open)
 gpio.mode(led_pin,gpio.INPUT,gpio.FLOAT)
 if gpio.read(key2_pin) == key2_on then
  print("start enduser setup")
  ws2812.init()
  ws2812.write(string.char(0,0,128))
  wifi.sta.config("","")
  enduser_setup.start( function()
    print("Connected to wifi as:" .. wifi.sta.getip())
   end, function(err,str)
    print("enduser setup error " .. err .. ": " .. str)
   end)
 else
  print("start station mode")
  wifi.setmode(wifi.STATION)
  if cfg.ssid then wifi.sta.config(cfg.ssid,cfg.key) end
 end
-- -- Press button within another 500ms to skip autostart
-- tmr.alarm(0, 500, 0, function()
  if gpio.read(key1_pin) ~= key1_on and gpio.read(key2_pin) ~= key2_on then
   print("start autostart")
   pcall(function() dofile("autostart.lua") end)
  else
   tmr.alarm(0, 5000, 0, function()
    if gpio.read(key1_pin) == key1_on then
     dofile("update.lua")
    end
   end)
  end
-- end)
end)
