local ldr_pin=5 -- GPIO14

function ldr_read(callback)
 gpio.mode(ldr_pin,gpio.OUTPUT)
 gpio.write(ldr_pin,gpio.LOW)
 tmr.alarm(0,1000,0,function()
  gpio.mode(ldr_pin,gpio.INPUT,gpio.FLOAT)
  -- =gpio.read(ldr_pin)
  local ldr_t0=tmr.now()
  gpio.trig(ldr_pin,"high",function(level)
   ldr_val=tmr.now()-ldr_t0
   if callback ~=nil then callback(ldr_val) end
   gpio.trig(ldr_pin,"none")
  end)
 end)
end

tmr.alarm(1,3000,1,function() ldr_read(print) end)
