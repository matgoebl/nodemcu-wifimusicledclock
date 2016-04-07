key_tmr=3
key_int=50
--key1_pin=3  -- GPIO0 "MODE"
--key1_on=gpio.LOW
--key2_pin=8  -- GPIO15 "SELECT"
--key2_on=gpio.HIGH

key1_len=0
key2_len=0
status.mode=0
status.uptime_ms=0

gpio.mode(key1_pin,gpio.INPUT,gpio.PULLUP)
gpio.mode(key2_pin,gpio.INPUT,gpio.PULLDOWN)

tmr.alarm(key_tmr, key_int, 1, function()
 status.uptime_ms=status.uptime_ms+key_int

 -- MODE Key
 if gpio.read(key1_pin) == key1_on then
   key1_len = key1_len + key_int
 else
  if key1_len >= 50 and key1_len < 300 then
   play(125,20,"c")
   modeset(1)
  elseif key1_len >= 300 and key1_len < 1000 then
   play(125,20,"C")
   modeset(-1)
--  elseif key1_len >= 1000 and key1_len < 3000 then
--   play(250,20,"G")
  elseif key1_len >= 3000 then
   play(500,20,"F")
   node.restart()
  end
  key1_len=0
 end

 -- SELECT Key
 if gpio.read(key2_pin) == key2_on then
   key2_len = key2_len + key_int
 else
  if key2_len >= 50 and key2_len < 300 then
   play(125,20,"e")
   modes[status.mode+1](1)
  elseif key2_len >= 300 and key2_len < 1000 then
   play(125,20,"E")
   modes[status.mode+1](-1)
  elseif key2_len >= 1000 and key2_len < 3000 then
   play(125,20,"G")
   modes[status.mode+1](0)
--  elseif key2_len >= 3000 then
--   play(125,20,"b")
  end
  key2_len=0
 end
end)

modeset(0)
