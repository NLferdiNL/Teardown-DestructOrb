#include "scripts/utils.lua"

binds = {
	Shoot = "usetool",
	Alt_Fire = "grab",
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
	Alt_Fire = "Alt Fire",
	Open_Menu = "Open Menu",
	Disable_Sphere = "Disable Sphere",
}

function resetKeybinds()
	binds = deepcopy(bindBackup)
end

function getFromBackup(id)
	return bindBackup[id]
end