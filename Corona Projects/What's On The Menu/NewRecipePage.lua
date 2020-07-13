local composer = require( "composer" )
local cookbook = require( "cookbook" )
local globalData = require( "globalData" )
local widget = require( "widget" )
local tinker = require("Tinker")

 
local scene = composer.newScene()
 

 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor(unpack(globalData.background_color))

	self.tab_group = cookbook.createTabBar() 
	sceneGroup:insert(self.tab_group)

	local text_field_params = {	rounded = true,
								defaultText = "Enter Recipe Name",
								font = native.systemFontBold,
								backgroundColor = globalData.white,
								textColor = globalData.dark_grey,
								strokeColor = globalData.dark_grey,
								strokeWidth = 0,
								cursorColor = globalData.dark_grey}
	local name_text_field = tinker.newTextField(display.contentCenterX, 0.2*display.contentHeight, 0.8*display.contentWidth, 0.05*display.contentHeight, text_field_params)
	sceneGroup:insert(name_text_field)

	text_field_params.defaultText = "Prep Time"
	local prep_time_text_field = tinker.newTextField(0.5*display.contentCenterX, 0.4*display.contentHeight, 0.4*display.contentWidth, 0.05*display.contentHeight, text_field_params)

	text_field_params.defaultText = "Cook Time"
	local cook_time_text_field = tinker.newTextField(1.5*display.contentCenterX, 0.4*display.contentHeight, 0.4*display.contentWidth, 0.05*display.contentHeight, text_field_params)
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
		native.setKeyboardFocus(nil)
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