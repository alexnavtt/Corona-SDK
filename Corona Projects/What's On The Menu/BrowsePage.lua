local composer = require("composer")
local cookbook = require("cookbook")
local widget   = require("widget")
local globalData = require("globalData")
local tinker = require("Tinker")
local colors = require("Palette")
local app_colors = require("AppColours")
local util = require("GeneralUtility")
 
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
 	self.clip_box = widget.newScrollView(opt)
 	sceneGroup:insert(self.clip_box)

 -- 	self.tab_group = cookbook.createTabBar()
	-- sceneGroup:insert(self.tab_group)

	globalData.loadMenuImages()
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase

	local food_list = util.sortTableKeys(globalData.menu)
 
	if ( phase == "will" ) then

		-- self.tab_group = cookbook.updateTabBar(self.tab_group)
		transition.to(globalData.tab_bar, {alpha = 1, time = 0.8*globalData.transition_time})
		self.panels = {}

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
			local new_panel_group = createFoodPanel(food_list[i], display.contentCenterX, panel_pos, panel_width, panel_height, self.clip_box, panel_color[1+iter], text_color[iter+1])
	
			local new_panel = util.findID(new_panel_group, "panel")
			self.panels[food_list[i]] = new_panel
			
			panel_pos = panel_pos + 0.8*panel_height

			function new_panel:tap(event)
				globalData.active_recipe = food_list[i]
				print("Active recipe: " .. food_list[i])
				if globalData.settings.recipeStyle == "portrait" then
					composer.gotoScene("ViewRecipePage", {effect = "slideRight", time = globalData.transition_time, params = {name = food_list[i]}})
				else
					composer.gotoScene("ViewLandscapeRecipe", {effect = "slideRight", time = globalData.transition_time, params = {name = food_list[i]}})
				end

				return true
			end

			new_panel:addEventListener("tap", new_panel)
			self.clip_box:insert(new_panel_group)
			new_panel_group:toBack()
			iter = 1 - iter
		end

		self.clip_box:setScrollHeight(panel_pos) 

		
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
		if self.clip_box then
			for i = 1,self.clip_box._collectorGroup.numChildren,1 do
				self.clip_box:remove(1)
			end
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