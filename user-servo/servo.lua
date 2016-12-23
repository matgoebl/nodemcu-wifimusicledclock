local M={}

local servo_pin=7 -- GPIO13
local servo_down=false

-- These positions must be adapted to your hardware design and servo model
local servo_downpos=65
local servo_uppos=95
local servo_maxpos=127
local servo_minpos=31

local function servo(p,servo_fast)
 local pos
 beep(false)
 if type(p) == "table" then
  pos=tonumber(p.p)
  servo_fast=p.f
 else
  if p then
   pos=servo_downpos
   timer_cb = function()
    servo(false)
    tmr.alarm(mod_tmr, 1500, 0, function()
     if mod.alarm then mod.alarm() end
    end)
    return true
   end
  else
   pos=servo_uppos
   timer_cb=nil
  end
 end
 if servo_fast==true and pos ~= nil and pos >= 20 and pos <= 130 then
  pwm.setup(servo_pin,50,pos)
  pwm.start(servo_pin)
  tmr.alarm(tmp_tmr, 1000, 0, function()
   pwm.stop(servo_pin)
  end)
  status.servo_pos=pos
  status.servo_down=servo_down
 else
  if not status.servo_pos then status.servo_pos=servo_uppos end
  status.servo_down=servo_down
  pwm.setup(servo_pin,50,status.servo_pos)
  pwm.start(servo_pin)
  tmr.alarm(tmp_tmr, 50, 1, function()
   if pos > status.servo_pos then
    status.servo_pos = status.servo_pos + 1
   elseif pos < status.servo_pos then
    status.servo_pos = status.servo_pos - 1
   end
   pwm.setduty(servo_pin,status.servo_pos)
   if pos == status.servo_pos then
    pwm.stop(servo_pin)
    tmr.stop(tmp_tmr)
   end
  end)
 end
 return ({})
end

function M.key(n)
 if n == nil then
  servo(false)
  servo_down=false
 elseif n == 1 then
  servo_down = not servo_down
  servo(servo_down)
 elseif n == -1 then
  servo({p=servo_maxpos,f=true})
 elseif n == 0 then
  servo({p=servo_minpos,f=true})
 end
end

function M.stop()
 tmr.stop(tmp_tmr)
 pwm.stop(servo_pin)
end

M.cmd=servo
M.start=M.key

return M
