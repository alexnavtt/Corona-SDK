local composer = require( "composer" )
local cookbook = require( "cookbook" )
local globalData = require( "globalData" )
local widget = require( "widget" )
 
local scene = composer.newScene()

 
local container

local function createIngredientPanel(x,y,foodname,image_title)
	local group = display.newGroup()

	local background = display.newRect(0, 0, globalData.label_width, globalData.label_height)
	-- background.anchorX = 0
	background:setFillColor(unpack(globalData.panel_color))
	group:insert(background)

	if image_title then
		local icon = display.newImageRect("Image Assets/"..image_title, 0.2*background.width, 0.9*background.height)
		icon.x = background.x + 0.75*background.width
		icon.y = background.y
		group:insert(icon)
	end

	local text_params = {text = foodname, 
						 x = -0.45*background.width,
						 y = background.y,
						 width = 0.75*background.width,
						 fontSize = 0.02*display.contentHeight}
	local text = display.newText(text_params)
	text:setFillColor(unpack(globalData.light_text_color))
	text.anchorX = 0
	while text.height > 0.9*background.height do
		text.size = 0.95*text.size
	end

	group:insert(text)

	group.anchorX = 0
	group.anchorY = 0
	group.anchorChildren = true

	group.x = x
	group.y = y

	return(group)
end

local function translateBy(object, final_time, delay, dx, dy)
	local time_ratio = delay/final_time
	object:translate(time_ratio*dx, time_ratio*dy)
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
 	cookbook.newRecipeIngredientList = {}

 	-- Create display groups
	local sceneGroup 	= self.view
	self.tab_group 	= cookbook.createTabBar()
	local label_group 	= display.newGroup()
	local scroll_group 	= display.newGroup()

	-- Parameters
	local tab_height = globalData.tab_height

	local panel_labels = {"Common Ingredients", "Meats", "Starches", "Fruits and Veggies", "Dairy", "Nuts", "Seasonings", "Sauces", "New Ingredient"}
	local panel_text_keys = {"common_ingredients", "meats", "starches", "fruits_and_veggies", "dairy", "nuts", "seasonings", "sauces", "new_ingredient"}

	local display_height = display.contentHeight - 2*tab_height
	local scroll_height = 0.95*display_height

	local y_level = tab_height + 0.025*display_height
	local y_level_delta = (scroll_height - globalData.label_height)/(#panel_labels-1)

	-- Create Background
	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor(unpack(globalData.background_color))

	-- Create Scroll Panels to Hold Ingredients
	local left_side_tab = widget.newScrollView({left = 0.025*display_height,
												top = tab_height + 0.025*display_height, 
												width = 0.475*display.contentWidth, 
												height = scroll_height,
												friction = 1.0,
												horizontalScrollDisabled = true,
												isBounceEnabled = false,
												backgroundColor = globalData.panel_color})
	left_side_tab.index = 1.0

	local left_outline = display.newRect(scroll_group, left_side_tab.x, left_side_tab.y, left_side_tab.width, left_side_tab.height)
	left_outline:setFillColor(1,1,1,0)
	left_outline:setStrokeColor(0.1)
	left_outline.strokeWidth = 2

	-- Create Ingredient List
	local right_side_tab = widget.newScrollView({left = 1.05*display.contentWidth, 
												top = tab_height + 0.025*display_height,  
												width = 0.4*display.contentWidth, 
												height = scroll_height,
												friction = 1.0,
												horizontalScrollDisabled = true,
												isBounceEnabled = false,
												backgroundColor = globalData.background_color})

	local back_button = display.newRect(label_group, right_side_tab.x - 0.5*right_side_tab.width - 0.0*display.contentWidth, right_side_tab.y, 0.05*display.contentWidth, 0.3*right_side_tab.height)
	back_button:setFillColor(unpack(globalData.panel_color))

	local back_button_arrow = display.newLine(label_group,
											  back_button.x - 0.4*back_button.width, back_button.y + 0.05*back_button.height,
											  back_button.x - 0.1*back_button.width, back_button.y + 0.00*back_button.height,
											  back_button.x - 0.4*back_button.width, back_button.y - 0.05*back_button.height)
	back_button_arrow.strokeWidth = 4
	back_button_arrow:setStrokeColor(1)

	function back_button:tap(event)
		local parent_group = self.parent
		local delta_t = 10
		local final_t = 100

		local function clearList()
			for i = 1,right_side_tab._collectorGroup.numChildren,1 do
				right_side_tab:remove(1)
			end
			right_side_tab:scrollTo("top", {time = 1})
		end

		local function timerFunc(event)
			return translateBy(parent_group, final_t, delta_t, 0.5*display.contentWidth, 0)
		end
		timer.performWithDelay(delta_t, timerFunc, final_t/delta_t)

		local function timerFunc(event)
			return translateBy(right_side_tab, final_t, delta_t, 0.5*display.contentWidth, 0)
		end
		timer.performWithDelay(delta_t, timerFunc, final_t/delta_t)
		timer.performWithDelay(final_t, clearList, 1)
	end
	back_button:addEventListener("tap", back_button)

	right_side_tab.y_level = 0.025*right_side_tab.height
	right_side_tab.y_level_delta = 0.1*right_side_tab.height

	local function toggleScrollView(object)
		-- print(object[2].text)
		local left_side_obj = left_side_tab._collectorGroup
		local right_side_obj = right_side_tab._collectorGroupd

		if object.pos_id == "right" then
			for i = 1,left_side_obj.numChildren,1 do
				left_side_obj[i]:translate(0, right_side_tab.y_level_delta)
				left_side_obj[i].tab_index = left_side_obj[i].tab_index + 1
			end

			left_side_tab:insert(object)
			object:translate(0,-(object.index-1)*right_side_tab.y_level_delta)
			object.tab_index = 1
			object.pos_id = "left"
			object[1]:setFillColor(unpack(globalData.background_color))
			object[2]:setFillColor(unpack(globalData.panel_color))
		
		elseif object.pos_id == "left" then
			-- object.tab_index = 0
			local cutoff_index = object.tab_index
			cookbook.newRecipeIngredientList[object.id] = nil

			if object.category == right_side_tab.category then
				right_side_tab:insert(object)
			else
				left_side_tab:remove(object)
			end

			for i = 1,left_side_obj.numChildren,1 do --left_side_obj.numChildren,1 do
				if left_side_obj[i] then
					if left_side_obj[i].tab_index > cutoff_index then
						left_side_obj[i]:translate(0, -right_side_tab.y_level_delta)
						left_side_obj[i].tab_index = left_side_obj[i].tab_index - 1
					end
				end
			end

			object.y = object.y0
			object.pos_id = "right"
			object[2]:setFillColor(unpack(globalData.background_color))
			object[1]:setFillColor(unpack(globalData.panel_color))

			left_side_tab:scrollTo("top", {time = 1})
		end

		local function timerFunc(event)
			translateBy()
		end

		return true
	end

	-- Create Food Type Label Panels
	for i = 1,#panel_labels,1 do
		local label = createIngredientPanel(0.55*display.contentWidth, y_level, panel_labels[i], false)
		label.id = panel_text_keys[i]

		function label:tap(event)
			-- Parameters
			local y_level = 0.05*(display.contentHeight - tab_height)
			local y_level_delta = right_side_tab.y_level_delta
			local name_table = cookbook.getAlphabetizedList(cookbook[label.id])
			local delta_t = 10   -- milliseconds
			local final_t = 100  -- milliseconds

			-- Transparent Listener to Prevent Touch Propagation
			local glass_screen = display.newRect(0.5*display.contentCenterX, display.contentCenterY + 0.5*tab_height, 0.5*display.contentWidth, display.contentHeight - tab_height)
			glass_screen:setFillColor(1,1,1,0.01)
			scroll_group:insert(glass_screen)

			function glass_screen:tap(event)
				return true
			end
			glass_screen:addEventListener("tap", glass_screen)

			local existance_table = {}
			for k = 1,left_side_tab._collectorGroup.numChildren,1 do
				print(left_side_tab._collectorGroup[k].id)
				existance_table[left_side_tab._collectorGroup[k].id] = true
			end

			-- Add options to scrollView
			for index, fieldname in pairs(name_table) do

				if not existance_table[fieldname] then
					-- Create Icon with Ingredient Name
					local icon = createIngredientPanel(0.025*right_side_tab.width, y_level, fieldname, false)
					icon.id = fieldname
					icon.pos_id = "right"
					icon.index = index
					icon.category = label.id
					icon.y0 = y_level
					right_side_tab:insert(icon)

					-- Add Listener to move to Other Scroll View
					function icon:tap(event)
						return toggleScrollView(self) 
					end
					icon:addEventListener("tap", icon)
				end

				y_level = y_level + y_level_delta
			end

			right_side_tab.category = label.id
			right_side_tab:insert(display.newRect(0,y_level,1,1))
			-- right_side_tab:toFront()
			left_side_tab:toFront()
			-- back_button:toFront()
			-- back_button_arrow:toFront()

			local parent_group = self.parent

			for i = 1,parent_group.numChildren,1 do
				local function timerFunc(event)
					return translateBy(parent_group[i], final_t, delta_t, -0.5*display.contentWidth, 0)
				end
				timer.performWithDelay(delta_t, timerFunc, final_t/delta_t)
			end

			local function timerFunc(event)
				return translateBy(right_side_tab, final_t, delta_t, -0.5*display.contentWidth, 0)
			end
			timer.performWithDelay(delta_t, timerFunc, final_t/delta_t)
		end
		label:addEventListener("tap", label)

		y_level = y_level + y_level_delta
		label_group:insert(label)
	end

	local bottomTabGroup = display.newGroup()

	-- Create Progression Bar
	local progress_tab = display.newRect(bottomTabGroup, 0.5*display.contentWidth, display.contentHeight, 0.5*display.contentWidth, globalData.tab_height)
	progress_tab.anchorX = 0
	progress_tab.anchorY = progress_tab.height
	progress_tab:setFillColor(unpack(globalData.green))
	progress_tab.strokeWidth = 2
	progress_tab:setStrokeColor(0.1)

	local proceed_text = display.newText({text = "Select Ingredient Measurements",
										  x = progress_tab.x + 0.5*progress_tab.width,
										  y = progress_tab.y - 0.5*progress_tab.height,
										  width = 0.8*progress_tab.width,
										  height = 0,
										  fontSize = globalData.smallFontSize,
										  align = "center"})
	proceed_text:setFillColor(unpack(globalData.tab_text_color))
	bottomTabGroup:insert(proceed_text)

	function progress_tab:tap(event)
		-- LOOK TO ALLOW MEASUREMENTS TO STAY WHEN SWITCHING TABS
		for i = 1,left_side_tab._collectorGroup.numChildren,1 do
			if not cookbook.newRecipeIngredientList[left_side_tab._collectorGroup[i].id] then
				cookbook.newRecipeIngredientList[left_side_tab._collectorGroup[i].id] = {amount = 0, unit = "cup", text_amount = "0"}
			end
		end

		globalData.relocateSearchBar(-1000,-1000)
		composer.gotoScene("MeasurementPage")	
	end
	progress_tab:addEventListener("tap", progress_tab)

	local clear_tab = display.newRect(bottomTabGroup, 0, display.contentHeight, 0.5*display.contentWidth, globalData.tab_height)
	clear_tab.anchorX = 0
	clear_tab.anchorY = clear_tab.height
	clear_tab:setFillColor(unpack(globalData.red))
	clear_tab.strokeWidth = 2
	clear_tab:setStrokeColor(0.1)

	local clear_text = display.newText({text = "Clear Ingredients",
										x = clear_tab.x + 0.5*clear_tab.width,
										y = clear_tab.y - 0.5*clear_tab.height,
										width = 0.8*clear_tab.width,
										height = 0,
										fontSize = globalData.smallFontSize,
										align = "center"})

	function clear_tab:tap(event)
		for i = 1,left_side_tab._collectorGroup.numChildren,1 do
			toggleScrollView(left_side_tab._collectorGroup[1])
		end
	end
	clear_tab:addEventListener("tap", clear_tab)

	clear_text:setFillColor(globalData.tab_text_color)
	bottomTabGroup:insert(clear_text)

	scroll_group:insert(left_side_tab)
	scroll_group:insert(right_side_tab)

	sceneGroup:insert(label_group)
	sceneGroup:insert(scroll_group)
	sceneGroup:insert(self.tab_group)
	sceneGroup:insert(bottomTabGroup)
 
 	right_side_tab:insert(display.newRect(0,y_level,1,1))
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		self.tab_group = cookbook.updateTabBar(self.tab_group)
		-- Code here runs when the scene is still off screen (but is about to come on screen)
 
	elseif ( phase == "did" ) then
		globalData.relocateSearchBar(unpack(globalData.search_bar_home))
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