#include "scripts/utils.lua"
#include "scripts/savedata.lua"
#include "scripts/menu.lua"
#include "datascripts/keybinds.lua"
#include "datascripts/inputList.lua"

toolName = "destructorb"
toolReadableName = "DestructOrb"

local menu_disabled = false

local sphereActive = false
local spherePos = Vec()

local sphereRadius = 0.1

maxTick = 0.1
local currTick = maxTick

local singleUnit = 1000 / 5
local damageUnit = 0.5
local num_pts = singleUnit * sphereRadius

breakMediumMat = true
breakHardMat = true

growOnX = true
growOnY = true
growOnZ = true
rimOnly = true

local firstHitDone = false

function init()
	saveFileInit()
	menu_init()
	
	RegisterTool(toolName, toolReadableName, "MOD/vox/molotov.vox")
	SetBool("game.tool." .. toolName .. ".enabled", true)
	--SetFloat("game.tool." .. toolName .. ".ammo", 100)
end

function tick(dt)
	if not menu_disabled then
		menu_tick(dt)
	end
	
	--DebugWatch("nu", num_pts)
	
	local isMenuOpenRightNow = isMenuOpen()
	
	if sphereActive then
		sphereLogic()
		currTick = currTick - dt
		
		if currTick <= 0 then
			currTick = maxTick
			updateSphere(0.05)
		end
		
		if InputPressed(binds["Disable_Sphere"]) then
			resetSphere()
		end
	end
	
	if GetString("game.player.tool") ~= toolName or GetPlayerVehicle() ~= 0 or isMenuOpenRightNow then
		return
	end
	
	if InputPressed(binds["Shoot"]) then
		shootLogic()
	end
end

function draw(dt)
	menu_draw(dt)
	
	if sphereActive then
		UiPush()
			UiAlign("top left")
			UiFont("regular.ttf", 26)
			UiTranslate(20, 20)
			UiTextShadow(0, 0, 0, 0.5, 2.0)
			UiText("Destruction sphere active.\n[" .. binds["Disable_Sphere"]:upper() .. "] to disable.")
		UiPop()
	end
end

-- UI Functions (excludes sound specific functions)
-- Creation Functions

-- Object handlers

-- Tool Functions

function resetSphere()
	sphereActive = false
	sphereRadius = 0.1
	num_pts = singleUnit * sphereRadius
	firstHitDone = false
end

function updateSphere(radius)
	sphereRadius = sphereRadius + radius
	num_pts = singleUnit * sphereRadius
	firstHitDone = false
end

function shootLogic()
	local cameraTransform = GetPlayerCameraTransform()
	local origin = cameraTransform.pos
	local direction = TransformToParentVec(cameraTransform, Vec(0, 0, -1))
	
	local hit, hitPoint, normal = raycast(origin, direction)
	
	if not hit then
		return
	end
	
	--local offsetHit = VecAdd(hitPoint, VecScale(normal, 5))
	
	spherePos = hitPoint
	sphereActive = true
end

function sphereLogic()
	fibonacci_sphere(num_pts, spherePos, sphereRadius)
	--[[for i = 1, num_pts do
		local offsetI = (i - sphereLayers / 2)
		local currentSphereRadius =  math.abs(sphereRadius / 100 * offsetI * 100)
		local sphereHeight = VecAdd(spherePos, Vec(0, offsetI * layerHeight, 0))
		
		local offsetI = i - sphereLayers / 2
		local currentSphereRadius = sphereRadius / sphereLayers * math.abs(offsetI)
		local sphereHeight = VecAdd(spherePos, Vec(0, offsetI * layerHeight, 0))
		for j = 1, spherePoints do
			local point = posAroundCircle(j, spherePoints, sphereHeight, currentSphereRadius)
			ParticleReset()
			ParticleCollide(0)
			SpawnParticle(point, Vec(), 1)
		end
		
		local currPos = VecAdd(spherePos, test(i))
		ParticleReset()
		ParticleCollide(0)
		SpawnParticle(currPos, Vec(), 1)
	end]]--
end

function test(indices)
--local indices =  -- All floats from 0 to num_pts inclusively (for loop perhaps where i = float)

	local phi = math.acos(1 - 2*indices/num_pts)
	local theta = math.pi * (1 + 5*0.5) * indices

	local x, y, z = math.cos(theta) * math.sin(phi), math.sin(theta) * math.sin(phi), math.cos(phi)
	
	return {x, y, z}
end

-- Really wish I understood this math :(
function fibonacci_sphere(samples, offsetPos, radius)
	local rnd = 1.0 * samples

	local  offset = 2/samples
	local  increment = math.pi * (3. - math.sqrt(5))
	
	local alternating = 5

	for i = 1, samples do
		y = ((i * offset) - 1) + (offset / 2);
		r = math.sqrt(1 - math.pow(y,2))

		phi = ((i + rnd) % samples) * increment

		x = math.cos(phi) * r
		z = math.sin(phi) * r
		
		if growOnX then
			x = x * radius
		else
			x = 0
		end
		
		if growOnY then
			y = y * radius
		else
			y = 0
		end
		
		if growOnZ then
			z = z * radius
		else
			z = 0
		end
		
		local currPos = VecAdd(Vec(x, y, z), offsetPos)
		
		if alternating > 5 then
			alternating = 0
			spawnParticleAt(currPos)
		end
		
		alternating = alternating + 1
		
		if not firstHitDone then
			if not getCutRimOnly() then
				local soft = damageUnit
				local medium = breakMediumMat and damageUnit or 0
				local hard = breakHardMat and damageUnit or 0
				MakeHole(currPos, soft, medium, hard)
			else
				if VecDist(currPos, spherePos) > radius * 0.98 then
					local soft = damageUnit
					local medium = breakMediumMat and damageUnit or 0
					local hard = breakHardMat and damageUnit or 0
					MakeHole(currPos, soft, medium, hard)
				end
			end
		end
	end
	
	firstHitDone = true

	return points
end

function getCutRimOnly()
	return (not growOnX or not growOnY or not growOnZ) and rimOnly
end

-- Particle Functions

function spawnParticleAt(pos)
	ParticleReset()
	ParticleCollide(0)
	ParticleColor(0, 0.5, 1, 
				  0, 1, 1)
	ParticleEmissive(1, 0)
	local vel = Vec()
	
	local lifetime = 1 / 0.1 * maxTick
	
	if lifetime < 0.1 then
		lifetime = 0.1
	end
	
	SpawnParticle(pos, vel, lifetime)
end

-- Action functions

-- Sprite Functions

-- UI Sound Functions

-- Misc Functions