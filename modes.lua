modes={"clock","timer","melody","rgb"}
mod_tmr=1

local mod=nil

function modeset(n,no_start)
 tmr.stop(mod_tmr)
 tmr.stop(tmp_tmr)
 if mod ~= nil then
  mod.stop()
  mod=nil
 end
 collectgarbage()
 if not n then return end
 if type(n) == "number" then
  status.mode = (status.mode + n + #modes) % #modes
 end
 if type(n) == "string" then
  for k,v in pairs(modes) do
   if v == n then
    status.mode = k-1
   end
  end
 end
 local newmode = modes[status.mode+1]
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
