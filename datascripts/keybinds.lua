#include "scripts/utils.lua"

binds = {
	Shoot = "usetool",
	Disable_Sphere = "r",
}

local bindBackup = deepcopy(binds)

bindOrder = {
	"Disable_Sphere",
}
		
bindNames = {
	Shoot = "Shoot",
	Disable_Sphere = "Disable Sphere",
}

function resetKeybinds()
	binds = deepcopy(bindBackup)
end

function getFromBackup(id)
	return bindBackup[id]
end