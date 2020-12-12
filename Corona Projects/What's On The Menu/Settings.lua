local composer = require("composer")
local globalData = require("globalData")
local cookbook = require("cookbook")
local colors = require("Palette")
local widget = require("widget")
local tinker = require("Tinker")
local app_colors = require("AppColours")
local transition = require("transition")
 
local scene = composer.newScene()

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY
local y_level
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local settings_list =  {"Panel Colour",
 						"Background Colour",
 						"Recipe Colour",
 						"Recipe Mode",
 						"Clear Favourite Data",
 						"Clear Recipe Data"}
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, cX, cY, W, H)
	background:setFillColor(unpack(app_colors.settings.background))
	-- local paint = {type = "image", filename = "Image Assets/Cheese-Graphic.png"}
	-- background.fill = paint 

	-- self.tab_group = cookbook.createTabBar()
	-- sceneGroup:insert(self.tab_group)

	y_level = 0.15*H
	local title = display.newText({text = "General Settings", x = 0.05*W, y = y_level, fontSize = 1.5*globalData.titleFontSize, font = native.systemFontBold})
	title.anchorX = 0
	title:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(title)

	y_level = y_level + 0.1*H

	---------------------
	-- DEFAULT RECIPES --
	---------------------
	local showDefaultRecipes = display.newText({text = "Show Default Recipes", x = 0.08*W, y = y_level, fontSize = globalData.mediumFontSize})
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

	local showDefaultRecipesSwitch = widget.newSwitch({x = 0.9*W, y = y_level, initialSwitchState = globalData.settings.showDefaultRecipes, onPress = defaultRecipeOnPress})
	showDefaultRecipesSwitch:scale(1.5,1.5)
	sceneGroup:insert(showDefaultRecipesSwitch)

	y_level = y_level + 0.1*H

	--------------------------------
	-- RECIPE DISPLAY MODE SCHEME --
	--------------------------------
	local recipeDisplay = display.newText({text = "Recipe Display Orientation", x = 0.08*W, y = y_level, fontSize = globalData.mediumFontSize})
	recipeDisplay.anchorX = 0
	recipeDisplay:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(recipeDisplay)

	local color = 1
	if app_colors.scheme == "light" then color = 0 end
	local params = {color = color, label = "Portrait", displayGroup = sceneGroup}
	local portraitOption = tinker.newButton(0.7*W, y_level, 0.15*W, 0.03*H, params)

	params.label = "Landscape"
	local landscapeOption = tinker.newButton(portraitOption.x + 1.1*portraitOption.width, y_level, portraitOption.width, portraitOption.height, params)

	if globalData.settings.recipeStyle == "portrait" then
		portraitOption.alpha = 0.5
		landscapeOption.alpha = 0.2
	else
		portraitOption.alpha = 0.2
		landscapeOption.alpha = 0.5
	end

	local function tapPortrait(event)
		globalData.settings.recipeStyle = "portrait"
		globalData.writeSettings()
		portraitOption.alpha = 0.5
		landscapeOption.alpha = 0.2
	end

	local function tapLandscape(event)
		globalData.settings.recipeStyle = "landscape"
		globalData.writeSettings()
		portraitOption.alpha = 0.2
		landscapeOption.alpha = 0.5
		native.showAlert("What's On The Menu", "This doesn't actually do anything yet", {"OK"})
	end

	portraitOption:addEventListener("tap", tapPortrait)
	landscapeOption:addEventListener("tap", tapLandscape)


	------------------
	-- COLOR SCHEME --
	------------------
	y_level = y_level + 0.1*H

	local colorScheme = display.newText({text = "Color Scheme", x = 0.08*W, y = y_level, fontSize = globalData.mediumFontSize})
	colorScheme.anchorX = 0
	colorScheme:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(colorScheme)

	local colorBox = display.newRect(sceneGroup, showDefaultRecipesSwitch.x, y_level, 0.05*W, 0.05*W)
	colorBox:setFillColor(unpack(colors[globalData.colorOptions[globalData.settings.colorScheme]]))
	colorBox.strokeWidth = 10
	colorBox:setStrokeColor(unpack(app_colors.settings.color_border))

	local function showColorOptions(event)
		local group = display.newGroup()
		group.x = cX
		group.y = cY

		local glassScreen = display.newRect(group, 0, 0, W, H)
		glassScreen:setFillColor(0,0,0,0.5)
		glassScreen:addEventListener("tap", function(event) group:removeSelf(); return true end)

		print(#globalData.colorOptions)
		local bkgd = display.newRect(group, 0, 0, 5*0.1*W, 0.1*W)
		bkgd:setFillColor(0.5)
		bkgd:addEventListener("tap", function(e) return true end)

		local x = -bkgd.width/2 + 0.05*W

		for colorScheme, color in pairs(globalData.colorOptions) do
			local option = display.newRect(group, x, 0, 0.07*W, 0.07*W)
			option:setFillColor(unpack(colors[color]))

			x = x + 0.1*W
			if colorScheme == globalData.settings.colorScheme then
				option.strokeWidth = 10
				option:setStrokeColor(0,0,0,0.5)
			end

			local function onTap(event)
				group:removeSelf()
				app_colors.changeTo(colorScheme)
				globalData.reloadApp()
				globalData.settings.colorScheme = colorScheme
				globalData.writeSettings()
			end
			option:addEventListener("tap", onTap)
		end
	end
	colorBox:addEventListener("tap", showColorOptions)
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		transition.to(globalData.tab_bar, {alpha = 1, time = globalData.transition_time})
		-- self.tab_group = cookbook.updateTabBar(self.tab_group)
		-- Code here runs when the scene is entirely on screen
 
	end
end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
 
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