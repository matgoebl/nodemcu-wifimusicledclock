local rgb_preset_current=0
local rgb_presets={
 "F0080080440800800F0080480840800F0080480840800",
 "F000000000000F000000000000F000000000",
-- "F00800400200",
 "F00000000000",
 "0F0000000000",
 "00F000000000",
 "FFF000000000000000"}

local melody_preset_current=0
local melody_presets={
"A4A4A4F3c1.A4F3c1A8.e4e4e4f3c1,XG4F3c1A8.a4A3A1a4xg2g.xffxf2z2XA2xd4d2xc2.c1B1c2z2F1XG4F3A1.c4A3c1e8.a4A3A1a4xg2g,xffxf2z2XA2xd4d2xc2.cBc2z2FXG4F3c.A4F3cA8",
"E4.G3E2EA2.E2D2.E4.B3E2Ec2.B2G2.E2B2.e2ED2DBV2.XF2E2",
"C3C1D4C4F4E8.C3C1D4C4G4F8.C3C1c4A4F4E4D8.XA3XA1A4F4G4F8",
"c2A2A4XA2G2G4F2G2A2XA2c2c2c4.c2A2A4XA2G2G4F2A2c2c2F4p2.G2G2G2G2G2A2XA4A2A2A2A2A2XA2c4.c2A2A4XA2G2G4F2A2c2c2F4p2" -- Haenschen klein
}

function melodymode(n)
 if n == 1 or n == -1 then
  melody_preset_current = (melody_preset_current + n + #melody_presets) % #melody_presets
 end
 local p = melody_presets[melody_preset_current+1]
 play(125,20,p,"1")
end

function rgbmode(n)
 if n == 1 or n == -1 then
  rgb_preset_current = (rgb_preset_current + n + #rgb_presets) % #rgb_presets
 end
 local p = rgb_presets[rgb_preset_current+1]
 if n == 0 then
  rgbset({p=p.."000000000",ms=10,step=-1,fade=2})
 else
  rgbset({p=p,ms=50,step=1,rep="1"})
 end
--   rgb(nil,{p=patterns[key_mode+1].."000000000",ms=100})
--rgbx={"F00","0F0","00F","FFF","888","333","111","000"}
end

modes={clockmode,melodymode,rgbmode}

function modeset(n)
 collectgarbage()
 rgbset({p="000",ms=0,rep="1"})
 play(nil)
 clock(nil)
 collectgarbage()
 if n == nil then return end
 status.mode = (status.mode + n + #modes) % #modes
 tmr.alarm(tmp_tmr, 50, 0, function()
  modes[status.mode+1](nil)
 end)
end

function cmd.mode(p)
 if p.m then status.mode=tonumber(p.m) modeset(0) end
 if p.n then modes[status.mode+1](tonumber(p.n)) end
 return true
end
