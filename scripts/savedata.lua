#include "datascripts/keybinds.lua"

moddataPrefix = "savegame.mod.destructorb"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	maxTick = tonumber(GetString(moddataPrefix .. "MaxTick"))
	damageAlternating = GetInt(moddataPrefix .. "dAlt")
	particleAlternating = GetInt(moddataPrefix .. "pAlt")
	showAxis = GetBool(moddataPrefix.. "ShowAxis")
	breakMediumMat = GetBool(moddataPrefix.. "BreakMediumMat")
	breakHardMat = GetBool(moddataPrefix.. "BreakHardMat")
	growOnX = GetBool(moddataPrefix.. "GrowOnX")
	growOnY = GetBool(moddataPrefix.. "GrowOnY")
	growOnZ = GetBool(moddataPrefix.. "GrowOnZ")
	rimOnly = GetBool(moddataPrefix.. "RimOnly")

	
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
	
	if saveVersion < 3 then
		saveVersion = 3
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		breakMediumMat = true
		SetBool(moddataPrefix.. "BreakMediumMat", breakMediumMat)
		
		breakHardMat = true
		SetBool(moddataPrefix.. "BreakHardMat", breakHardMat)
		
		growOnX = true 
		SetBool(moddataPrefix.. "GrowOnX", growOnX)
		
		growOnY = true
		SetBool(moddataPrefix.. "GrowOnY", growOnY)
		
		growOnZ = true
		SetBool(moddataPrefix.. "GrowOnZ", growOnZ)
		
		rimOnly = true
		SetBool(moddataPrefix.. "RimOnly", rimOnly)
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
	SetBool(moddataPrefix.. "BreakMediumMat", breakMediumMat)
	SetBool(moddataPrefix.. "BreakHardMat", breakHardMat)
	SetBool(moddataPrefix.. "GrowOnX", growOnX)
	SetBool(moddataPrefix.. "GrowOnY", growOnY)
	SetBool(moddataPrefix.. "GrowOnZ", growOnZ)
	SetBool(moddataPrefix.. "RimOnly", rimOnly)
end