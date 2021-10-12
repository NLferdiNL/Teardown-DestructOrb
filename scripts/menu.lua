#include "datascripts/inputList.lua"
#include "datascripts/keybinds.lua"
#include "scripts/ui.lua"
#include "scripts/utils.lua"
#include "scripts/textbox.lua"

local menuOpened = false
local menuOpenLastFrame = false

local rebinding = nil

local erasingBinds = 0
local erasingValues = 0

local menuWidth = 0.20
local menuHeight = 0.575

local maxTickBox = nil

function menu_init()
	
end

function menu_tick(dt)
	if PauseMenuButton(toolReadableName .. " Settings") then
		menuOpened = true
	end
	
	if menuOpened and not menuOpenLastFrame then
		menuUpdateActions()
		menuOpenActions()
	end
	
	menuOpenLastFrame = menuOpened
	
	if rebinding ~= nil then
		local lastKeyPressed = getKeyPressed()
		
		if lastKeyPressed ~= nil then
			binds[rebinding] = lastKeyPressed
			rebinding = nil
		end
	end
	
	textboxClass_tick()
	
	if erasingBinds > 0 then
		erasingBinds = erasingBinds - dt
	end
end

function drawTitle()
	UiPush()
		UiTranslate(0, -40)
		UiFont("bold.ttf", 45)
		
		local titleText = toolReadableName .. " Settings"
		
		local titleBoxWidth, titleBoxHeight = UiGetTextSize(titleText)
		
		UiPush()
			UiColorFilter(0, 0, 0, 0.25)
			UiImageBox("MOD/sprites/square.png", titleBoxWidth + 20, titleBoxHeight + 20, 10, 10)
		UiPop()
		
		UiText(titleText)
	UiPop()
end

function bottomMenuButtons()
	UiPush()
		UiFont("regular.ttf", 26)
	
		UiButtonImageBox("MOD/sprites/square.png", 6, 6, 0, 0, 0, 0.5)
		
		UiAlign("center bottom")
		
		local buttonWidth = 250
		
		UiPush()
			UiTranslate(0, -100)
			if erasingValues > 0 then
				UiPush()
				c_UiColor(Color4.Red)
				if UiTextButton("Are you sure?" , buttonWidth, 40) then
					resetValues()
					erasingValues = 0
				end
				UiPop()
			else
				if UiTextButton("Reset values to defaults" , buttonWidth, 40) then
					erasingValues = 5
				end
			end
		UiPop()
		
		
		UiPush()
			--UiAlign("right bottom")
			--UiTranslate(230, 0)
			UiTranslate(0, -50)
			if erasingBinds > 0 then
				UiPush()
				c_UiColor(Color4.Red)
				if UiTextButton("Are you sure?" , buttonWidth, 40) then
					resetKeybinds()
					erasingBinds = 0
				end
				UiPop()
			else
				if UiTextButton("Reset binds to defaults" , buttonWidth, 40) then
					erasingBinds = 5
				end
			end
		UiPop()
		
		
		UiPush()
			--UiAlign("left bottom")
			--UiTranslate(-230, 0)
			if UiTextButton("Close" , buttonWidth, 40) then
				menuCloseActions()
			end
		UiPop()
	UiPop()
end

function disableButtonStyle()
	UiButtonImageBox("MOD/sprites/square.png", 6, 6, 0, 0, 0, 0.5)
	UiButtonPressColor(1, 1, 1)
	UiButtonHoverColor(1, 1, 1)
	UiButtonPressDist(0)
end

function greenAttentionButtonStyle()
	local greenStrength = math.sin(GetTime() * 5) - 0.5
	local otherStrength = 0.5 - greenStrength
	
	if greenStrength < otherStrength then
		greenStrength = otherStrength
	end
	
	UiButtonImageBox("MOD/sprites/square.png", 6, 6, otherStrength, greenStrength, otherStrength, 0.5)
end

function menu_draw(dt)
	if not isMenuOpen() then
		return
	end
	
	UiMakeInteractive()
	
	UiPush()
		UiBlur(0.75)
		
		UiAlign("center middle")
		UiTranslate(UiWidth() * 0.5, UiHeight() * 0.5)
		
		UiPush()
			UiColorFilter(0, 0, 0, 0.25)
			UiImageBox("MOD/sprites/square.png", UiWidth() * menuWidth, UiHeight() * menuHeight, 10, 10)
		UiPop()
		
		UiWordWrap(UiWidth() * menuWidth)
		
		UiTranslate(0, -UiHeight() * (menuHeight / 2))
		
		drawTitle()
		
		UiTranslate(UiWidth() * (menuWidth / 10), 0)
		
		UiTranslate(0, 30)
		
		UiFont("regular.ttf", 26)
		UiAlign("left middle")
		
		UiPush()
			UiTranslate(0, 50)
			for i = 1, #bindOrder do
				local id = bindOrder[i]
				local key = binds[id]
				drawRebindable(id, key)
				UiTranslate(0, 50)
			end
		UiPop()
		
		setupTextBoxes()
		
		UiTranslate(0, 50 * (#bindOrder + 1))
		
		textboxClass_render(maxTickBox)
		
		UiPush()
			UiTranslate(-165, 50)
			
			UiFont("regular.ttf", 20)
			drawToggle("Break medium materials:", breakMediumMat, function(v) 
																	breakMediumMat = v
																	
																	if not v then 
																		breakHardMat = false 
																	end 
																 end)
			
			UiTranslate(0, 50)
			drawToggle("Break hard materials:", breakHardMat, function(v) 
																if not breakMediumMat then 
																	breakMediumMat = true 
																end 
																
																breakHardMat = v 
																
																end)
			
			UiTranslate(0, 50)
			drawToggle("Grow on X:", growOnX, function(v) growOnX = v end)
			
			UiTranslate(0, 50)
			drawToggle("Grow on Y:", growOnY, function(v) growOnY = v end)
			
			UiTranslate(0, 50)
			drawToggle("Grow on Z:", growOnZ, function(v) growOnZ = v end)
			
			UiTranslate(0, 50)
			drawToggle("Rim damage only:", rimOnly, function(v) rimOnly = v end)
		UiPop()
	UiPop()
	
	UiPush()
		UiTranslate(UiWidth() * 0.5, UiHeight() * 0.5)
		--UiTranslate(0, -UiHeight() * (menuHeight / 2))
		UiTranslate(0, UiHeight() * (menuHeight / 2) - 10)
		
		bottomMenuButtons()
	UiPop()

	textboxClass_drawDescriptions()
end

function setupTextBoxes()
	local textBox01, newBox01 = textboxClass_getTextBox(1)
	
	if newBox01 then
		textBox01.name = "Tick Speed"
		textBox01.value = maxTick .. ""
		textBox01.numbersOnly = true
		textBox01.limitsActive = true
		textBox01.numberMin = 0.001
		textBox01.numberMax = 500
		textBox01.description = "Delay between growth.\nLower is faster.\n Min: 0.001\nDefault: 0.1\nMax: 500"
		textBox01.onInputFinished = function(v) maxTick = tonumber(v) end
		
		maxTickBox = textBox01
	end
end

function drawRebindable(id, key)
	UiPush()
		UiButtonImageBox("MOD/sprites/square.png", 6, 6, 0, 0, 0, 0.5)
	
		--UiTranslate(UiWidth() * menuWidth / 1.5, 0)
	
		UiAlign("right middle")
		UiText(bindNames[id] .. "")
		
		--UiTranslate(UiWidth() * menuWidth * 0.1, 0)
		
		UiAlign("left middle")
		
		if rebinding == id then
			c_UiColor(Color4.Green)
		else
			c_UiColor(Color4.Yellow)
		end
		
		if UiTextButton(key:upper(), 40, 40) then
			rebinding = id
		end
	UiPop()
end

function menuOpenActions()
	
end

function menuUpdateActions()
	--[[if resolutionBox ~= nil then
		resolutionBox.value = resolution .. ""
	end]]--
end

function menuCloseActions()
	menuOpened = false
	rebinding = nil
	erasingBinds = 0
	erasingValues = 0
	saveKeyBinds()
	saveFloatValues()
end

function resetValues()
	menuUpdateActions()
	maxTickBox.value = 0.1
end

function isMenuOpen()
	return menuOpened
end

function setMenuOpen(val)
	menuOpened = val
end