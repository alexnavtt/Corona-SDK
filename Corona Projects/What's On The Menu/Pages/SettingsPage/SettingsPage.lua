local composer = require("composer")
local globalData = require("globalData")
local cookbook = require("cookbook")
local colors = require("Palette")
local widget = require("widget")
local tinker = require("ext_libs.tinker.tinker")
local app_colors = require("AppColours")
local transition = require("transition")
local util = require("lib.util.table")
local app_transitions = require("AppTransitions")
local app_network = require("lib.network.library")
 
local scene = composer.newScene()

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
globalData.colorOptions = {blue = "blue", red = "red", light = "white", dark = "purple", bright = "green"}
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
	local params = event.params or {}
 
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, cX, cY, W, H)
	background:setFillColor(unpack(app_colors.settings.background))
	background:addEventListener("touch", app_transitions.swipeLeft)

	local y_level = 0.12*H
	local x_level = 0.08*W

	local title = display.newText({text = "General Settings", x = 0.05*W, y = y_level, fontSize = 1.5*globalData.titleFontSize, font = native.systemFontBold})
	title.anchorX = 0
	title:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(title)

	y_level = y_level + 0.1*H

	---------------------
	-- DEFAULT RECIPES --
	---------------------
	local showDefaultRecipes = display.newText({text = "Show Default Recipes", x = x_level, y = y_level, fontSize = globalData.mediumFontSize})
	showDefaultRecipes.anchorX = 0
	showDefaultRecipes:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(showDefaultRecipes)

	local function defaultRecipeOnPress(event)
		globalData.settings.showDefaultRecipes = not globalData.settings.showDefaultRecipes
		globalData.writeSettings()

		if not globalData.settings.showDefaultRecipes then
			globalData.menu["Hot Chocolate"] = nil
			globalData.menu["Classic Waffle"] = nil
			globalData.menu["Banana Bread"] = nil
			globalData.writeCustomMenu()
		else 
			globalData.readDefaultMenu()
		end
	end

	local default_switch_params = {defaultState = globalData.settings.showDefaultRecipes, tap_func = defaultRecipeOnPress, displayGroup = sceneGroup, touchScale = 2.0}
	local showDefaultRecipesSwitch = tinker.newSlidingSwitch(0.9*W, y_level, default_switch_params)

	y_level = y_level + 0.1*H

	--------------------------------
	-- RECIPE DISPLAY MODE SCHEME --
	--------------------------------
	local recipeDisplay = display.newText({text = "Default Recipe Display to Landscape", x = x_level, y = y_level, fontSize = globalData.mediumFontSize})
	recipeDisplay.anchorX = 0
	recipeDisplay:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(recipeDisplay)

	local function tapRecipeStyle(event)
		if globalData.settings.recipeStyle == "portrait" then
			globalData.settings.recipeStyle = "landscape"
		else
			globalData.settings.recipeStyle = "portrait"
		end
		globalData.writeSettings()
		return true
	end

	local showLandscape = globalData.settings.recipeStyle == "landscape"
	local recipe_style_switch_params = {defaultState = showLandscape, tap_func = tapRecipeStyle, displayGroup = sceneGroup, touchScale = 2.0}
	local recipe_style_switch = tinker.newSlidingSwitch(showDefaultRecipesSwitch.x, y_level, recipe_style_switch_params)

	y_level = y_level + 0.1*H

	-----------------
	-- SCREEN LOCK --
	-----------------

	local screenLock = display.newText({text = "Prevent Idle Screen Lock", x = x_level, y = y_level, fontSize = globalData.mediumFontSize})
	screenLock.anchorX = 0
	screenLock:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(screenLock)

	local function tapScreenLock(event)
		globalData.settings.allow_idle_timeout = not globalData.settings.allow_idle_timeout
		if not globalData.settings.allow_idle_timeout then
			system.setIdleTimer(false)
		else
			system.setIdleTimer(true)
		end
		globalData.writeSettings()
	end

	local prevent_screen_lock = not globalData.settings.allow_idle_timeout
	local screen_lock_params = {defaultState = prevent_screen_lock, tap_func = tapScreenLock, displayGroup = sceneGroup, touchScale = 2.0}
	local screen_lock_switch = tinker.newSlidingSwitch(recipe_style_switch.x, y_level, screen_lock_params)

	y_level = y_level + 0.1*H

	------------------
	-- DATA SYNCING -- 
	------------------
	-- local dataSync = display.newText({text = "Store data on the cloud", x = x_level, y = y_level, fontSize = globalData.mediumFontSize})
	-- dataSync.anchorX = 0
	-- dataSync:setFillColor(unpack(app_colors.settings.text))
	-- sceneGroup:insert(dataSync)

	-- local function tapDataSync(event)
	-- 	globalData.settings.network_is_enabled = not globalData.settings.network_is_enabled
	-- 	globalData.writeSettings()

	-- 	-- Make sure that all entries have a timestamp for networking
	-- 	if globalData.settings.network_is_enabled then
	-- 		for key, value in pairs(globalData.menu) do
	-- 			if not value.timestamp then
	-- 				value.timestamp = os.time(os.date('*t'))
	-- 			end
	-- 		end

	-- 		if app_network.config.logged_in then
	-- 			app_network.syncData()
	-- 		end

	-- 		local function firstTimeListener(event)
	-- 			if event.index == 1 then
	-- 				app_network.createProfile()
	-- 			end
	-- 			return true
	-- 		end

	-- 		if app_network.config.first_time then
	-- 			native.showAlert(globalData.app_name, "Hey! This is your fist time connecting to the cloud\nLet's get started by making a profile for you!", {"OK", "Cancel"}, firstTimeListener)
	-- 		end
	-- 	end
	-- end

	-- local enable_data_sync_params = {defaultState = globalData.settings.network_is_enabled, tap_func = tapDataSync, displayGroup = sceneGroup}
	-- local enable_data_sync = tinker.newSlidingSwitch(screen_lock_switch.x, y_level, enable_data_sync_params)

	-- y_level = y_level + 0.1*H

	---------------------
	-- NETWORK PROFILE --
	---------------------

	local Profile = display.newText({text = "Network Profile", x = x_level, y = y_level, fontSize = globalData.mediumFontSize, parent = sceneGroup})
	Profile.anchorX = 0
	Profile:setFillColor(unpack(app_colors.settings.text))

	local profileRect = display.newRect(sceneGroup, cX, Profile.y, W, 0.1*H)
	profileRect.isVisible = false
	profileRect.isHitTestable = true

	local proceedToProfile = display.newImageRect(sceneGroup, "Image Assets/White-Dropdown-Arrow-Graphic.png", 0.05*W, 0.05*W)
	proceedToProfile.x = recipe_style_switch.x
	proceedToProfile.y = y_level
	proceedToProfile:rotate(-90)

	local function moveToProfile(event)
		app_transitions.moveTo("NetworkProfilePage")
	end
	profileRect:addEventListener("tap", moveToProfile)

	y_level = y_level + 0.1*H

	------------------
	-- COLOR SCHEME --
	------------------
	local colorScheme = display.newText({text = "Color Scheme", x = x_level, y = y_level, fontSize = globalData.mediumFontSize})
	colorScheme.anchorX = 0
	colorScheme:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(colorScheme)

	local colorDropdown = display.newImageRect(sceneGroup, "Image Assets/White-Dropdown-Arrow-Graphic.png", 0.05*W, 0.05*W)
	colorDropdown.x = recipe_style_switch.x
	colorDropdown.y = y_level
	colorDropdown.id = "colorDropdown"
	colorDropdown.visible = false

	local names = {"Blueberry Blast", "Pastel Paradise", "Plumb Purple", "Tropical Trouble", "Raspberrry Red"}
	local official_names = {"blue", "light", "dark", "bright", "red"}
	local colorGroups = {}

	local start_y = y_level
	local indented_x = x_level + 0.04*H
	local delta_t = 500

	for i = 1,#names,1 do
		local newGroup = display.newGroup()
		newGroup.y     = start_y
		newGroup.alpha = 0
		newGroup.home  = start_y + i*0.05*H

		local new_text = display.newText({parent = newGroup, text = names[i], fontSize = globalData.smallFontSize, x = indented_x, y = 0})
		new_text:setFillColor(unpack(app_colors.settings.text))
		new_text.anchorX = 0

		function newGroup.appear(dt)
			transition.to(newGroup, {y = newGroup.home, alpha = 1, time = dt})
		end

		function newGroup.hide(dt)
			transition.to(newGroup, {y = start_y, alpha = 0, time = dt})
		end

		function newGroup:tap(event)
			local colorScheme = official_names[i]
			app_colors.changeTo(colorScheme)
			globalData.reloadApp()
			globalData.settings.colorScheme = colorScheme
			globalData.writeSettings()
		end
		newGroup:addEventListener("tap", newGroup)

		sceneGroup:insert(newGroup)
		colorGroups[i] = newGroup
	end

	function colorDropdown:tap(event)
		local dt = event.dt or delta_t

		colorDropdown.visible = not colorDropdown.visible
		transition.to(colorDropdown, {rotation = 180, time = dt, delta = true})
		
		if colorDropdown.visible then
			for i = 1,#colorGroups,1 do
				colorGroups[i].appear(dt)
			end
		else
			for i = 1,#colorGroups,1 do
				colorGroups[i].hide(dt)
			end
		end

		return true
	end
	colorDropdown:addEventListener("tap", colorDropdown)

	y_level = y_level + 0.1*H
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
	local params = event.params or {}
 
	if ( phase == "will" ) then
		local colorDropdown = util.findID(sceneGroup, "colorDropdown")
		if params.reload then colorDropdown:dispatchEvent({name = "tap", dt = 0}) end

	elseif ( phase == "did" ) then
		transition.to(globalData.tab_bar, {alpha = 1, time = globalData.transition_time})
 
	end
end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
	if not sceneGroup then return true end
 
	if ( phase == "will" ) then
		local colorDropdown = util.findID(sceneGroup, "colorDropdown")
		if colorDropdown.visible then colorDropdown:dispatchEvent({name = "tap"}) end
 
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
 
	end
end
 
 
-- destroy()
function scene:destroy( event )
 
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene