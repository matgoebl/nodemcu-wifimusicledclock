local M={}

local timer_int=60000
local running=false
local count=cfg.timerpreset and tonumber(cfg.timerpreset) or 8

local rgb_buf=ws2812.newBuffer(rgb_max,3)
rgb_buf:fill(0,0,0)

local show_timer=function()
 rgb_buf:fill(0,0,0)
 local right=count
 local mid=rgb_max/2
 local cur
 if count > mid then
  for i=1,count-rgb_max/2 do
   rgb_buf:set(i,0,i%5==3 and 32 or 8,0)
   cur=i
  end
  right=mid
 end
 for i=mid+1, mid+right do
  rgb_buf:set(i,0,i%5==2 and 32 or 8,0)
  if count <= mid then
   cur=i
  end
 end
 if running then
  rgb_buf:set(cur,64,64,0) 
 else
  rgb_buf:set(cur,32,0,32)
 end
 rgb_buf:write()
end

local function countdown()
 count = count - 1
 if count > 0 then
  show_timer()
 else
  if timer_cb then
   if timer_cb() then return end
  end
  local i=0
  tmr.alarm(mod_tmr, 500, 1, function()
   i=i+1
   if i%2==1 then
    rgb(string.rep("700",rgb_max))
    beep(880,600)
   else
    rgb("000")
    beep(660,600)
   end
  end)
 end
end

function M.key(n)
 if count == 0 then
  running = false
  tmr.stop(mod_tmr)
 end
 if n==1 or n==-1 then
  count = count + n
 end
 if count < 1 then count = 1 end
 if count > 23 then count = 23 end
 if n == 0 then
  running = not running
  if running then
   tmr.alarm(mod_tmr, timer_int, 1, countdown)
  else
   tmr.stop(mod_tmr)
  end
 end
 show_timer()
end

function M.cmd(p)
 return ({})
end

function M.stop()
 tmr.stop(mod_tmr)
end

function M.start()
 show_timer(counter,running)
end

return M
