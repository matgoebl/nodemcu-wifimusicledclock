local clock_tmr=5
local clock_int=60000
local clock_int_demo=50
local clock_warn=4*clock_int

local show_clock=function(ts,h,m,s)
 local hp=(math.floor(h*rgb_max/12)+rgb_max/2)%rgb_max
 local mp=(math.floor(m*rgb_max/60)+rgb_max/2)%rgb_max
 local p
 if hp == mp then
  p =  string.char(3,3,0):rep(hp)..string.char(rgb_dim,0,rgb_dim)..string.char(3,3,0):rep(rgb_max-mp-1)
 elseif hp < mp then
  p =  string.char(3,3,0):rep(hp)..string.char(rgb_dim,0,0)..string.char(0,63,0):rep(mp-hp-1)..string.char(0,0,rgb_dim)..string.char(3,3,0):rep(rgb_max-mp-1)
 else
  p =  string.char(0,63,0):rep(mp)..string.char(0,0,rgb_dim)..string.char(3,3,0):rep(hp-mp-1)..string.char(rgb_dim,0,0)..string.char(0,64,0):rep(rgb_max-hp-1)
 end
 ws2812.writergb(rgb_pin,p)
 p=nil
 collectgarbage()
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
     rgbset(nil,{pattern="700700",ms=0,norepeat="1"})
   end
   nettime(show_clock)
  end)
 end
end

local demo_counter=0
function clockmode(n)
 if n == nil or n == -1 then
  clock(true)
 elseif n == 1 then
  tmr.alarm(clock_tmr, clock_int_demo, 1, function()
   show_clock(0,math.floor(demo_counter/60)%24,demo_counter%60,0)
   demo_counter=demo_counter+1
  end)
 end
end
