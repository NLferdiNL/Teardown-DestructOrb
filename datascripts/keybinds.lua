#include "scripts/utils.lua"

binds = {
	Shoot = "usetool",
	Open_Menu = "c",
	Disable_Sphere = "r",
}

local bindBackup = deepcopy(binds)

bindOrder = {
	"Disable_Sphere",
	"Open_Menu"
}
		
bindNames = {
	Shoot = "Shoot",
	Open_Menu = "Open Menu",
	Disable_Sphere = "Disable Sphere",
}

function resetKeybinds()
	binds = deepcopy(bindBackup)
end

function getFromBackup(id)
	return bindBackup[id]
end