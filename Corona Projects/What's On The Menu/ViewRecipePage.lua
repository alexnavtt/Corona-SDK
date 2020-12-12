local composer = require("composer")
local cookbook = require("cookbook")
local globalData = require("globalData")
local widget = require("widget")
local colors = require("Palette")
local tinker = require("Tinker")
local app_colors = require("AppColours")
local transition = require("transition")
local util = require("GeneralUtility")

local scene = composer.newScene()

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

local options_background
local options
local tapOptions

-----------------------
-- Display Variables --
-----------------------

-- Info Bar
local info_bar_height = 0.05*H

-- Title Banner
local title_banner_height = 0.10*H
local title_banner_bottom = title_banner_height + info_bar_height

-- Scroll Views
local v_spacing = 0.02*H -- vertical spacing
local h_spacing = 0.02*W -- horizontal spacing

local scroll_view_top = title_banner_bottom + v_spacing/2
local scroll_view_height = H - scroll_view_top - v_spacing/2

local scroll_view_left_1 = h_spacing
local scroll_view_width_1 = 0.45*W

local scroll_view_left_2 = scroll_view_left_1 + scroll_view_width_1 + h_spacing
local scroll_view_width_2 = W - scroll_view_width_1 - 3*h_spacing

-- Item Spacing
local div_y  = 0.15*H
local div_x1 = 0.30*W
local div_x2 = div_x1 + 0.13*W

local ingredient_level_delta = 0.1*H
local ingredient_level       = div_y + 0.5*ingredient_level_delta

local step_level_delta = 0.015*H
local step_level = div_y + step_level_delta
local step_count = 1


---------------------
-- Local Functions --
---------------------
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
	local width = 0.9*scroll_view_width_1

	-- Make it look pretty
	for i = 1,#ingredient-2,1 do
		if string.sub(ingredient,i, i) == " " then
			ingredient = ingredient:sub(1,i) .. string.upper(ingredient:sub(i+1,i+1)) .. ingredient:sub(i+2)
		elseif string.sub(ingredient,i, i) == "/" then
			ingredient = ingredient:sub(1,i) .. " " .. ingredient:sub(i+1) 
		end
	end

	-- Still making it look pretty
	ingredient = string.upper(ingredient:sub(1,1)) .. ingredient:sub(2)
	if cookbook.volumes[unit] then 
		unit = string.upper(unit:sub(1,1)) .. unit:sub(2)
	end

	local bkgd = display.newRoundedRect(ingredient_group, 0.05*scroll_view_width_1, ingredient_level, width, 0.6*ingredient_level_delta, 0.1*ingredient_level_delta)
	bkgd:setFillColor(unpack(color))
	bkgd.anchorX = 0

	-- Ingredient Text
	ingredient_text_params = {text = ingredient,
							  x = 0.2*scroll_view_width_1,
							  y = ingredient_level,
							  width = 0.5*scroll_view_width_1,
							  height = 0,
							  font = native.systemFont,
							  fontSize = 0.022*display.contentHeight,
							  align = "left"}
	local ingredient_word = display.newText(ingredient_text_params)
	ingredient_word.anchorX = 0
	ingredient_word:setFillColor(unpack(app_colors.recipe.ing_text))

	while ingredient_word.height > 0.55*ingredient_level_delta do
		ingredient_word.size = 0.9*ingredient_word.size
	end

	local checkBox = newCheckBox(0.11*scroll_view_width_1, ingredient_level, 0.025*W)
	ingredient_group:insert(checkBox)

	function bkgd:tap(event)
		checkBox.listener:dispatchEvent({name = "tap"})
	end
	bkgd:addEventListener("tap", bkgd)

	-- Ingredient Amount Text
	local space = "\n"
	if unit:lower() == "count" then
		unit = ""
		space = ""
	end

	local amount_text_params = {text = amount .. space .. unit,
								x = 0.85*scroll_view_width_1,
								y = ingredient_level,
								width = 0.3*scroll_view_width_1,
								height = 0,
								font = native.systemFont,
								fontSize = 0.02*display.contentHeight,
								align = "center"}
	local ingredient_amount = display.newText(amount_text_params)
	ingredient_amount:setFillColor(unpack(app_colors.recipe.ing_text))
	ingredient_amount.value = amount_number
	ingredient_amount.unit  = unit
	ingredient_amount.food  = ingredient

	if amount == "0" then ingredient_amount.text = "" end

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
		return true
	end
	ingredient_amount:addEventListener("tap", ingredient_amount)

	-- local new_dividing_line = display.newLine(ingredient_group, -display.contentWidth, ingredient_level + 0.5*ingredient_level_delta, div_x2, ingredient_level + 0.5*ingredient_level_delta)
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
						 x = 0.13*(display.contentWidth - div_x2),
						 y = step_level,
						 width = 0,--0.8*(display.contentWidth - div_x2),
						 height = 0,
						 font = native.systemFontBold,
						 fontSize = globalData.titleFontSize,
						 align = "center"}
	local step_title = display.newText(step_title_params)

	step_level = step_level + step_level_delta + step_title.height/2.0

	local step_text_params = {text = step_text,
						x = 0.12*(display.contentWidth - div_x2),
						y = step_level,
						width = 0.8*scroll_view_width_2,
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

local function createOptions(name, scaling_factor)
	local options = display.newGroup()
	options.x = W
	options.y = 0
	options.anchorX = 0
	options.anchorY = 0
	options.anchorChildren = true

	-- Display options
	local width = 0.7*W
	local height = H
	local spacing = 0.035*H
	local y_level = 0

	options.width = width
	options.height = height
	options.state = "hidden"

	local function ypp(dy) 
		dy = dy or spacing
		y_level = y_level + dy 
	end

	-- Visual Start
	local background = display.newRect(options, 0, y_level, width, height)
	background.anchorX = 0
	background.anchorY = 0
	background:addEventListener("tap", function(event) return true end)
	background:setFillColor(unpack(app_colors.medium_color))

	ypp()

	-- Back Button
	local back = display.newImageRect(options, "Image Assets/Small-Black-Up-Arrow-Graphic.png", 0.1*width, 0.1*width)
	back.x = back.width
	back.y = y_level
	back:rotate(270)

	ypp()

	-- Food Image
	local image = display.newRect(options, 0, y_level, width, math.min(width, 0.4*height))
	image.anchorX = 0
	image.anchorY = 0
	
	if globalData.textures[name] then
		image.height = math.min(width*globalData.gallery[name].height/globalData.gallery[name].width, 0.4*height)
		image.fill = {type = "image", filename = globalData.textures[name].filename, baseDir = globalData.textures[name].baseDir}
	else
		image.fill = {type = "image", filename = "Image Assets/Recipe-App-Icon.png"}
	end

	ypp(spacing/2 + image.height)


	-- Food Title
	local food_title = display.newText({text = name,
										x = width/2,
										y = y_level,
										width = 0.8*width,
										fontSize = globalData.titleFontSize,
										font = native.systemFontBold,
										align = "center"})
	food_title:setFillColor(unpack(app_colors.recipe.ing_text))
	food_title.anchorY = 0
	options:insert(food_title)

	ypp(spacing/2 + food_title.height)

	-- globalData.menu[name].calories = 210
	-- globalData.menu[name].servings = 4

	-- Food Info
	if globalData.menu[name].calories then
		local calories = display.newText({	text = "- Calories: " .. globalData.menu[name].calories .. " kCal",
											x = 0.5*width, 
											y = y_level,
											width = 0.8*width,
											fontSize = globalData.smallFontSize,
											align = "left"})

		calories:setFillColor(unpack(app_colors.recipe.ing_text))
		calories.anchorY = 0
		options:insert(calories)
		ypp(calories.height)
	end

	if globalData.menu[name].servings then
		local servings = display.newText({	text = "- Serves:   " .. globalData.menu[name].servings,
											x = 0.5*width,
											y = y_level,
											width = 0.8*width,
											fontSize = globalData.smallFontSize,
											align = "left"})

		servings:setFillColor(unpack(app_colors.recipe.ing_text))
		servings.anchorY = 0
		options:insert(servings)
		ypp(servings.height)
	end

	ypp()


	-- Favourite Icon
	local favourite_text = display.newText({text = "Favourite",
											x = 0.05*width,
											y = y_level,
											width = 0.8*width,
											fontSize = globalData.mediumFontSize,
											font = native.systemFontBold})
	options:insert(favourite_text)	
	favourite_text.anchorX = 0
	favourite_text:setFillColor(unpack(app_colors.recipe.ing_text))

	local star = display.newRect(options, favourite_text.width + 0.5*(width - favourite_text.width), y_level, 1.5*favourite_text.height, 1.5*favourite_text.height)

	if globalData.favourites[name] then
		star.fill = {type = "image", filename = "Image Assets/Small-Star.png"}
	else
		star.fill = {type = "image", filename = "Image Assets/Small-Empty Star.png"}
	end

	local function starTap(event)
		if globalData.favourites[name] then
			globalData.favourites[name] = nil
			star.fill = {type = "image", filename = "Image Assets/Small-Empty Star.png"}
		else
			globalData.favourites[name] = true
			star.fill = {type = "image", filename = "Image Assets/Small-Star.png"}
		end
	end
	star:addEventListener("tap", starTap)

	ypp(2*spacing)

	-- Edit Icon
	local edit = display.newText({	text = "Edit",
									x = favourite_text.x,
									y = y_level,
									width = favourite_text.width,
									font = native.systemFontBold,
									fontSize = globalData.mediumFontSize})
	edit:setFillColor(unpack(app_colors.recipe.ing_text))
	edit.anchorX = 0
	options:insert(edit)

	local edit_image = "Image Assets/Edit-Graphic.jpg"
	if app_colors.scheme == "dark" then edit_image = "Image Assets/White-Edit-Graphic.png" end
	local edit_icon = display.newImageRect(options,edit_image, star.width, star.height)
	edit_icon.x = star.x
	edit_icon.y = y_level

	edit_icon:addEventListener("tap", function(event) scene.glass_screen:dispatchEvent({name = "tap"}); return cookbook.editRecipe(name) end)

	ypp(3*spacing)

	-- Double And Half Buttons
	local function doubleIt(event)
		scene.glass_screen.alpha = 0
		composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = 2*scaling_factor}})
	end
	local double_params = {	color = app_colors.contrast_color, 
							label = "Double Recipe", 
							labelColor = app_colors.recipe.title_text,
							font = native.systemFontBold,
							fontSize = globalData.mediumFontSize,
							radius = 0.1*spacing,
							strokeWidth = 4,
							strokeColor = {0},
							displayGroup = options,
							tap_func = doubleIt}
	local double = tinker.newButton(0.5*width, y_level, 0.8*width, 1.3*spacing, double_params)

	ypp(2*spacing)

	local function halfIt(event)
		scene.glass_screen.alpha = 0
		composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = 0.5*scaling_factor}})
	end
	local half_params = double_params
	half_params.label = "Half Recipe"
	half_params.tap_func = halfIt
	local half = tinker.newButton(0.5*width, y_level, 0.8*width, 1.3*spacing, half_params)

	ypp()

	-- Delete Icon
	local delete_text = display.newText({	text = "Delete",
											x = edit.x,
											y = height - spacing,
											font = native.systemFontBold,
											fontSize = globalData.mediumFontSize})
	delete_text:setFillColor(unpack(app_colors.recipe.ing_text))
	delete_text.anchorX = 0
	options:insert(delete_text)

	local delete_image = "Image Assets/Trash-Graphic-Simple.png"
	if app_colors.scheme == "dark" then delete_image = "Image Assets/White-Trash-Graphic.png" end
	local delete = display.newImageRect(options, delete_image, star.width, star.height)
	delete.x = star.x
	delete.y = delete_text.y

	-- Function To Delete a Food From Memory
	function delete:tap(event)
		local function trash_listener(event)
			if event.index == 1 then 
				scene.glass_screen:dispatchEvent({name = "tap"})
				globalData.menu[name] = nil
				globalData.favourites[name] = nil
				globalData.writeCustomMenu()
				globalData.deleteFoodImage(name)
				composer.gotoScene(globalData.activeScene)
			end
		end
		native.showAlert("What's On The Menu", "Are you sure you want to delete \"" .. name .. "\"?", {"Yes, I'm Sure", "Cancel"}, trash_listener )

		return true
	end
	delete:addEventListener("tap", delete)

	function options:toggle()
		if self.state == "hidden" then
			transition.to(self, {time = 200, x = W - width})
			transition.to(back, {time = 500, rotation = 90})
			self.state = "visible"
		else
			transition.to(self, {time = 200, x = W})
			transition.to(back, {time = 500, rotation = 270})
			self.state = "hidden"
		end

		return true
	end
	
	back:addEventListener("tap", function(e) scene.glass_screen:dispatchEvent({name = "tap"}) end)

	return options
end


-- /////////////////////////////// --
-- 			SCENE BEGIN			   --
-- /////////////////////////////// --
function scene:create( event )
 
	local sceneGroup = self.view
	local name = event.params.name

	local background = display.newRect(sceneGroup, cX, cY, W, H)
	background:setFillColor(unpack(app_colors.recipe.background))

	self.glass_screen = display.newRect(sceneGroup, cX, cY, W, H)
	self.glass_screen:setFillColor(0)
	self.glass_screen.alpha = 0
	self.glass_screen:toBack()
	self.glass_screen:addEventListener("tap", function(event) self.glass_screen.alpha = 0; options:toggle(); return true end)

	local top_bar = display.newRect(sceneGroup, 0, 0, display.contentWidth, info_bar_height)
	top_bar.anchorX = 0
	top_bar.anchorY = 0
	top_bar:setFillColor(0)

	local title_background = display.newRect(sceneGroup, 0, info_bar_height, display.contentWidth, title_banner_height)
	title_background.anchorX = 0
	title_background.anchorY = 0
	title_background:setFillColor(unpack(app_colors.recipe.title_bkgd))

	self.ingredient_panel = widget.newScrollView({top = scroll_view_top + v_spacing, left = scroll_view_left_1,
											  width = scroll_view_width_1,
											  height = scroll_view_height - 2*v_spacing,
											  horizontalScrollDisabled = true,
											  isBounceEnabled = false,
											  backgroundColor = app_colors.recipe.ing_background,
											  hideBackground = true,
											  bottomPadding = 0.1*display.contentWidth})
	sceneGroup:insert(self.ingredient_panel)

	local ingredient_bkgd = display.newRoundedRect(sceneGroup, self.ingredient_panel.x, self.ingredient_panel.y, self.ingredient_panel.width, self.ingredient_panel.height + 2*v_spacing, 0.05*W)
	ingredient_bkgd:setFillColor(unpack(app_colors.recipe.ing_background))
	ingredient_bkgd:toBack()

	self.instruction_panel = widget.newScrollView({top = scroll_view_top + v_spacing, left = scroll_view_left_2,
												    width = scroll_view_width_2,
												    height = scroll_view_height - 2*v_spacing,
												    horizontalScrollDisabled = true,
												    isBounceEnabled = false,
												    backgroundColor = app_colors.recipe.step_bkgd,
												    hideBackground = true,
												    bottomPadding = 0.3*display.contentWidth})
	sceneGroup:insert(self.instruction_panel)

	local instruction_bkgd = display.newRoundedRect(sceneGroup, self.instruction_panel.x, self.instruction_panel.y, self.instruction_panel.width, self.instruction_panel.height + 2*v_spacing, 0.05*W)
	instruction_bkgd:setFillColor(unpack(app_colors.recipe.step_bkgd))
	instruction_bkgd:toBack()

	local back_button = display.newRect(sceneGroup, 0.025*W, 0.5*info_bar_height, 0.25*W, 0.9*info_bar_height)
	back_button.anchorX = 0
	back_button.alpha = 0.01

	local back_arrow = display.newImageRect(sceneGroup, "Image Assets/Small-White-Up-Arrow-Graphic.png", 0.6*info_bar_height, 0.6*info_bar_height)
	back_arrow.x = back_button.x + 0.6*back_arrow.width
	back_arrow.y = back_button.y
	back_arrow:rotate(270)

	local back_text = display.newText({	text = "Return",
										x = back_arrow.x + back_arrow.width,
										y = back_arrow.y,
										fontSize = globalData.titleFontSize,
										align = "left"})
	back_text.anchorX = 0
	back_text:setFillColor(1)
	sceneGroup:insert(back_text)

	local function goBack(event)
		composer.gotoScene(globalData.activeScene, {effect = "slideLeft", time = globalData.transition_time})
	end
	back_button:addEventListener("tap", goBack)

	-- Options Popout
	local options_icon = display.newGroup()
	sceneGroup:insert(options_icon)

	options_background = display.newRect(options_icon, 0.95*W, 0.5*info_bar_height, 0.06*W, info_bar_height)
	options_background.alpha = 0.01

	for i = 1,3,1 do
		local L = display.newLine(options_icon, 0.92*W, i*0.25*info_bar_height, 0.98*W, i*0.25*info_bar_height)
		L.strokeWidth = 5
	end

 	background:toBack()
end
 
 
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
	local name = event.params.name
	local scaling_factor = math.max(0.25,math.min(event.params.scaling_factor or 1, 4))

	local ingredient_level_delta = 0.1*display.contentHeight
	local ingredient_level = 0.5*ingredient_level_delta
	local step_level_delta = 0.015*display.contentHeight
	local step_level = 2*step_level_delta
 
	if ( phase == "will" ) then
		transition.to(globalData.tab_bar, {alpha = 0, time = 0.8*globalData.transition_time})
		local ingredient_group = display.newGroup()
		local step_group = display.newGroup()
		self.recipe_group = display.newGroup()
		self.recipe_group:insert(ingredient_group)
		self.recipe_group:insert(step_group)
		sceneGroup:insert(self.recipe_group)

		globalData.relocateSearchBar(-500, -500)

		-- Section Title Generation --
		title_text_params = {text = event.params.name,
							 x = 0.05*W,
							 y = info_bar_height + title_banner_height/2,
							 height = 0,
							 width = 0.7*display.contentWidth,
							 font = native.systemFontBold,
							 fontSize = 0.05*display.contentHeight,
							 align = "left"}
		local title = display.newText(title_text_params)
		title:setFillColor(unpack(app_colors.recipe.title_text))
		title.anchorX = 0
		self.recipe_group:insert(title)

		while title.height > 0.9*title_banner_height do
			title.size = 0.99*title.size
		end

		local scale_text = display.newText({text = "x" .. cookbook.getFraction(scaling_factor),
											x = title.x + title.width + 0.02*W, y = title.y,
											fontSize = globalData.smallFontSize,
											align = "center"})
		scale_text:setFillColor(unpack(app_colors.recipe.title_text))
		self.recipe_group:insert(scale_text)

		print("view page:")
		print(globalData.active_recipe)

		local ing_colors = {app_colors.recipe.ingredient_1, app_colors.recipe.ingredient_2}
		local i = 0

		local ingredients = globalData.menu[name].ingredients

		-- Sort Ingredients Alphabetically
		local ingredient_names = {}
		for j = 1,#ingredients,1 do
			ingredient_names[ingredients[j].name] = j
		end
		local sorted_ingredients = util.sortTableKeys(ingredient_names)

		-- Insert Each Ingredient 1 by 1
		for j = 1,#sorted_ingredients,1 do
			local table_val = ingredients[ingredient_names[sorted_ingredients[j]]]

			local text_amount = table_val.text_amount
			print("THIS" .. text_amount)
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

		-- local button_params = {label = "Double It", color = app_colors.recipe.measure_buttons, tap_func = function(event) composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = scaling_factor*2}}) end, displayGroup = self.ingredient_panel, strokeWidth = 3}
		-- local double_button = tinker.newButton(0, ingredient_level - 0.25*ingredient_level_delta, 0.5*div_x2, 0.5*ingredient_level_delta, button_params)
		-- double_button.anchorX = 0

		-- button_params.label = "Half It"
		-- button_params.tap_func = function(event) composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = scaling_factor*0.5}}) end
		-- local half_button = tinker.newButton(div_x2, ingredient_level - 0.25*ingredient_level_delta, 0.5*div_x2, 0.5*ingredient_level_delta, button_params)
		-- half_button.anchorX = half_button.width

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

		-- if globalData.favourites[name] then
		-- 	self.favourite_icon:replaceImage("Image Assets/Small-Star.png")
		-- else
		-- 	self.favourite_icon:replaceImage("Image Assets/Small-Empty Star.png")
		-- end

	elseif ( phase == "did" ) then
		self.glass_screen:toFront()
		options = createOptions(name, scaling_factor)

		function tapOptions(event)
			scene.glass_screen.alpha = 0.5
			return(options:toggle())
		end
		options_background:addEventListener("tap", tapOptions)
 
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

		options:removeSelf()
		options_background:removeEventListener("tap", tapOptions)
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