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

local toolPos = Vec(0.25, -0.25, -0.5)
local toolRot = 0
local rotSpeed = 30

maxTick = 0.1
local currTick = maxTick

damageAlternating = 0
particleAlternating = 5
local singleUnit = 2000 / 5
local damageUnit = 0.5
local growthSize = 0.05
local num_pts = singleUnit * sphereRadius

breakMediumMat = true
breakHardMat = true

growOnX = true
growOnY = true
growOnZ = true
rimOnly = true

showAxis = true

local indicatorPos = Vec()
local xEndPoint = Vec()
local yEndPoint = Vec()
local zEndPoint = Vec()

local firstHitDone = false

function init()
	saveFileInit()
	menu_init()
	
	RegisterTool(toolName, toolReadableName, "MOD/vox/tool.vox")
	SetBool("game.tool." .. toolName .. ".enabled", true)
end

function tick(dt)
	if not menu_disabled then
		menu_tick(dt)
	end
	
	local isMenuOpenRightNow = isMenuOpen()
	
	if sphereActive then
		sphereLogic()
		currTick = currTick - dt
		
		if currTick <= 0 then
			currTick = maxTick
			updateSphere(growthSize)
		end
		
		if InputPressed(binds["Disable_Sphere"]) then
			resetSphere()
		end
	end
	
	if GetString("game.player.tool") ~= toolName or GetPlayerVehicle() ~= 0 then
		return
	end
	
	doToolAnim(dt)
	
	if showAxis then
		getAxisPositions()
	end
	
	if isMenuOpenRightNow then
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
	
	if GetString("game.player.tool") ~= toolName or GetPlayerVehicle() ~= 0 then
		return
	end
	
	if showAxis then
		drawXYZIndicator()
	end
end

-- UI Functions (excludes sound specific functions)

function getAxisPositions()
	local cameraTransform = GetCameraTransform()
	local pos = cameraTransform.pos
	local dir = TransformToParentVec(cameraTransform, Vec(-0.75, -0.4, -1))
	
	indicatorPos = VecAdd(dir, pos)
	
	local lineLength = 0.05
	
	xEndPoint = VecAdd(indicatorPos, Vec(lineLength, 0, 0))
	yEndPoint = VecAdd(indicatorPos, Vec(0, lineLength, 0))
	zEndPoint = VecAdd(indicatorPos, Vec(0, 0, lineLength))
	
	if growOnX then
		DebugLine(indicatorPos, xEndPoint, 1, 0, 0, 1)
	else
		DebugLine(indicatorPos, xEndPoint, 0.25, 0.25, 0.25, 1)
	end
	
	if growOnY then
		DebugLine(indicatorPos, yEndPoint, 0, 1, 0, 1)
	else
		DebugLine(indicatorPos, yEndPoint, 0.25, 0.25, 0.25, 1)
	end
	
	if growOnZ then
		DebugLine(indicatorPos, zEndPoint, 0, 0, 1, 1)
	else
		DebugLine(indicatorPos, zEndPoint, 0.25, 0.25, 0.25, 1)
	end
end

function drawXYZIndicator()
	UiPush()
		UiFont("regular.ttf", 20)
		--[[local x = UiWidth() * 0.1
		local y = UiHeight() * 0.95
		
		local dir = UiPixelToWorld(x, y)
		local cameraTransform = GetCameraTransform()
		local pos = cameraTransform.pos
		
		indicatorPos = VecAdd(dir, pos)
		
		local lineLength = 0.05
		
		xEndPoint = VecAdd(indicatorPos, Vec(lineLength, 0, 0))
		yEndPoint = VecAdd(indicatorPos, Vec(0, lineLength, 0))
		zEndPoint = VecAdd(indicatorPos, Vec(0, 0, lineLength))]]--
		
		UiColor(0.25, 0.25, 0.25, 1)
		
		UiAlign("center bottom")
		
		UiPush()
			UiFont("bold.ttf", 26)
		
			local iX, iY = UiWorldToPixel(indicatorPos)
			
			iY = iY - 75
			
			UiTranslate(iX, iY)
			
			UiColor(1, 1, 1, 1)
			UiTextOutline(0, 0, 0, 1, 0.2)
			--UiTextShadow
			UiText("DestructOrb Axis")
		UiPop()
		
		UiPush()
			local xX, xY = UiWorldToPixel(xEndPoint)
			UiTranslate(xX, xY)
			
			if growOnX then
				UiColor(1, 0, 0, 1)
			end
			
			UiText("X")
		UiPop()
		
		UiPush()
			local yX, yY = UiWorldToPixel(yEndPoint)
			UiTranslate(yX, yY)
			
			if growOnY then
				UiColor(0, 1, 0, 1)
			end
			
			UiText("Y")
		UiPop()
		
		UiPush()
			local zX, zY = UiWorldToPixel(zEndPoint)
			UiTranslate(zX, zY)
			
			if growOnZ then
				UiColor(0, 0, 1, 1)
			end
			
			UiText("Z")
		UiPop()
	UiPop()
end

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
end

-- Really wish I understood this math :(
function fibonacci_sphere(samples, offsetPos, radius)
	local rnd = 1.0 * samples

	local offset = 2/samples
	local increment = math.pi * (3. - math.sqrt(5))
	
	local pAlternating = particleAlternating
	local dAlternating = damageAlternating
	
	particleSetup()

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
		
		if pAlternating > particleAlternating then
			pAlternating = 0
			spawnParticleAt(currPos)
		end
		
		pAlternating = pAlternating + 1
		
		if not firstHitDone and dAlternating > damageAlternating then
			dAlternating = 0
			if not getCutRimOnly() then
				local soft = damageUnit
				local medium = breakMediumMat and damageUnit or 0
				local hard = breakHardMat and damageUnit or 0
				--local hit = QueryClosestPoint(currPos, damageUnit)
				--if hit then 
					MakeHole(currPos, soft, medium, hard) 
				--end
			else
				if VecDist(currPos, spherePos) > radius * 0.98 then
					local soft = damageUnit
					local medium = breakMediumMat and damageUnit or 0
					local hard = breakHardMat and damageUnit or 0
					--local hit = QueryClosestPoint(currPos, damageUnit)
					--if hit then 
						MakeHole(currPos, soft, medium, hard) 
					--end
				end
			end
		end
		
		dAlternating = dAlternating + 1
	end
	
	firstHitDone = true

	return points
end

function doToolAnim(dt)
	toolRot = toolRot + dt * rotSpeed

	local tempRot = QuatEuler(0, toolRot, 0)
	
	SetToolTransform(Transform(toolPos, tempRot), 0)
end

function getCutRimOnly()
	return (not growOnX or not growOnY or not growOnZ) and rimOnly
end
-- Particle Functions

function particleSetup()
	ParticleReset()
	ParticleCollide(0)
	--[[ParticleColor(0, 0.5, 1, 
				  1, 0, 1)]]--
	ParticleColor(0, 0.5, 1,
				  0, 1, 1)
	ParticleEmissive(1, 0)
end

function spawnParticleAt(pos)
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