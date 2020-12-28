local composer = require("composer")
local cookbook = require("cookbook")
local widget   = require("widget")
local globalData = require("globalData")
local tinker = require("Tinker")
local colors = require("Palette")
local app_colors = require("AppColours")
local util = require("GeneralUtility")
local app_transitions = require("AppTransitions")
 
local scene = composer.newScene()

local createFoodPanel = require("BrowseUtil.create_food_panel")
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
	local sceneGroup = self.view

	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
 	background:setFillColor(unpack(app_colors.browse.background))
 	background.strokeWidth = 2
 	background:setStrokeColor(0)

	local opt = globalData.scroll_options()
	opt.backgroundColor = app_colors.browse.background
 	self.scroll_view = widget.newScrollView(opt)
 	sceneGroup:insert(self.scroll_view)

 	self.scroll_view._view:addEventListener("touch", app_transitions.swipeRight)
 	self.scroll_view._view._background:addEventListener("touch", app_transitions.swipeRight)

	globalData.loadMenuImages()
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase

	local food_list = util.sortTableKeys(globalData.menu)
 
	if ( phase == "will" ) then

		transition.to(globalData.tab_bar, {alpha = 1, time = 0.8*globalData.transition_time})

		local panel_width  = display.contentWidth --globalData.panel_width
		local panel_height = panel_width*(display.contentWidth/display.contentHeight)
		local panel_pos    = 0.3*panel_height
		local panel_color = {app_colors.browse.panel_1, app_colors.browse.panel_2}
		local text_color   = {{0.3}, {0.7}}
		local iter = 0

		for name, image_info in pairs(globalData.gallery) do
			if image_info.source == "camera" then
				local long_size  = math.max(image_info.width, image_info.height)
				local short_size = math.min(image_info.width, image_info.height) 

				panel_height = (short_size/long_size)*panel_width or panel_height
				break
			end
		end

		for i = 1,#food_list,1 do
			local new_panel_group = createFoodPanel(food_list[i], display.contentCenterX, panel_pos, panel_width, panel_height, self.scroll_view, panel_color[1+iter], text_color[iter+1])
			
			panel_pos = panel_pos + 0.8*panel_height

			self.scroll_view:insert(new_panel_group)
			new_panel_group:toBack()
			iter = 1 - iter
		end

		self.scroll_view:setScrollHeight(panel_pos) 

		
	elseif phase == "did" then

	end

end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
 
	elseif ( phase == "did" ) then
		if self.scroll_view then
			for i = 1,self.scroll_view._collectorGroup.numChildren,1 do
				self.scroll_view:remove(1)
			end
		end
		
		globalData.lastScene = "BrowsePage"
 
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