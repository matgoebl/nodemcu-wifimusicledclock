local clock_tmr=5
local clock_int=30000
local clock_int_demo=16
local clock_warn=4*clock_int

local show_clock=function(ts,h,m,s)
 rgb_buf:fill(0,0,0)
 local hp=(math.floor(h*rgb_max/12)+rgb_max/2)%rgb_max+1
 local mp=(math.floor(m*rgb_max/60)+rgb_max/2)%rgb_max+1
 for i=1,rgb_max,2 do
  rgb_buf:set(i,2,0,0)
 end
 for i=1,rgb_max,6 do
  rgb_buf:set(i,16,0,0)
 end
 if hp == mp then
  rgb_buf:set(hp,0,rgb_dim,rgb_dim)
 else
  rgb_buf:set(hp,0,rgb_dim,0)
  rgb_buf:set(mp,0,0,rgb_dim)
 end
 rgb_buf:write()
 status.clkup=status.uptime_ms
end

function clock(run)
 tmr.stop(clock_tmr)
 if run then
  status.clkup=0
  rgbset(nil,{pattern="770770770",ms=0,norepeat="1"})
  nettime(show_clock)
  tmr.alarm(clock_tmr, clock_int, 1, function()
   if(status.clkup+clock_warn<status.uptime_ms) then
     rgbset(nil,{pattern="700700700700",ms=0,norepeat="1"})
   end
   nettime(show_clock)
  end)
 end
end

local demo_counter=0
function clockmode(n)
 if n == nil then
  clock(true)
 elseif n == 0 then
  tmr.alarm(clock_tmr, clock_int_demo, 1, function()
   show_clock(0,math.floor(demo_counter/60)%24,demo_counter%60,0)
   demo_counter=demo_counter+1
  end)
 else
  if n==-1 then n=2 end
  if cfg.trigurl then
   http.get(string.format(cfg.trigurl,n))
   rgbset(nil,{pattern=string.rep("00F",n),ms=0,norepeat="1"})
  end
  if status.mq_on then
   mqc:publish(mqid.."/button",n,0,0)
   rgbset(nil,{pattern=string.rep("00F",n),ms=0,norepeat="1"})
  end
  tmr.alarm(clock_tmr, 3000, 0, function() clock(true) end)
 end
end
