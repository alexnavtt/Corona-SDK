-- Custom library for the cookbook app
local cookbook = {}
local globalData = require("globalData")
local widget = require("widget")
local composer = require("composer")
local json = require("json")
local tinker = require("Tinker")
local colors = require("Palette")
local app_colors = require("AppColours")
local transition = require("transition")


-- Foods and Ingredients ----------------------------------
local foods = require("Cookbook.cookbook_foods")
cookbook.common_ingredients = foods.common_ingredients
cookbook.meats 				= foods.meats
cookbook.fruits_and_veggies = foods.fruits_and_veggies
cookbook.starches 			= foods.starches
cookbook.seasonings 		= foods.seasonings
cookbook.dairy 				= foods.dairy
cookbook.sauces 			= foods.sauces
cookbook.nuts 				= foods.nuts
-- ========================================================



-- Measurements and Conversions ---------------------------
local measurements = require("Cookbook.cookbook_measurements")
cookbook.densities 		 = measurements.densities
cookbook.essential_units = measurements.essential_units
cookbook.volumes 		 = measurements.volumes
cookbook.masses  		 = measurements.masses
cookbook.convertFromCup  = measurements.convertFromCup
cookbook.convertFromGram = measurements.convertFromGram

-- Populate the ingredient list with the imported foods
cookbook.ingredientList = {}
local categories = {"common_ingredients", "meats", "fruits_and_veggies", "dairy", "nuts", "sauces", "seasonings", "starches"} 
for i = 1,#categories,1 do
	for food, value in pairs(cookbook[categories[i]]) do
		cookbook.ingredientList[food] = true
	end
end
-- ========================================================



-- NEW RECIPE STUFF
cookbook.newRecipeTitle = "test-recipe"
cookbook.newRecipeIngredientList = {}
cookbook.newIngredient = {amount = 0, unit = "Cup", text_amount = "0"}
cookbook.newRecipeSteps = {}
cookbook.newRecipeKeywords = {}
cookbook.newRecipeParams = {}

-- EDIT RECIPE STUFF
cookbook.is_editing = false

-- BECAUSE I'M BAD AT PLANNING
cookbook.div_y  = 0.15*display.contentHeight
cookbook.div_x1 = 0.3*display.contentWidth
cookbook.div_x2 = cookbook.div_x1 + 0.13*display.contentWidth

cookbook.ingredient_level_delta = 0.1*display.contentHeight
cookbook.ingredient_level = cookbook.div_y + 0.5*cookbook.ingredient_level_delta

cookbook.step_level_delta = 0.015*display.contentHeight
cookbook.step_level = cookbook.div_y + cookbook.step_level_delta
cookbook.step_count = 1

cookbook.sub_line_color = {0.8, 0.8, 0.8}
cookbook.major_line_color = {0.3, 0.3, 0.3}


function cookbook.findRecipe(search_word)
	search_word = search_word:lower()
	key_options = {}
	result_options = {}

	local word_length = #search_word

	for key, food_list in pairs(globalData.keywords) do

		if key == search_word then
			table.insert(key_options, key)
			print("Found it exactly")
		end

		for i = 1,(#key),1 do
			if key:sub(i,i+word_length-1) == search_word then
				table.insert(key_options, key)
				print("Found it: " .. key)
			end
		end
	end

	for index, keyword in pairs(key_options) do
		for index, food in pairs(globalData.keywords[keyword]) do
			result_options[food] = true
		end
	end

	return(result_options)
end


function cookbook.searchMenu(search_word)
	search_word = search_word:lower()
	result_options = {}

	local word_length = #search_word

	for foodname, value in pairs(globalData.menu) do

		-- print(foodname)
		-- foodname = foodname:lower()

		if foodname:lower() == search_word then
			result_options[foodname] = true
			-- print("Found it exactly")
		end

		for i = 1,#foodname,1 do 
			if foodname:lower():sub(i,i+word_length-1) == search_word then
				result_options[foodname] = true
				-- print("Found it")
			end
		end

	end

	return(result_options)
end 

function cookbook.searchIngredients(search_word)
	search_word = search_word:lower()
	result_options = {}

	if search_word == "" then
		return {}
	end

	local word_length = #search_word

	for foodname, value in pairs(cookbook.ingredientList) do

		-- print(foodname)
		-- foodname = foodname:lower()

		if foodname:lower() == search_word then
			result_options[foodname] = true
			-- print("Found it exactly")
		end

		for i = 1,#foodname,1 do 
			if foodname:lower():sub(i,i+word_length-1) == search_word then
				result_options[foodname] = true
				-- print("Found it")
			end
		end

	end

	return(result_options)
end 



function cookbook.createTabBar()
	local tab_group  = display.newGroup()
	local tab_height = globalData.tab_height
	local width = 0.8*display.contentWidth

	local tab_titles 	= {'Cookbook','Favourites','New Recipe'} --,'Settings'} --'Custom Search'
	local page_titles 	= {"BrowsePage", "FavouritesPage", "NewRecipePage", "Settings"} -- "CustomPage",
	local icon_paths 	= {"Small-Recipe-App-Icon-Transparent.png", "Small-Star.png", "Small-Recipe-Card-Graphic.png", "Small-Settings-Graphic.png"}
	local num_tabs 		= #tab_titles

	local tab_bar = display.newRoundedRect(tab_group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height, 0.00*display.contentWidth)
	tab_bar:setFillColor(unpack(app_colors.tab_bar.background))
	tab_bar:setStrokeColor(unpack(app_colors.tab_bar.outline))

	local shadow = display.newRect(tab_group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height)
	shadow:setFillColor(0,0,0,0.2)
	shadow:translate(0, 0.1*tab_height)
	shadow:toBack()

	local underline = display.newLine(tab_group, 0, tab_height, display.contentWidth, tab_height)
	underline.strokeWidth = 4
	underline:setStrokeColor(unpack(app_colors.recipe.outline))

	-- Find the direction to transition in order to move pages naturally
	local function findDirection(last_name, this_name)
		local last_index, this_index

		if this_name == "Settings" then return "slideRight" end

		for i = 1,#page_titles,1 do
			if page_titles[i] == last_name then
				last_index = i
			end

			if page_titles[i] == this_name then
				this_index = i
			end
		end

		if last_index < this_index then
			return "slideLeft"
		elseif last_index > this_index then
			return "slideRight"
		else
			return nil
		end
	end

	local icon_height 	= 0.07*display.contentWidth
	local icon_spacing 	= 0.1*display.contentWidth
	local icon_loc		= 0.7*icon_spacing

	local tab_width  = 1/num_tabs*width

	local buttons = {}
	local active_index = 4

	for i = 1,num_tabs,1 do
		local button

		local function onTap(event)
			local old_one = globalData.activeScene
			if old_one == page_titles[i] then return true end

			globalData.activeScene = page_titles[i]
			for i = 1,#buttons,1 do
				buttons[i]:setBackgroundColor({1,1,1,0.1})
				if i == #buttons then buttons[i]:setBackgroundColor({1,1,1,0.01}) end
			end
			button:setBackgroundColor({1,1,1,0.2})
			composer.gotoScene(page_titles[i], {effect = findDirection(old_one, page_titles[i]), time = globalData.transition_time})
			return true
		end 

		local options = {label = tab_titles[i], color = {1,1,1,0.1}, labelColor = app_colors.tab_bar.button_text, tap_func = onTap, fontSize = globalData.smallFontSize, displayGroup = tab_group, font = native.systemFontBold, radius = 30}
		button = tinker.newButton((i-1)*tab_width + tab_width/2, 0.5*tab_height, 0.8*tab_width, 0.7*tab_height, options)
		button.id = "bkgd-" .. page_titles[i]
		button.count = i

		-- local div_line = display.newLine(tab_group, i*tab_width, 0.1*tab_height, i*tab_width, 0.9*tab_height)
		-- div_line.strokeWidth = 3
		-- div_line:setStrokeColor(0,0,0,0.5)

		if globalData.activeScene == page_titles[i] then active_index = i end

		table.insert(buttons, button)
	end

	local settings_button
	local function goToSettings(event)
		if globalData.activeScene == "Settings" then return true end

		globalData.activeScene = "Settings"
		for i = 1,#buttons,1 do
			buttons[i]:setBackgroundColor({1,1,1,0.1})
		end
		settings_button:setBackgroundColor({1,1,1,0.2})

		globalData.activeScene = "Settings"
		composer.gotoScene("Settings", {effect = "slideLeft", time = globalData.transition_time})
		return true
	end 

	local options = {image = "Image Assets/Small-Settings-Graphic.png", tap_func = goToSettings, displayGroup = tab_group, color = {0,0,0,0.01}}
	-- settings_button = tinker.newButton(0.95*display.contentWidth, 0.5*tab_height, 0.8*tab_height, 0.8*tab_height, options)
	settings_button = tinker.newDot(0.95*display.contentWidth, 0.5*tab_height, 0.4*tab_height, options)
	settings_button.id = "bkgd-Settings"
	table.insert(buttons, settings_button)

	buttons[active_index]:setBackgroundColor({1,1,1,0.2})


	-- ----------------------------- --
	-- ------- Search Button ------- --
	-- ----------------------------- --
	local search_button

	-- ------ Search Bar ------- --
	local function createSearchBar(event)
		local search_group = display.newGroup()
		local options_group = display.newGroup()
		search_group:insert(options_group)

		local options = {radius = 0.025*display.contentHeight, textColor = app_colors.tab_bar.search_text, backgroundColor = app_colors.tab_bar.search_bkgd, 
						 defaultText = "Search Recipes...", displayGroup = search_group, strokeWidth = 5, strokeColor = app_colors.tab_bar.outline}
		local search_bar = tinker.newTextField(display.contentCenterX, 2*tab_height, 0.8*display.contentWidth, 0.05*display.contentHeight, options)
		search_bar.alpha = 0

		local glass_screen = display.newRect(search_group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
		glass_screen:setFillColor(0,0,0,0.3)
		glass_screen:addEventListener("tap", function(event) native.setKeyboardFocus(nil); search_group:removeSelf(); return true; end)
		glass_screen:addEventListener("touch", function(event) return true end)

		glass_screen:toBack()		

		transition.to(search_bar, {time = 300, alpha = 1})

		-- Search Bar Listener
		local function searchFoods(event)
			if not event.text then return end

			for i = 1,options_group.numChildren,1 do
				options_group:remove(1)
			end

			local possible_foods = cookbook.searchMenu(event.text)
			local delta_y = 1.5*search_bar.height
			local y = 3*tab_height
			local count = 0

			for name, value in pairs(possible_foods) do
				local function tap_func(event)
					composer.gotoScene("ViewRecipePage", {effect = "slideRight", time = globalData.transition_time, params = {name = name}})
				end

				local params = {label = name, displayGroup = options_group, radius = 20, tap_func = tap_func}
				local option = tinker.newButton(display.contentCenterX, y, search_bar.width, search_bar.height, params)
			
				y = y + delta_y
				count = count + 1
				if count == 11 then break end
			end
		end
		search_bar:addEventListener("userInput", searchFoods)

		-- Set Keyboard Focus
		search_bar._background:dispatchEvent({name = "tap", x = display.contentCenterX})

		return true
	end

	local options = {image = "Image Assets/Small-Magnifying-Glass-Graphic.png", tap_func = createSearchBar, displayGroup = tab_group, color = {0,0,0,0.01}}
	search_button = tinker.newButton(settings_button.x - settings_button.width, settings_button.y, settings_button.width, settings_button.height, options)

	return tab_group
end

-- function cookbook.createTabBar()
-- 	local tab_group  = display.newGroup()
-- 	local tab_height = globalData.tab_height

-- 	local tab_titles 	= {'Browse','Favourites','Add Recipe','Settings'} --'Custom Search'
-- 	local page_titles 	= {"BrowsePage", "FavouritesPage", "NewRecipePage", "Settings"} -- "CustomPage",
-- 	local icon_paths 	= {"Small-Recipe-App-Icon-Transparent.png", "Small-Star.png", "Small-Recipe-Card-Graphic.png", "Small-Settings-Graphic.png"}
-- 	local num_tabs 		= #tab_titles

-- 	local tab_bar = display.newRect(tab_group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height)
-- 	tab_bar:setFillColor(unpack(app_colors.tab_bar.background))
-- 	tab_bar.strokeWidth = 2
-- 	tab_bar:setStrokeColor(unpack(app_colors.tab_bar.outline))

-- 	local icon_height 	= 0.07*display.contentWidth
-- 	local icon_spacing 	= 0.1*display.contentWidth
-- 	local icon_loc		= 0.7*icon_spacing

-- 	-- local tab_width  = 1/num_tabs*display.contentWidth

-- 	for i = 1,num_tabs,1 do
-- 		local icon_background = display.newRoundedRect(tab_group, icon_loc, 0.5*tab_height, 1.3*icon_height, 1.3*icon_height, 0.1*tab_height)
-- 		icon_background:setFillColor(unpack(globalData.tab_color))
-- 		icon_background.id = "bkgd-" .. page_titles[i]

-- 		function icon_background:tap(event)
-- 			print(page_titles[i])
-- 			globalData.activeScene = page_titles[i]
-- 			composer.gotoScene(page_titles[i])
-- 			return true
-- 		end
-- 		icon_background:addEventListener("tap", icon_background)

-- 		local icon = display.newImageRect(tab_group, "Image Assets/"..icon_paths[i], icon_height, icon_height)
-- 		icon.x = icon_loc
-- 		icon.y = 0.5*tab_height

-- 		icon_loc = icon_loc + icon_spacing
-- 	end

-- 	local options = {rounded = false, defaultText = "Search", strokeWidth = 4, strokeColor = globalData.dark, tapOutside = false, centered = false}
-- 	local search_bar = tinker.newTextField(0.7*display.contentWidth, 0.5*globalData.tab_height, 0.5*display.contentWidth, 0.6*globalData.tab_height, options)
-- 	tab_group:insert(search_bar)

-- 	local searchGroup = display.newGroup()
-- 	searchGroup.y = 0.5*globalData.tab_height
-- 	searchGroup.x = search_bar.x
-- 	tab_group:insert(searchGroup)

-- 	local function textListener(event)
-- 		globalData.parseMenuSearch(event, searchGroup, {width = search_bar.width, height = search_bar.height, strokeWidth = options.strokeWidth})
-- 		return true
-- 	end
-- 	search_bar:addEventListener("userInput", textListener)

-- 	return tab_group
-- end

function cookbook.updateTabBar(tab_group)
	for i = 1,tab_group.numChildren,1 do
		if tab_group[i].id then
			-- print(tab_group[i].id:sub(6))
			if tab_group[i].id:sub(6) == globalData.activeScene then
				tab_group[i]:setBackgroundColor({0,0,0,0.1})
				-- tab_group[i]:setFillColor(unpack(app_colors.tab_bar.selected))
				-- print("Colour Filled")

			elseif tab_group[i].id:sub(1,4) == "bkgd" then
				tab_group[i]:setBackgroundColor({0,0,0,0.01})
				-- tab_group[i]:setFillColor(unpack(app_colors.tab_bar.background))
				-- print("Set to invis")

			end
		end
	end

	return tab_group
end

function cookbook.tempTabBar(title, back_text, back_page, next_text, next_page)
	local group = display.newGroup()
	local tab_height = globalData.tab_height

	local tab_bar = display.newRect(group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height)
	tab_bar:setFillColor(unpack(app_colors.tab_bar.background))
	tab_bar:setStrokeColor(unpack(app_colors.tab_bar.outline))
	tab_bar.strokeWidth = 3

	local function back_tap(event)
		globalData.activeScene = back_page
		if back_page == "NewRecipePage" then
			composer.gotoScene(back_page, {effect = "slideDown", time = globalData.transition_time})
		else
			composer.gotoScene(back_page, {effect = "slideRight", time = globalData.transition_time})
		end
	end

	local back_params = {label = back_text, tap_func = back_tap, color = {1,1,1,0.1}, labelColor = app_colors.tab_bar.button_text, radius = 0.02*display.contentWidth, fontSize = globalData.mediumFontSize}
	local back_button = tinker.newButton(0.03*display.contentWidth, 0.5*tab_height, 0.25*display.contentWidth, 0.8*tab_height, back_params)
	back_button.anchorX = 0
	back_button.id = back_page
	group:insert(back_button)

	local function next_tap(event)
		globalData.activeScene = next_page
		composer.gotoScene(next_page, {effect = "slideLeft", time = globalData.transition_time})
	end

	local next_params = {label = next_text, tap_func = next_tap, color = {1,1,1,0.1}, labelColor = app_colors.tab_bar.button_text, radius = 10, radius = 0.02*display.contentWidth, fontSize = globalData.mediumFontSize}
	local next_button = tinker.newButton(0.97*display.contentWidth, 0.5*tab_height, 0.25*display.contentWidth, 0.8*tab_height, next_params)
	next_button.anchorX = next_button.width
	next_button.id = next_page
	group:insert(next_button)

	local title = display.newText({text = title,
								   x = display.contentCenterX,
								   y = 0.5*tab_height,
								   width = 0.45*display.contentWidth,
								   fontSize = globalData.titleFontSize,
								   font = native.systemFontBold,
								   align = "center"})
	title:setFillColor(unpack(app_colors.tab_bar.title))
	group:insert(title)

	while title.height > 0.9*tab_height do
		title.size = 0.95*title.size
	end

	return group
end



function cookbook.getAlphabetizedList(table_input)
	local output = {}
	foods = table_input

	local function stringLessThan(a,b)
		for i = 1,#a,1 do
			if i > #b then
				return(false)
			end

			letter1 = a:sub(i,i):lower()
			letter2 = b:sub(i,i):lower()

			if letter1 < letter2 then
				return true

			elseif letter1 > letter2 then
				return false

			elseif i == #a then
				return true
			end
		end
	end

	for foodname, value in pairs(foods) do
		table.insert(output, foodname)
	end

	for i = 1,#output,1 do
		local switch_count = 0

		for j = 2,#output,1 do
			if stringLessThan(output[j], output[j-1]) then
				local temp_var = output[j]
				output[j] = output[j-1]
				output[j-1] = temp_var

				switch_count = switch_count + 1
			end
		end

		if switch_count == 0 then
			break
		end
	end

	return output

end


function cookbook.createFoodPanel(title, x, y, width, height, parent, color, text_color)
	local panel_group = display.newGroup()

	local panel = display.newRoundedRect(panel_group, 0, 0, width, height, 0.1*height)
	panel.id = "panel"
	panel:setFillColor(unpack(color))

	local has_image = globalData.gallery[title] ~= nil
	if globalData.gallery[title] then

		panel.fill = {	type 		= "image",
						filename 	= globalData.textures[title].filename,
						baseDir 	= globalData.textures[title].baseDir}

	end

	local panel_shadow = display.newRoundedRect(panel_group, -0.015*display.contentWidth, 0.02*display.contentWidth, width, height, 0.1*height)
	panel_shadow.id = "panel_shadow"
	panel_shadow:setFillColor(0,0,0,0.4)

	local panel_text_params = {text = title,
							   x = -0.47*panel.width,
							   y = -0.15*panel.height,
							   width = 0.6*panel.width,
							   height = 0,
							   font = native.systemFontBold,
							   fontSize = 0.08*math.sqrt(panel.height*panel.width),
							   align = "left"}
	local panel_text = display.newText(panel_text_params)
	panel_text:setFillColor(has_image and 1 or unpack(app_colors.browse.recipe_title))
	panel_text.anchorX = 0
	panel_text.anchorY = 0

	local prep_text = globalData.menu[title].prep_time
	if prep_text and prep_text ~= "" then
		local prep_time = display.newText({	text = "Prep Time: " .. prep_text,
										 	x = -0.45*width,
										 	y = 0.25*panel.height,
										 	width = 0.6*width,
										 	fontSize = globalData.smallFontSize})
		prep_time.anchorY = 0
		prep_time.anchorX = 0
		prep_time:setFillColor(has_image and 1 or unpack(app_colors.browse.recipe_info))
		panel_group:insert(prep_time)
	end

	local cook_text = globalData.menu[title].cook_time
	if cook_text and cook_text ~= "" then
		local cook_time = display.newText({	text = "Cook Time: " .. cook_text,
										 	x = -0.45*width,
										 	y = 0.25*panel.height + 0.1*height,
										 	width = 0.6*width,
										 	fontSize = globalData.smallFontSize})
		cook_time.anchorY = 0
		cook_time.anchorX = 0
		cook_time:setFillColor(has_image and 1 or unpack(app_colors.browse.recipe_info))
		panel_group:insert(cook_time)
	end

	-- panel_group:insert(ingredient_text)
	panel_group:insert(panel_text)

	local star = display.newImageRect("Image Assets/Small-Star.png", 0.07*panel.width, 0.07*panel.width)
	star.x = 0.4*panel.width
	star.y = 0.35*panel.height
	panel_group:insert(star)

	local empty_star = display.newImageRect("Image Assets/Small-Empty Star.png", 0.07*panel.width, 0.07*panel.width)
	empty_star.x = 0.4*panel.width
	empty_star.y = star.y
	panel_group:insert(empty_star)

	if not globalData.favourites[title] then
		star.alpha = 0
	end

	function empty_star:tap(event)

		if globalData.favourites[title] then
			globalData.favourites[title] = nil
			star.alpha = 0
			print("Removed " .. title .. " from Favourites")
		else
			globalData.favourites[title] = true
			star.alpha = 1
			print("Added " .. title .. " to Favourites")
		end

		globalData.writeFavourites()
		return true
	end
	empty_star:addEventListener("tap", empty_star)

	-- Edit Icon
	local edit_image = "Image Assets/White-Edit-Graphic.png"
	if app_colors.scheme == "light" and not has_image then edit_image = "Image Assets/Edit-Graphic.jpg" end
	local edit_params = {image = edit_image, tap_func = function(event) return cookbook.editRecipe(title) end, color = {0,0,0,0.01}}
	local edit_button = tinker.newButton(0.4*width, -0.15*height, 0.2*height, 0.2*height, edit_params)
	panel_group:insert(edit_button)

	-- Trash Icon
	local trash_image = "Image Assets/White-Trash-Graphic.png"
	if app_colors.scheme == "light" and not has_image then trash_image = "Image Assets/Trash-Graphic-Simple.png" end
	local trash_icon = display.newImageRect(panel_group, trash_image, empty_star.width, empty_star.height)
	trash_icon.x = 0.25*panel.width
	trash_icon.y = empty_star.y

	-- Function To Delete a Food From Memory
	function trash_icon:tap(event)
		local function trash_listener(event)
			if event.index == 1 then 
				globalData.menu[title] = nil
				globalData.favourites[title] = nil
				globalData.writeCustomMenu()
				globalData.deleteFoodImage(title)
				composer.gotoScene(globalData.activeScene)

			end
		end
		native.showAlert("What's On The Menu", "Are you sure you want to delete \"" .. title .. "\"?", {"Yes, I'm Sure", "Cancel"}, trash_listener )

		return true
	end
	trash_icon:addEventListener("tap", trash_icon)

	local function image_listener(event)

		local function selectListener(event)
			if event.index == 1 then
				cookbook.captureFoodImage(title)

			elseif event.index == 2 then
				cookbook.selectFoodImage(title)

			elseif event.index == 3 then
				globalData.deleteFoodImage(title)
				composer.gotoScene(globalData.activeScene)
			end
		end

		local options = {"Take Photo", "Select From Device"}
		if globalData.gallery[title] then
			table.insert(options, "Delete Photo")
		end
		native.showAlert("Corona", "Select Photo Method", options, selectListener)
		return true
	end

	local image_image = "Image Assets/Small-White-Camera-Graphic.png"
	if app_colors.scheme == "light" and not has_image then image_image = "Image Assets/Small-Camera-Graphic.png" end
	local image_params = {image = image_image, color = {0,0,0,0.01}, tap_func =  image_listener}
	local image_button = tinker.newButton(trash_icon.x - 0.15*width, trash_icon.y, trash_icon.width, trash_icon.height, image_params)
	panel_group:insert(image_button)

	panel_group.x = x
	panel_group.y = y

	panel_group.id = title

	panel_shadow:toBack()

	return panel_group
end

function cookbook.findID(table_obj, id)

	if table_obj.numChildren then
		table_length = table_obj.numChildren
	else
		table_length = #table_obj
	end

	for i = 1,table_length,1 do
		if table_obj[i].id == id then
			return(table_obj[i])
		end
	end
end

function cookbook.convertUnit(value, old_unit, new_unit, food_name)
	-- Ensure consistent casing
	old_unit = old_unit:lower()
	new_unit = new_unit:lower()
	food_name = food_name:lower()

	-- Load conversion parameters
	local volumes = cookbook.volumes
	local masses  = cookbook.masses
	local densities  = cookbook.densities	-- Measured in grams per cup

	local convertFromCup  = cookbook.convertFromCup
	local convertToCup    = {}
	local convertFromGram = cookbook.convertFromGram
	local convertToGram	  = {}

	-- Create reciprocal conversion tables
	for fieldname, value in pairs(convertFromCup) do
		convertToCup[fieldname] = 1/convertFromCup[fieldname]
	end

	for fieldname, value in pairs(convertFromGram) do 
		convertToGram[fieldname] = 1/convertFromGram[fieldname]
	end

	-- START CONVERSION --
	local new_val 		-- output variable (nil until specified)

	-- Consistent Conversions (Volume to Volume or Mass to Mass)
	if volumes[old_unit] and volumes[new_unit] then
		-- Converting from a volume
		cup_val = value*convertToCup[old_unit]
		new_val = cup_val*convertFromCup[new_unit]
	
	elseif masses[old_unit] and masses[new_unit] then
		-- Converting to a mass
		gram_val = value*convertToGram[old_unit]
		new_val  = gram_val*convertFromGram[new_unit]
	end

	-- Convert beween Mass and Volume
	if food_name and densities[food_name] then 	-- density information is required

		-- Convert Volume to Mass
		if volumes[old_unit] and masses[new_unit] then
			cup_val  = value*convertToCup[old_unit]
			gram_val = cup_val*densities[food_name]
			new_val  = gram_val*convertFromGram[new_unit]

		-- Convert Mass to Volume
		elseif masses[old_unit] and volumes[new_unit] then
			gram_val = value*convertToGram[old_unit]
			cup_val  = gram_val/densities[food_name]
			new_val  = cup_val*convertFromCup[new_unit]
		end
	end

	return(new_val)		-- A failed conversion will return nil
end




function cookbook.createUnitTab(current_unit, x_level, y_level, amount_text, amount, food)
	local unit_group = display.newGroup()
	-- local panel_width = cookbook.div_x2 - cookbook.div_x1
	local panel_width = 0.3334*(display.contentWidth - cookbook.div_x2)
	local x_level = cookbook.div_x2 + 0.5*panel_width
	local y_level = y_level + 0.25*cookbook.ingredient_level_delta

	-- PREVENT TOUCH PROPAGATION -------------|
	local glass_screen = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	glass_screen:setFillColor(1,1,1,0.01)

	function glass_screen:tap(event)
		for i = 1,unit_group.numChildren,1 do
			unit_group:remove(1)
		end
		return true
	end

	glass_screen:addEventListener("tap",glass_screen)

	function glass_screen:touch(event)
		return true
	end
	glass_screen:addEventListener("touch", glass_screen)

	unit_group:insert(glass_screen)
	-------------------------------------------|

	local labels = {}
	if cookbook.volumes[current_unit:lower()] then
		labels = {'Cup', 'Tsp', 'Tbsp', 'Fl oz', 'mL'}

		if cookbook.densities[food:lower()] then
			table.insert(labels, "g")
			table.insert(labels, "oz")
			table.insert(labels, "kg")
			table.insert(labels, 'lb')
		end

	elseif cookbook.masses[current_unit:lower()] then
		labels = {}

		if cookbook.densities[food:lower()] then
			table.insert(labels, "Cup")
			table.insert(labels, "Tsp")
			table.insert(labels, "Tbsp")
			table.insert(labels, "Fl oz")
			table.insert(labels, "mL")
		end

		table.insert(labels, "g")
		table.insert(labels, "oz")
		table.insert(labels, "kg")
		table.insert(labels, 'lb')
	end

	for i = 1,#labels,1 do
		local option_panel = display.newRect(x_level, y_level, panel_width, 0.5*cookbook.ingredient_level_delta)
		option_panel:setFillColor(unpack(globalData.panel_color))
		option_panel.strokeWidth = 2
		option_panel:setStrokeColor(0.2)
		option_panel.id = labels[i]
		-- option_panel.anchorY = 0
		
		function option_panel:tap(event)
			new_value = cookbook.convertUnit(amount, current_unit, self.id, food)

			if current_unit == "" or current_unit == "count" then
				amount_text.text = amount_text.text
			elseif self.id == "Fl oz" or self.id == "oz" or self.id == "g" or self.id == "mL" or self.id == "kg" then
				amount_text.text = (new_value - new_value % 1) .. "\n" .. self.id 

				if amount_text.text:sub(1,1) == "0" then
					amount_text.text = string.format("%.2f", new_value) .. "\n" .. self.id
				end
			else
				amount_text.text = cookbook.getFraction(new_value) .. "\n" .. self.id
			end

			for i = 1,unit_group.numChildren,1 do
				unit_group:remove(1)
			end

			unit_group:removeSelf()
		end

		option_panel:addEventListener("tap", option_panel)

		local params = {text = labels[i], x = x_level, y = y_level, fontSize = 0.25*cookbook.ingredient_level_delta, align = "center"}
		local label_params = params

		local measure_label = display.newText(label_params)
		measure_label:setFillColor(0.9)

		unit_group:insert(option_panel)
		unit_group:insert(measure_label)

		x_level = x_level + 0.3334*(display.contentWidth - cookbook.div_x2)
		if (i%3 == 0) then
			x_level = cookbook.div_x2 + 0.5*panel_width
			y_level = y_level + 0.5*cookbook.ingredient_level_delta
		end
	end


	return(unit_group)
end


function cookbook.showUnitCircle(unit, amount_text, amount, foodname)
	if unit == "" or unit:lower() == "count" then return true end

	local labels = {}
	if cookbook.volumes[unit:lower()] then
		labels = {'Cup', 'Tsp', 'Tbsp', 'Fl oz', 'mL'}

		if cookbook.densities[foodname:lower()] then
			table.insert(labels, "g")
			table.insert(labels, "oz")
			-- table.insert(labels, "kg")
			table.insert(labels, 'lb')
		end

	elseif cookbook.masses[unit:lower()] then
		labels = {}

		if cookbook.densities[foodname:lower()] then
			table.insert(labels, "Cup")
			table.insert(labels, "Tsp")
			table.insert(labels, "Tbsp")
			table.insert(labels, "Fl oz")
			table.insert(labels, "mL")
		end

		table.insert(labels, "g")
		table.insert(labels, "oz")
		-- table.insert(labels, "kg")
		table.insert(labels, 'lb')
	end

	local group = display.newGroup()

	local iter = 1
	local function spawnDot(event)
		local label
		local new_unit = labels[iter]
		local new_amount = cookbook.convertUnit(amount, unit, new_unit, foodname)

		if new_unit == "lb" or new_unit == "Fl oz" or new_unit == "oz" or new_unit == "g" or new_unit == "mL" or new_unit == "kg" then
			label = (new_amount - new_amount % 1) .. "\n" .. new_unit

			if label:sub(1,1) == "0" then
				label = string.format("%.2f", new_amount) .. "\n" .. new_unit
			end
		else
			label = cookbook.getFraction(new_amount) .. "\n" .. new_unit
		end

		local function replaceText(event)
			amount_text.text = label
			group:removeSelf()
			return true
		end

		local params = {color = app_colors.recipe.title_bkgd, label = label, hasShadow = true, tap_func = replaceText, labelColor = app_colors.recipe.ing_text}
		local offset = 0.35*display.contentWidth
		local x = display.contentCenterX + offset*math.sin((iter-1)*2*math.pi/#labels)
		local y = display.contentCenterY - offset*math.cos((iter-1)*2*math.pi/#labels)
		local dot = tinker.newDot(display.contentCenterX,display.contentCenterY,0.07*display.contentWidth, params)
		group:insert(dot)

		globalData.transitionTo(dot, x, y, 0.2)
		iter = iter + 1
	end

	local function spawnLabel(event)
		local foodname = foodname

		for i =1,foodname:len(),1 do
			if foodname:sub(i,i) == " " or foodname:sub(i,i) == "/" then
				foodname = foodname:sub(1,i) .. "\n" .. foodname:sub(i+1)
			end
		end

		local params = {color = app_colors.recipe.title_bkgd, label = foodname, hasShadow = true, labelColor = app_colors.recipe.ing_text, tap_func = function(event) return true end}
		local offset = 0.35*display.contentWidth
		local dot = tinker.newDot(display.contentCenterX,display.contentCenterY,0.1*display.contentWidth, params)
		group:insert(dot)
	end

	spawnLabel()
	spawnDot()
	timer.performWithDelay(50, spawnDot, #labels-1)
	-- timer.performWithDelay(50*#labels + 500, spawnLabel, 1)

	local glass_screen = display.newRect(group, 0,0,2*display.contentWidth, 2*display.contentHeight)
	glass_screen:setFillColor(0,0,0,0.3)
	glass_screen:toBack()
	glass_screen:addEventListener("tap", function(event) group:removeSelf(); return true end)
end

function cookbook.getFraction(number)

	if number <= 0 then
		return "0"
	end

	local integer_value = number - (number % 1)
	local decimal_value = number - integer_value

	-- Try to use large denominators at first, allow smaller if it doesn't work
	local allowable_denom_table = {{4,3,2},{16,8,4,3,2}}


	for allowable_denominators = 1,2,1 do
		local denominator = 1
		local denom_table = allowable_denom_table[allowable_denominators]
		local min_error = 1e6

		local error_value
		for i = 1,#denom_table,1 do
			local fraction_value = math.round(decimal_value/(1/denom_table[i]))
			error_value = math.abs((integer_value + fraction_value/denom_table[i]) - number)
			if error_value <= min_error then
				denominator = denom_table[i]
				min_error = error_value
			end
		end

		local final_fraction_value = math.round(decimal_value/(1/denominator))
		if final_fraction_value == denominator then
			final_fraction_value = 0
			integer_value = integer_value + 1
		end

		local string_number = ""

		if integer_value > 0 then
			string_number = string_number .. integer_value
		end

		if final_fraction_value > 0 then
			if string_number == "" then
				string_number = string_number .. final_fraction_value .. "/" .. denominator
			else
				string_number = string_number .. " " .. final_fraction_value .. "/" .. denominator
			end
		end

		if string_number == "" then string_number = "0" end

		if error_value < 1e-2 or allowable_denominators == 2 then
			return string_number
		end

	end

	return string.format("%.2f",number)
end

function cookbook.breakdownFraction(string_number)

	if #string_number == 1 and tonumber(string_number) then
		return string_number, "0", "1"
	end


	local has_integer = false
	local space_index = 0

	local has_fraction = false
	local divide_index = 0

	for i = 1,#string_number,1 do
		if string_number:sub(i,i) == " " then
			has_integer = true
			space_index = i
		
		elseif string_number:sub(i,i) == "/" then
			has_fraction = true
			divide_index = i
		end
	end

	local integer; local numerator; local denominator;

	if has_fraction and has_integer then
		integer = string_number:sub(1,space_index-1)
		numerator = string_number:sub(space_index+1,divide_index-1)
		denominator = string_number:sub(divide_index+1)

	elseif has_integer then
		integer = string_number:sub(1,space_index-1)
		numerator = "0"
		denominator = "1"

	elseif has_fraction then
		integer = "0"
		numerator = string_number:sub(1,divide_index-1)
		denominator = string_number:sub(divide_index+1)
	end

	return integer, numerator, denominator

end


function cookbook.createStar(OD, ID, points)

	local rot_point = 0
	local rot_delta = 2*math.pi/points
	local vertices  = {}

	for i = 1,points,1 do
		local outer_point_x = OD*math.sin(rot_point)
		local outer_point_y = -OD*math.cos(rot_point)

		local inner_point_x = ID*math.sin(rot_point + rot_delta/2)
		local inner_point_y = -ID*math.cos(rot_point + rot_delta/2)

		table.insert(vertices, outer_point_x)
		table.insert(vertices, outer_point_y)
		table.insert(vertices, inner_point_x)
		table.insert(vertices, inner_point_y)

		rot_point = rot_point + rot_delta
	end

	for index, point in pairs(vertices) do
		print(point)
	end

	local star = display.newPolygon(0,0,vertices)
	star:setStrokeColor(unpack(globalData.orange))
	star.strokeWidth = 10
	star:setFillColor(0.9, 0.9, 0)

	return star
end

function cookbook.editRecipe(title)
	cookbook.newRecipeTitle = title
	cookbook.newRecipeIngredientList = {}
	cookbook.newRecipeSteps = {}
	cookbook.newRecipeParams = {}

	for index, ingredient in pairs(globalData.menu[title].ingredients) do
		cookbook.newRecipeIngredientList[ingredient.name] = {amount = ingredient.amount, text_amount = ingredient.text_amount, unit = ingredient.unit} 
	end

	for index, step in pairs(globalData.menu[title].steps) do
		table.insert(cookbook.newRecipeSteps, step)
	end

	cookbook.newRecipeParams = {cook_time = globalData.menu[title].cook_time, prep_time = globalData.menu[title].prep_time}
	globalData.activeScene = "NewRecipePage"
	composer.gotoScene("NewRecipePage", {params = {name = title, prep_time = globalData.menu[title].cook_time, cook_time = globalData.menu[title].prep_time}})
	return true
end

function cookbook.captureFoodImage(title)

	local filename = "Food_Images__"..title..".png"
	local function recordImage(event) 
		local test_image = display.newImage(filename, system.DocumentsDirectory)
		globalData.gallery[title] = {width = test_image.width, height = test_image.height, source = "camera"}
		test_image:removeSelf()

		if globalData.textures[title] then
			globalData.textures[title]:releaseSelf()
			globalData.textures[title] = nil
		end
		composer.removeScene(globalData.activeScene)

		-- globalData.textures[title] = graphics.newTexture({type = "image", filename = filename, baseDir = system.DocumentsDirectory})
		globalData.saveMenuImages()
		-- globalData.textures[title]:preload()
		
		composer.gotoScene(globalData.activeScene)
	end

	-- recordImage({target = display.newRect(0,0,100,100)})
	media.capturePhoto( { listener = recordImage, destination = {baseDir = system.DocumentsDirectory, filename = filename }} )
end

function cookbook.selectFoodImage(title)

	local filename = "Food_Images__"..title..".png"
	local function recordImage(event)
		local test_image = display.newImage(filename, system.DocumentsDirectory)
		globalData.gallery[title] = {width = test_image.width, height = test_image.height, source = "gallery"}
		test_image:removeSelf()

		if globalData.textures[title] then
			globalData.textures[title]:releaseSelf()
			globalData.textures[title] = nil
		end
		composer.removeScene(globalData.activeScene)

		-- globalData.textures[title] = graphics.newTexture({type = "image", filename = filename, baseDir = system.DocumentsDirectory})
		globalData.saveMenuImages()
		-- globalData.textures[title]:preload()

		composer.gotoScene(globalData.activeScene)
	end

	media.selectPhoto({ listener = recordImage , mediaSource = media.PhotoLibrary, destination = {baseDir = system.DocumentsDirectory, filename = "Food_Images__"..title..".png"}} )
end

return cookbook