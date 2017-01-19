local key_tmr=3
local key_int=50

local key1_len=0
local key2_len=0
local key1_last=0
local key1_fallback=10000
status.mode=0
status.uptime_ms=0

gpio.mode(key1_pin,gpio.INPUT,gpio.PULLUP)
gpio.mode(key2_pin,gpio.INPUT,gpio.PULLDOWN)

local wifi_max_outage=10000
local wifi_check_int=1000
local wifi_outage=0

local owtemp_int = 5000

ldr_pin=5 -- GPIO14
local ldr_t0=0
local ldr_int = 2000
local ldr_max = ldr_int * 1000

status.wifi_reconns = 0

tmr.alarm(key_tmr, key_int, 1, function()
 status.uptime_ms=status.uptime_ms+key_int

 -- MODE Key
 if gpio.read(key1_pin) == key1_on then
   key1_len = key1_len + key_int
 else
  if key1_len >= 50 and key1_len < 300 then
   beep(523) -- c
   if status.mode ~= 0 and ( status.uptime_ms - key1_last >= key1_fallback or key1_last == -1 ) then
    modeset("clock")
   else
    modeset(1)
   end
  elseif key1_len >= 300 and key1_len < 1000 then
   beep(261) -- C
   modeset(-1)
--  elseif key1_len >= 1000 and key1_len < 3000 then
--   play(250,20,"G
  elseif key1_len >= 3000 then
   beep(349,500) -- F
   node.restart()
  end
  if key1_len > 0 then
   key1_last = status.uptime_ms
  end
  key1_len=0
 end

 -- SELECT Key
 if gpio.read(key2_pin) == key2_on then
   key2_len = key2_len + key_int
 else
  if key2_len >= 50 and key2_len < 300 then
   beep(659) -- e
   modekey(1)
  elseif key2_len >= 300 and key2_len < 1000 then
   beep(329) -- E
   modekey(-1)
  elseif key2_len >= 1000 and key2_len < 3000 then
   beep(391) -- G
   modekey(0)
--  elseif key2_len >= 3000 then
--   b
  end
  if key2_len > 0  then
   key1_last = -1
  end
  key2_len=0
 end

 --- Wifi Check (should one time use callback registry and go into into own file - but new files complicate the upgrade process)
 if status.uptime_ms % wifi_check_int == 0 then
  if(wifi.sta.getip()==nil) then
   wifi_outage = wifi_outage + wifi_check_int
   if wifi_outage >= wifi_max_outage then
    status.wifi_reconns = status.wifi_reconns + 1
    dofile("wifiautoconnect.lc")
    wifi_outage = 0
   end
  else
   wifi_outage = 0
  end
 end

 if status.uptime_ms % owtemp_int == 0 then
  if status.mode == 0 then
   status.temp = dofile("owtemp.lc")
  else
   status.temp = nil
  end
 end

 if status.uptime_ms % ldr_int == 0 then
  if ldr_t0 > 0 then status.ldr=ldr_max end
  gpio.trig(ldr_pin,"none")
  gpio.mode(ldr_pin,gpio.OUTPUT)
  gpio.write(ldr_pin,gpio.LOW)
 end
 if status.uptime_ms % ldr_int == ldr_int/10 then
  gpio.mode(ldr_pin,gpio.INPUT,gpio.FLOAT)
  ldr_t0=tmr.now()
  gpio.trig(ldr_pin,"high",function(level)
   status.ldr=tmr.now()-ldr_t0
   ldr_t0=0
   gpio.trig(ldr_pin,"none")
  end)
 end

end)
