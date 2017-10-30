table.insert(modes,"usereffect")

function cmd.effect(p)
 local mod=modeset("usereffect",true)
 return mod.cmd(p)
end
