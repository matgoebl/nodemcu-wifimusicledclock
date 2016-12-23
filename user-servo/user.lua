table.insert(modes,"servo")

function cmd.servo(p)
 local mod=modeset("servo",true)
 return mod.cmd(p)
end
