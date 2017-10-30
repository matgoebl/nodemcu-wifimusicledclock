table.insert(modes,3,"userservo")

function cmd.servo(p)
 local mod=modeset("userservo",true)
 return mod.cmd(p)
end
