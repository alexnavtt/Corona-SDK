local composer = require("composer")
local cookbook = require("cookbook")
local widget   = require("widget")
local globalData = require("globalData")
local tinker = require("ext_libs.tinker.tinker")
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function createIngredientPanel(foodname, amount_text, unit)
	local group = display.newGroup()

	-- local integer; local numerator; local denominator;
	local integer, numerator, denominator = cookbook.breakdownFraction(amount_text)
	local value = tonumber(integer) + tonumber(numerator)/tonumber(denominator)
	print("Adding panel for " .. foodname)
	print("Integer: " .. integer)
	print("Numerator: " .. numerator)
	print("Denominator: " .. denominator)
	print("Value for " .. foodname .. ": " .. value)

	print(integer .. "+" .. numerator .. "/" .. denominator)
	local bar = display.newRect(group, 0,0,0.9*display.contentWidth, 0.07*display.contentHeight)
	bar:setFillColor(unpack(globalData.selection_color))
	bar:addEventListener("tap", function(event) return true end)

	local food_title = display.newText({text = foodname,
										x = -0.45*bar.width,
										y = 0,
										width = 0.4*bar.width,
										height = 0,
										fontSize = globalData.smallFontSize,
										align = "left"})
	food_title:setFillColor(1)
	food_title.anchorX = 0
	group:insert(food_title)

	-- Resize text to fit
	while food_title.size >= 0.9*bar.height do
		food_title.size = 0.95*food_title.size 
	end

	local div_line_1 = display.newLine(-0.06*bar.width, -0.4*bar.height, -0.06*bar.width, 0.4*bar.height)
	div_line_1:setStrokeColor(1)
	div_line_1.strokeWidth = 2
	group:insert(div_line_1)

	-- Integer Field
	local integer_params = {defaultText = "##", textColor = globalData.light_text_color, backgroundColor = {unpack(globalData.background_color),0.5}, radius = 0.1*bar.height, noUnderline = true, centered = true, isNumeric = true}
	local integer_rect = tinker.newTextField(0.02*bar.width, 0, 0.1*bar.width, 0.75*bar.height, integer_params)
	integer_rect.id = "integer_text"
	group:insert(integer_rect)

	local ampersand = display.newText({text = "&",
									   x = integer_rect.x + 0.08*bar.width,
									   y = integer_rect.y,
									   width = 0,
									   height = 0,
									   fontSize = globalData.smallFontSize,
									   align = "center"})
	group:insert(ampersand)

	-- Numerator Field
	local numerator_rect = tinker.newTextField(0.16*bar.width, -0.2*bar.height, 0.07*bar.width, 0.5*bar.height, integer_params)
	numerator_rect.id = "numerator_text"
	group:insert(numerator_rect)

	-- Denominator Field
	local denominator_rect = tinker.newTextField(0.26*bar.width, 0.2*bar.height, 0.07*bar.width, 0.5*bar.height, integer_params)
	denominator_rect.id = "denominator_text"
	group:insert(denominator_rect)

	if value > 0 then
		print("Appended Values")
		integer_rect:replaceText(integer)
		numerator_rect:replaceText(numerator)
		denominator_rect:replaceText(denominator)
		print("Integer Text: " ..integer_rect.text)
	end

	local divide_line = display.newLine(group, numerator_rect.x, 1.8*denominator_rect.y, denominator_rect.x, 1.8*numerator_rect.y)
	divide_line.strokeWidth = 4

	local div_line_2 = display.newLine(0.33*bar.width, -0.4*bar.height, 0.33*bar.width, 0.4*bar.height)
	div_line_2:setStrokeColor(1)
	div_line_2.strokeWidth = 2
	group:insert(div_line_2)

	local unit_rect = display.newRoundedRect(group, 0.415*bar.width, 0, 0.1*bar.width, 0.75*bar.height, 0.1*bar.height)
	unit_rect:setFillColor(unpack(globalData.background_color), 0.5)

	local unit_text = display.newText({text = unit,
									   x = unit_rect.x,
									   y = unit_rect.y,
									   width = unit_rect.width,
									   height = 0,
									   fontSize = globalData.smallFontSize,
									   align = "center"})
	unit_text.id = "unit_text"
	group:insert(unit_text)

	local unit_group = display.newGroup()
	local left_x = bar.x - 0.5*bar.width

	for i = 1,#cookbook.essential_units,1 do
		local new_unit_rect = display.newRect(unit_group, left_x, bar.y + 0.75*bar.height, (1/#cookbook.essential_units)*bar.width, 0.5*bar.height)
		new_unit_rect:setFillColor(0.1)
		new_unit_rect:setStrokeColor(unpack(globalData.background_color))
		new_unit_rect.anchorX = 0
		new_unit_rect.strokeWidth = 2

		local new_unit_text = display.newText({text = cookbook.essential_units[i], x = left_x + 0.5*new_unit_rect.width, y = new_unit_rect.y, width = new_unit_rect.width, fontSize = globalData.smallFontSize, align = "center"})
		unit_group:insert(new_unit_text)

		function new_unit_rect:tap(event)
			unit_text.text = new_unit_text.text
			globalData.transitionTo(unit_group, unit_group.x, bar.y, 0.3)
		end
		new_unit_rect:addEventListener("tap", new_unit_rect)

		left_x = left_x + (1/#cookbook.essential_units)*bar.width
	end

	group:insert(unit_group)
	unit_group:toBack()

	-- function unit_rect:tap(event)
	-- 	globalData.transitionTo(unit_group, unit_group.x, bar.y + 0.75*bar.height, 0.3)
	-- end
	-- unit_rect:addEventListener("tap", unit_rect)

	function integer_rect:userInput(event)
		if event.phase == "submitted" or event.phase == "ended" then
			numerator_rect:setFocus(true)
		end
	end
	integer_rect:addEventListener("userInput", integer_rect)

	function numerator_rect:userInput(event)
		if event.phase == "submitted" or event.phase == "ended" then
			denominator_rect:setFocus(true)
		end
	end
	numerator_rect:addEventListener("userInput", numerator_rect)


	return group
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)

	-- SCROLL VIEW DEFINITION
	local scroll_options = globalData.scroll_options()
	scroll_options.bottomPadding = 0.8*display.contentHeight
 	self.display_scroll = widget.newScrollView(scroll_options)
 	sceneGroup:insert(self.display_scroll)


 	-- TAB GROUP DEFINITION
 	local tab_bar = cookbook.tempTabBar("Ingredient Measurements", "Back to Ingredient Selection", "IngredientsPage", "Input Steps", "InsertStepsPage")
 	sceneGroup:insert(tab_bar)
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		local y_level = 0.05*self.display_scroll.height
		local y_level_delta = 3*y_level

		for name, value in pairs(cookbook.newRecipeIngredientList) do
			local new_ingredient_panel = createIngredientPanel(name, value.text_amount, value.unit)
			new_ingredient_panel.id = name
			new_ingredient_panel.y = y_level
			new_ingredient_panel.x = display.contentCenterX

			self.display_scroll:insert(new_ingredient_panel)
			y_level = y_level + y_level_delta
		end
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
	 
	elseif ( phase == "did" ) then

		for i = 1,self.display_scroll._collectorGroup.numChildren,1 do
			local ingredient_panel = self.display_scroll._collectorGroup[1]
			tinker.printTable(ingredient_panel)
			local integer_string = cookbook.findID(ingredient_panel, 'integer_text').text
			local numerator_string = cookbook.findID(ingredient_panel, 'numerator_text').text
			local denominator_string = cookbook.findID(ingredient_panel, 'denominator_text').text

			print(integer_string .. " + " .. numerator_string .. "/" .. denominator_string)

			if integer_string == "" then
				integer_string = "0"
			end

			if numerator_string == "" then
				numerator_string = "0"
			end

			if denominator_string == "" then
				denominator_string = "1"
			end

			local has_integer = tonumber(integer_string) > 0
			local has_fraction = (tonumber(numerator_string) > 0) and (tonumber(denominator_string) > 0)

			local text_amount = ""
			if has_integer then
				text_amount = text_amount .. integer_string
			end

			if has_fraction then
				text_amount = text_amount .. " " .. numerator_string .. "/" .. denominator_string
			end

			if text_amount:sub(1,1) == " " then
				text_amount = text_amount:sub(2)
			end

			if text_amount == "" then
				text_amount = "0"
			end

			cookbook.newRecipeIngredientList[ingredient_panel.id].amount = tonumber(integer_string) + tonumber(numerator_string)/tonumber(denominator_string)
			cookbook.newRecipeIngredientList[ingredient_panel.id].unit  = cookbook.findID(ingredient_panel, "unit_text").text
			cookbook.newRecipeIngredientList[ingredient_panel.id].text_amount = text_amount
			self.display_scroll:remove(1)
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