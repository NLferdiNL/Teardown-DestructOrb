#include "datascripts/keybinds.lua"

moddataPrefix = "savegame.mod.sphereDestroyer"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	
	binds["Disable_Sphere"] = GetString(moddataPrefix.. "DisableSphereKey")
	
	if saveVersion < 1 or saveVersion == nil then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		binds["Disable_Sphere"] = getFromBackup("Disable_Sphere")
		SetString(moddataPrefix.. "DisableSphereKey", binds["Disable_Sphere"])
	end
end

function saveKeyBinds()
	SetString(moddataPrefix.. "DisableSphereKey", binds["Disable_Sphere"])
end

function saveFloatValues()
	
end