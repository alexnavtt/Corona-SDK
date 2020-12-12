local globalData = require("globalData")
local widget = require("widget")
local composer = require("composer")
local json = require("json")
local tinker = require("Tinker")
local colors = require("Palette")
local app_colors = require("AppColours")
local transition = require("transition")
local new_recipe_info = require("NewRecipeUtil.new_recipe_info")

-- Custom library for the cookbook app
local cookbook = require("Cookbook.cookbook_main")


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



-- Searching through the menu -----------------------------
local menu_parser = require("Cookbook.cookbook_menu_parsing")
cookbook.findRecipe = menu_parser.findRecipe
cookbook.searchMenu = menu_parser.searchMenu
cookbook.searchIngredients = menu_parser.searchIngredients
-- ========================================================



-- Edit an existing recipe --------------------------------
function cookbook.editRecipe(title)
	new_recipe_info.newRecipeTitle = title
	new_recipe_info.newRecipeIngredientList = {}
	new_recipe_info.newRecipeSteps = {}
	new_recipe_info.newRecipeParams = {}

	for index, ingredient in pairs(globalData.menu[title].ingredients) do
		new_recipe_info.newRecipeIngredientList[ingredient.name] = {amount = ingredient.amount, text_amount = ingredient.text_amount, unit = ingredient.unit} 
	end

	for index, step in pairs(globalData.menu[title].steps) do
		table.insert(new_recipe_info.newRecipeSteps, step)
	end

	new_recipe_info.newRecipeParams = {cook_time = globalData.menu[title].cook_time, prep_time = globalData.menu[title].prep_time}
	globalData.activeScene = "NewRecipePage"
	composer.gotoScene("NewRecipePage", {params = {name = title, prep_time = globalData.menu[title].cook_time, cook_time = globalData.menu[title].prep_time}})
	return true
end
-- ========================================================



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