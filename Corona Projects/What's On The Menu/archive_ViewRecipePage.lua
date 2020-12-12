local composer = require("composer")
local cookbook = require("cookbook")
local globalData = require("globalData")
local widget = require("widget")
local colors = require("Palette")
local tinker = require("Tinker")
local app_colors = require("AppColours")
local scene = composer.newScene()


local function newCheckBox(x, y, size)
	local group = display.newGroup()
	group.x = x
	group.y = y
	group.anchorChildren = true

	local big_box = display.newRect(group, 0, 0, 3*size, 3*size)
	big_box.alpha = 0.01

	local box = display.newRect(group, 0, 0, size, size)
	box:setFillColor(0,0,0,0.5)
	box:setStrokeColor(1)
	box.strokeWidth = 3
	box.tapped = false

	local check

	function big_box:tap(event)
		self.tapped = not self.tapped

		if self.tapped then
			if not check then
				check = display.newImageRect(group, "Image Assets/Check-Graphic.png", 1.6*size, 1.4*size)
				check:translate(0.2*size, -0.4*size)
			end
			check.alpha = 1
		else
			check.alpha = 0
		end

		return true
	end
	big_box:addEventListener("tap", big_box)

	group.listener = big_box
	return group
end

local function insertIngredient(ingredient, amount, unit, amount_number, ingredient_level, ingredient_level_delta, color)
	local ingredient_group = display.newGroup()

	-- Make it look pretty
	for i = 1,#ingredient-2,1 do
		if string.sub(ingredient,i, i) == " " then
			ingredient = ingredient:sub(1,i) .. string.upper(ingredient:sub(i+1,i+1)) .. ingredient:sub(i+2)
		end
	end

	-- Still making it look pretty
	ingredient = string.upper(ingredient:sub(1,1)) .. ingredient:sub(2)
	if cookbook.volumes[unit] then 
		unit = string.upper(unit:sub(1,1)) .. unit:sub(2)
	end

	local bkgd = display.newRect(ingredient_group, 0, ingredient_level, cookbook.div_x2, ingredient_level_delta)
	bkgd:setFillColor(unpack(color))
	bkgd.anchorX = 0

	-- Ingredient Text
	ingredient_text_params = {text = ingredient,
							  x = 0.3*cookbook.div_x1,
							  y = ingredient_level,
							  width = 0.75*cookbook.div_x1,
							  height = 0,
							  font = native.systemFont,
							  fontSize = 0.025*display.contentHeight,
							  align = "left"}
	local ingredient_word = display.newText(ingredient_text_params)
	ingredient_word.anchorX = 0
	ingredient_word:setFillColor(unpack(app_colors.recipe.ing_text))

	while ingredient_word.height > ingredient_level_delta do
		ingredient_word.size = 0.9*ingredient_word.size
	end

	local checkBox = newCheckBox(0.15*cookbook.div_x1, ingredient_level, 0.1*cookbook.div_x1)
	ingredient_group:insert(checkBox)

	function ingredient_word:tap(event)
		checkBox.listener:dispatchEvent({name = "tap"})
	end
	ingredient_word:addEventListener("tap", ingredient_word)

	-- Ingredient Amount Text
	if unit:lower() == "count" then
		unit = ""
	end

	local amount_text_params = {text = amount .. "\n" .. unit,
								x = 0.5*(cookbook.div_x1 + cookbook.div_x2),
								y = ingredient_level,
								width = 0.9*(cookbook.div_x2 - cookbook.div_x1),
								height = 0,
								font = native.systemFont,
								fontSize = 0.025*display.contentHeight,
								align = "center"}
	local ingredient_amount = display.newText(amount_text_params)
	ingredient_amount:setFillColor(unpack(app_colors.recipe.ing_text))
	ingredient_amount.value = amount_number
	ingredient_amount.unit  = unit
	ingredient_amount.food  = ingredient

	function ingredient_amount:tap(event)
		if not self.value then
			return true
		end

		local old_value = self.value
		local old_unit  = self.unit
		local food_name = self.food

		local abs_x, abs_y = self:localToContent(self.x, self.y)
		print(display.contentHeight)
		print(string.format("(%d,%d)",abs_x,abs_y))
		cookbook.showUnitCircle(old_unit, self, old_value, food_name)
	end
	ingredient_amount:addEventListener("tap", ingredient_amount)

	-- local new_dividing_line = display.newLine(ingredient_group, -display.contentWidth, ingredient_level + 0.5*ingredient_level_delta, cookbook.div_x2, ingredient_level + 0.5*ingredient_level_delta)
	-- new_dividing_line.strokeWidth = 2
	-- new_dividing_line:setStrokeColor(unpack(globalData.outline_color))

	ingredient_group:insert(ingredient_word)
	ingredient_group:insert(ingredient_amount)

	return ingredient_group

end

local function insertStep(step_text, step_level, step_level_delta, step_count)
	local step_group = display.newGroup()

	if step_text == "" or step_text == nil then
		return
	end

	local step_title_params = {text = "Step " .. step_count,
						 x = 0.13*(display.contentWidth - cookbook.div_x2),
						 y = step_level,
						 width = 0,--0.8*(display.contentWidth - cookbook.div_x2),
						 height = 0,
						 font = native.systemFontBold,
						 fontSize = globalData.titleFontSize,
						 align = "center"}
	local step_title = display.newText(step_title_params)

	step_level = step_level + step_level_delta + step_title.height/2.0

	local step_text_params = {text = step_text,
						x = 0.12*(display.contentWidth - cookbook.div_x2),
						y = step_level,
						width = 0.8*(display.contentWidth - cookbook.div_x2),
						height = 0,
						font = native.systemFont,
						fontSize = 0.025*display.contentHeight}

	local step_text_paragraph = display.newText(step_text_params)
	step_text_paragraph.id = "step_text"

	step_title:setFillColor(unpack(app_colors.recipe.step_text))
	step_title.anchorX = 0
	step_text_paragraph:setFillColor(unpack(app_colors.recipe.step_text))
	step_text_paragraph.anchorX = 0
	step_text_paragraph.anchorY = 0

	local checkBox = newCheckBox(0.5*(step_title.x), step_title.y, 0.33*(step_title.x))

	function step_title:tap(event)
		checkBox.listener:dispatchEvent({name = "tap"})
	end
	step_title:addEventListener("tap", step_title)

	step_group:insert(checkBox)
	step_group:insert(step_title)
	step_group:insert(step_text_paragraph)

	return step_group
end

-- /////////////////////////////// --
-- 			SCENE BEGIN			   --
-- /////////////////////////////// --
function scene:create( event )
 
	local sceneGroup = self.view
	local name = event.params.name

	local title_background = display.newRect(sceneGroup, 0, 0, display.contentWidth, cookbook.div_y)
	title_background.anchorX = 0
	title_background.anchorY = 0
	title_background:setFillColor(unpack(app_colors.recipe.title_bkgd))

	local back_button = display.newRect(sceneGroup, display.contentWidth, 0, 0.15*display.contentWidth, 0.5*cookbook.div_y)
	back_button.anchorX = back_button.width
	back_button.anchorY = 0
	back_button:setFillColor(unpack(app_colors.recipe.back_button))

	local favourite_button = display.newRect(sceneGroup, display.contentWidth, back_button.height, back_button.width, back_button.height)
	favourite_button.anchorX = favourite_button.width
	favourite_button.anchorY = 0
	favourite_button:setFillColor(unpack(app_colors.recipe.star_button))

	self.instruction_panel = widget.newScrollView({top = cookbook.div_y, left = cookbook.div_x2,
												    width = display.contentWidth - cookbook.div_x2,
												    height = display.contentHeight - cookbook.div_y,
												    horizontalScrollDisabled = true,
												    isBounceEnabled = false,
												    backgroundColor = app_colors.recipe.step_bkgd,
												    hideBackground = false,
												    bottomPadding = 0.3*display.contentWidth})
	sceneGroup:insert(self.instruction_panel)

	self.ingredient_panel = widget.newScrollView({top = cookbook.div_y, left = 0,
											  width = cookbook.div_x2,
											  height = display.contentHeight - cookbook.div_y,
											  horizontalScrollDisabled = true,
											  isBounceEnabled = false,
											  backgroundColor = app_colors.recipe.ing_background,
											  hideBackground = false,
											  bottomPadding = 0.05*display.contentWidth})
	sceneGroup:insert(self.ingredient_panel)

	local small_div_line1 = display.newLine(sceneGroup, display.contentWidth - back_button.width, 0, display.contentWidth - back_button.width, cookbook.div_y)
	small_div_line1.strokeWidth = 3
	small_div_line1:setStrokeColor(unpack(app_colors.recipe.outline))

	local small_div_line2 = display.newLine(sceneGroup, display.contentWidth - back_button.width, back_button.height, display.contentWidth, back_button.height)
	small_div_line2.strokeWidth = 3
	small_div_line2:setStrokeColor(unpack(app_colors.recipe.outline))

	-- local vertical_dividing_line1 = display.newLine(sceneGroup, cookbook.div_x1, cookbook.div_y, cookbook.div_x1, display.contentHeight)
	-- vertical_dividing_line1.strokeWidth = 2
	-- vertical_dividing_line1:setStrokeColor(unpack(globalData.outline_color))

	local vertical_dividing_line2 = display.newLine(sceneGroup, cookbook.div_x2, cookbook.div_y, cookbook.div_x2, display.contentHeight)
	vertical_dividing_line2.strokeWidth = 3
	vertical_dividing_line2:setStrokeColor(unpack(app_colors.recipe.outline))

	local move_tab_line = display.newRect(sceneGroup, cookbook.div_x2, cookbook.div_y, 0.05*display.contentWidth, display.contentHeight - cookbook.div_y)
	move_tab_line:setFillColor(1,1,1,0.01)
	move_tab_line.anchorY = 0

	local horizontal_dividing_line = display.newLine(sceneGroup, 0, cookbook.div_y, display.contentWidth, cookbook.div_y)
	horizontal_dividing_line.strokeWidth = 3
	horizontal_dividing_line:setStrokeColor(unpack(app_colors.recipe.outline))

	-- Image Asset Load --
	local unfavourite_icon = display.newImageRect(sceneGroup, "Image Assets/Small-Empty Star.png", 0.6*favourite_button.width, 0.6*favourite_button.width)
	unfavourite_icon.x = favourite_button.x - favourite_button.width/2
	unfavourite_icon.y = favourite_button.y + favourite_button.height/2

	local favourite_icon = display.newImageRect(sceneGroup, "Image Assets/Small-Star.png", 0.6*favourite_button.width, 0.6*favourite_button.width)
	favourite_icon.x = favourite_button.x - favourite_button.width/2
	favourite_icon.y = favourite_button.y + favourite_button.height/2
	if not globalData.favourites[name] then
		favourite_icon.alpha = 0
	end

	function unfavourite_icon:tap(event)
		if globalData.favourites[name] then
			globalData.favourites[name] = nil
			favourite_icon.alpha = 0
		else
			globalData.favourites[name] = true
			favourite_icon.alpha = 1
		end
	end
	unfavourite_icon:addEventListener("tap", unfavourite_icon)

	back_text_params = {text = "Back",
						x = back_button.x - 0.5*back_button.width,
						y = back_button.y + 0.5*back_button.height,
						height = 0,
						width = 0,
						font = native.systemFont,
						fontSize = 0.02*display.contentHeight,
						align = "center"}
	back_text = display.newText(back_text_params)
	back_text:setFillColor(unpack(app_colors.recipe.back_text))
	sceneGroup:insert(back_text)

	local big_self = self
	function back_button:tap(event)
		big_self.recipe_group:removeSelf()
		composer.gotoScene(globalData.activeScene, {effect = "slideLeft", time = 300})
	end
	back_button:addEventListener("tap", back_button)
 
 	-- sceneGroup:insert(scene.recipe_group)
end
 
 
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
	local name = event.params.name
	local scaling_factor = math.max(0.25,math.min(event.params.scaling_factor or 1, 4))

	local ingredient_level_delta = 0.1*display.contentHeight
	local ingredient_level = 0.5*ingredient_level_delta
	local step_level_delta = 0.015*display.contentHeight
	local step_level = 2*cookbook.step_level_delta
 
	if ( phase == "will" ) then
		local ingredient_group = display.newGroup()
		local step_group = display.newGroup()
		self.recipe_group = display.newGroup()
		self.recipe_group:insert(ingredient_group)
		self.recipe_group:insert(step_group)
		sceneGroup:insert(self.recipe_group)

		globalData.relocateSearchBar(-500, -500)

		-- Section Title Generation --
		title_text_params = {text = event.params.name,
							 x = 0.4*display.contentWidth,
							 y = 0.07*display.contentHeight,
							 height = 0,
							 width = 0.8*display.contentWidth,
							 font = native.systemFontBold,
							 fontSize = 0.05*display.contentHeight,
							 align = "center"}
		local title = display.newText(title_text_params)
		title:setFillColor(unpack(app_colors.recipe.title_text))
		self.recipe_group:insert(title)

		local scale_text = display.newText({text = "x" .. cookbook.getFraction(scaling_factor),
											x = title.x, y = 0.9*cookbook.div_y,
											fontSize = globalData.smallFontSize,
											align = "center"})
		scale_text:setFillColor(unpack(app_colors.recipe.title_text))
		self.recipe_group:insert(scale_text)

		print("view page:")
		print(globalData.active_recipe)

		local ing_colors = {app_colors.recipe.ingredient_1, app_colors.recipe.ingredient_2}
		local i = 0

		for index, table_val in pairs(globalData.menu[name].ingredients) do

			local text_amount = table_val.text_amount
			local amount = table_val.amount

			if scaling_factor ~= 1 then
				if amount then
					amount = amount*scaling_factor
					text_amount = cookbook.getFraction(amount)
				end
			end

			local new_ingredient = insertIngredient(table_val.name, text_amount, table_val.unit, amount, ingredient_level, ingredient_level_delta, ing_colors[i+1])
			self.ingredient_panel:insert(new_ingredient)

			ingredient_level = ingredient_level + ingredient_level_delta
			i = 1 - i
		end

		local button_params = {label = "Double It", color = app_colors.recipe.measure_buttons, tap_func = function(event) composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = scaling_factor*2}}) end, displayGroup = self.ingredient_panel, strokeWidth = 3}
		local double_button = tinker.newButton(0, ingredient_level - 0.25*ingredient_level_delta, 0.5*cookbook.div_x2, 0.5*ingredient_level_delta, button_params)
		double_button.anchorX = 0

		button_params.label = "Half It"
		button_params.tap_func = function(event) composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = scaling_factor*0.5}}) end
		local half_button = tinker.newButton(cookbook.div_x2, ingredient_level - 0.25*ingredient_level_delta, 0.5*cookbook.div_x2, 0.5*ingredient_level_delta, button_params)
		half_button.anchorX = half_button.width

		for index, table_val in pairs(globalData.menu[name].steps) do
			local new_step = insertStep(table_val, step_level, step_level_delta, index)
			self.instruction_panel:insert(new_step)

			step_level = step_level + step_level_delta + new_step.height
		end 


		local bkgd = display.newImageRect("Image Assets/Papyrus-Texture.jpg", display.contentWidth, self.instruction_panel.height)
		bkgd.x = display.contentCenterX
		bkgd.y = self.instruction_panel.y
		sceneGroup:insert(bkgd)
		bkgd:toBack()

	elseif ( phase == "did" ) then
		-- Touch Listener Functions
 
	end
end
 
 
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
 
	elseif ( phase == "did" ) then
		for i = 1,self.ingredient_panel._collectorGroup.numChildren,1 do
			self.ingredient_panel:remove(1)
		end

		for i = 1,self.instruction_panel._collectorGroup.numChildren,1 do
			self.instruction_panel:remove(1)
		end

		self.recipe_group:removeSelf()
	end
end
 
 
function scene:destroy( event )
 
	local sceneGroup = self.view 
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