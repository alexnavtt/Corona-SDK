local composer = require("composer")
local globalData = require("globalData")
local cookbook = require("cookbook")
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
 local settings_list = {"Panel Colour",
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
	local background = display.newRoundedRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight, 10)
	background:setFillColor(unpack(globalData.dark_grey))
	local paint = {type = "image", filename = "Image Assets/Cheese-Graphic.png"}
	background.fill = paint 

	self.tab_group = cookbook.createTabBar()
	sceneGroup:insert(self.tab_group)
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		self.tab_group = cookbook.updateTabBar(self.tab_group)
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