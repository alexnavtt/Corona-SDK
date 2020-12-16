-- Solar2D includes
local composer = require("composer")
local widget   = require("widget")
local transition = require("transition")

-- App includes
local globalData = require("globalData")
local app_colors = require("AppColours")

-- Page includes
local view_recipe_params = require("ViewRecipeUtil.view_recipe_shared_params")
local page_params = view_recipe_params.landscape

local scene = composer.newScene()

local Cx = display.contentCenterX
local Cy = display.contentCenterY
local W  = display.contentWidth
local H  = display.contentHeight 
local pH = W - page_params.info_bar_height - page_params.title_banner_height -- page height (the height of the meat of the page)

 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view

	local background = display.newRect(sceneGroup, Cx, Cy, W, H)
	background:setFillColor(unpack(app_colors.recipe.background))

	local top_bar = display.newRect(sceneGroup, W, 0, H, page_params.info_bar_height)
	top_bar.anchorX = 0
	top_bar.anchorY = 0
	top_bar:setFillColor(0)
	top_bar:rotate(90)

	local title_background = display.newRect(sceneGroup, W - page_params.info_bar_height, 0, display.contentHeight, page_params.title_banner_height)
	title_background.anchorX = 0
	title_background.anchorY = 0
	title_background:setFillColor(unpack(app_colors.recipe.title_bkgd))
	title_background:rotate(90)

	self.ingredient_panel = widget.newScrollView({x = pH/2, y = 0.15*H,
											 	  width = 0.9*pH,
											 	  height = 0.28*H,
											 	  verticalScrollDisabled = true,
											 	  isBounceEnabled = false,
											  	  backgroundColor = app_colors.recipe.ing_background,
											 	  hideBackground = true,
											 	  bottomPadding = 0.1*display.contentWidth})
	sceneGroup:insert(self.ingredient_panel)

	local ingredient_bkgd = display.newRoundedRect(sceneGroup, self.ingredient_panel.x, self.ingredient_panel.y, self.ingredient_panel.width + 2*page_params.v_spacing, self.ingredient_panel.height, 0.05*W)
	ingredient_bkgd:setFillColor(unpack(app_colors.recipe.ing_background))
	ingredient_bkgd:toBack()

 	background:toBack()
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		transition.to(globalData.tab_bar, {alpha = 0, time = 0.8*globalData.transition_time})
		-- Code here runs when the scene is still off screen (but is about to come on screen)
 
	elseif ( phase == "did" ) then
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