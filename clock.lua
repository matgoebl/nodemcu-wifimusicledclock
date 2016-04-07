clock_tmr=5
clock_int=60000

function update_clock(t,h,m,s)
 local hp=(math.floor(h*rgb_max/12)+rgb_max/2)%rgb_max
 local mp=(math.floor(m*rgb_max/60)+rgb_max/2)%rgb_max
 local p
 if hp == mp then
  p =  string.char(3,3,0):rep(hp)..string.char(255,0,255)..string.char(3,3,0):rep(rgb_max-mp-1)
 elseif hp < mp then
  p =  string.char(3,3,0):rep(hp)..string.char(255,0,0)..string.char(0,63,0):rep(mp-hp-1)..string.char(0,0,255)..string.char(3,3,0):rep(rgb_max-mp-1)
 else
  p =  string.char(0,63,0):rep(mp)..string.char(0,0,255)..string.char(3,3,0):rep(hp-mp-1)..string.char(255,0,0)..string.char(0,64,0):rep(rgb_max-hp-1)
 end
 ws2812.writergb(rgb_pin,p)
end

function clock(run)
 tmr.stop(clock_tmr)
 if run then
  nettime(update_clock)
  tmr.alarm(clock_tmr, clock_int, 1, function()
   nettime(update_clock)
  end)
 end
end
