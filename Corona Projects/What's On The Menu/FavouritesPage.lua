local composer 	 = require("composer")
local cookbook 	 = require("cookbook")
local widget   	 = require("widget")
local globalData = require("globalData")

local scene = composer.newScene()

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
	self.tab_group = cookbook.createTabBar()
	self.clip_box = widget.newScrollView(globalData.scroll_options)

	sceneGroup:insert(self.clip_box)
	sceneGroup:insert(self.tab_group)
	-- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		self.tab_group = cookbook.updateTabBar(self.tab_group)
		local panel_group = display.newGroup()

		local food_list = cookbook.getAlphabetizedList(globalData.favourites)

		local panel_height = globalData.panel_height
		local panel_width  = globalData.panel_width
		local panel_pos    = 0.6*panel_height

		for i = 1,#food_list,1 do
			local new_panel_group = cookbook.createFoodPanel(food_list[i], display.contentCenterX, panel_pos, panel_width, panel_height)
			
			local new_panel = cookbook.findID(new_panel_group, "panel")
			panel_pos = panel_pos + 1.2*panel_height

			function new_panel:tap(event)
				self:setFillColor(unpack(globalData.panel_color_touched))

				local function timerFunc(event)
					self:setFillColor(unpack(globalData.panel_color))
					globalData.active_recipe = food_list[i]
					composer.gotoScene("ViewRecipePage", {effect = "slideRight", time = globalData.transition_time, params = {name = food_list[i]}})
				end
				timer.performWithDelay(50, timerFunc, 1)

			end

			new_panel:addEventListener("tap", new_panel)
			panel_group:insert(new_panel_group)
		end

		self.clip_box:insert(panel_group)
	
	elseif phase == "did" then
		globalData.relocateSearchBar(unpack(globalData.search_bar_home))

	end
end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
 
	elseif ( phase == "did" ) then
		for i = 1,self.clip_box._collectorGroup.numChildren,1 do
			self.clip_box:remove(1)
		end
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