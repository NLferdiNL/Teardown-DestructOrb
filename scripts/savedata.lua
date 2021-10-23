#include "datascripts/keybinds.lua"

moddataPrefix = "savegame.mod.destructorb"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	maxTick = tonumber(GetString(moddataPrefix .. "MaxTick"))
	damageAlternating = GetInt(moddataPrefix .. "dAlt")
	particleAlternating = GetInt(moddataPrefix .. "pAlt")
	showAxis = GetBool(moddataPrefix.. "ShowAxis")
	
	loadKeyBinds()
	
	if saveVersion < 1 or saveVersion == nil then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		maxTick = 0.1
		SetString(moddataPrefix .. "MaxTick", maxTick .. "")
		
		damageAlternating = 0
		SetInt(moddataPrefix .. "dAlt", damageAlternating)
		
		particleAlternating = 5
		SetInt(moddataPrefix .. "pAlt", particleAlternating)
	end
	
	if saveVersion < 2 then
		saveVersion = 2
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		showAxis = true
		SetBool(moddataPrefix.. "ShowAxis", showAxis)
	end
end


function loadKeyBinds()
	for i = 1, #bindOrder do
		local currBindID = bindOrder[i]
		local boundKey = GetString(moddataPrefix .. "Keybind" .. currBindID)
		
		if boundKey == nil or boundKey == "" then
			boundKey = getFromBackup(currBindID)
		end
		
		binds[currBindID] = boundKey
	end
end

function saveKeyBinds()
	for i = 1, #bindOrder do
		local currBindID = bindOrder[i]
		local boundKey = binds[currBindID]
		
		SetString(moddataPrefix .. "Keybind" .. currBindID, boundKey)
	end
end

function saveData()
	saveKeyBinds()
	
	SetString(moddataPrefix .. "MaxTick", maxTick .. "")
	SetInt(moddataPrefix .. "dAlt", damageAlternating)
	SetInt(moddataPrefix .. "pAlt", particleAlternating)
	SetBool(moddataPrefix.. "ShowAxis", showAxis)
end