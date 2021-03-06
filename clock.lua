local M={}

local clock_int=30000
local clock_int_demo=16
local clock_warn=4*clock_int

local rgb_buf=ws2812.newBuffer(rgb_max,3)
rgb_buf:fill(0,0,0)

local show_clock=function(h,m)
 local is_night=false
 local rgb_dim=cfg.leddim_day and tonumber(cfg.leddim_day) or 90
 if cfg.leddim_threshold and status.ldr>tonumber(cfg.leddim_threshold) then
  is_night=true
  rgb_dim=cfg.leddim_night and tonumber(cfg.leddim_night) or 24
 end

 rgb_buf:fill(0,0,0)
 local hp=(math.floor(h*rgb_max/12)+rgb_max/2)%rgb_max+1
 local mp=(math.floor(m*rgb_max/60)+rgb_max/2)%rgb_max+1
 if m>=30 then hp=hp+1 end
 for i=1,rgb_max,2 do
  rgb_buf:set(i,is_night and 1 or 2,0,0)
 end
 for i=1,rgb_max,6 do
  rgb_buf:set(i,is_night and 4 or 16,0,0)
 end
 if hp == mp then
  rgb_buf:set(hp,0,rgb_dim,rgb_dim)
 else
  rgb_buf:set(hp,0,rgb_dim,0)
  rgb_buf:set(mp,0,0,rgb_dim)
 end
 ws2812.init()
 rgb_buf:write()
 gpio.mode(rgb_pin,gpio.INPUT,gpio.FLOAT)
end

local update_clock=function()
 sntp.sync(cfg.ntphost or 'ntp1.ptb.de',
  function(ts)
   local tz=1 -- normal/wintertime
   -- Daylight-Saving Times 2016-2027 for Europe
   if ( ts > 1459040400 and ts < 1477789200 ) or  ( ts > 1490490000 and ts < 1509238800 ) or  ( ts > 1521939600 and ts < 1540688400 ) or
      ( ts > 1553994000 and ts < 1572138000 ) or  ( ts > 1585443600 and ts < 1603587600 ) or  ( ts > 1616893200 and ts < 1635642000 ) or
      ( ts > 1648342800 and ts < 1667091600 ) or  ( ts > 1679792400 and ts < 1698541200 ) or  ( ts > 1711846800 and ts < 1729990800 ) or
      ( ts > 1743296400 and ts < 1761440400 ) or  ( ts > 1774746000 and ts < 1792890000 ) or  ( ts > 1806195600 and ts < 1824944400 ) then
    tz=2  -- summertime
   end
   local t = (ts+tz*3600) % 86400
   local h,m = math.floor(t/3600),math.floor((t%3600)/60)
   show_clock(h,m)
  end,
  function(errno)
   rgb("700700700700700000"..string.rep("700",errno))
  end
 )
end

function realclock()
 rgb("770770770")
 update_clock()
 tmr.alarm(mod_tmr, clock_int, 1, function()
  update_clock()
 end)
end

local demo_counter=0
function democlock()
 tmr.alarm(mod_tmr, clock_int_demo, 1, function()
  show_clock(math.floor(demo_counter/60)%24,demo_counter%60)
  demo_counter=demo_counter+1
 end)
end

function M.key(n)
 if n == 0 then
  if demo_counter == 0 then
   democlock()
  else
   demo_counter=0
   M.start()
  end
 else
  if n==-1 then n=2 end
  if cfg.trigurl then
   http.get(string.format(cfg.trigurl,n))
   rgb(string.rep("00F",n))
  end
  if status.mq_on then
   mqc:publish(mqid.."/button",n,0,0)
   rgb(string.rep("00F",n))
  end
  tmr.alarm(mod_tmr, 3000, 0, function() realclock(true) end)
 end
end

function M.cmd(p)
 return ({})
end

function M.stop()
 tmr.stop(mod_tmr)
end

function M.start()
 realclock()
end

return M
