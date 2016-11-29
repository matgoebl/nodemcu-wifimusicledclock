modes={"clock","melody","rgb"}
mod_tmr=1

local mod=nil

function modeset(n,no_start)
 local newmode=nil
 tmr.stop(mod_tmr)
 if mod ~= nil then
  mod.stop()
  mod=nil
 end
 collectgarbage()
 if type(n) == "number" then
  status.mode = (status.mode + n + #modes) % #modes
  newmode = modes[status.mode+1]
 end
 if type(n) == "string" then
  for k,v in pairs(modes) do
   if v == n then
    newmode = n
   end
  end
 end
 if newmode == nil then return end
 mod=dofile(newmode..".lc")
 if not no_start then mod.start() end
end

function modekey(n)
 if mod and mod.key then
  mod.key(n)
 end
end

function cmd.mode(p)
 if p.s then modeset(p.s) end
 if p.m then modeset(tonumber(p.m)) end
 if p.n then modekey(tonumber(p.n)) end
 return true
end

function cmd.melody(p)
 modeset("melody",true)
 return mod.cmd(p)
end

function cmd.rgb(p)
 modeset("rgb",true)
 return mod.cmd(p)
end

function cmd.beep(p)
 beep(tonumber(p.f),tonumber(p.d))
 return({})
end
