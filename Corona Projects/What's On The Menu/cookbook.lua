-- custom library for the cookbook app

local cookbook = {}
local globalData = require("globalData")
local widget = require("widget")
local composer = require("composer")
local json = require("json")

-- Density is measured in gram/Cup
cookbook.densities  =  {["flour"]			= 120,
						["baking powder"] 	= 12,
						["baking soda"] 	= 2*48*3,
						["bread crumbs"] 	= 4*28,
						["brown sugar"]		= 213,
						["butter"] 			= 2*113,
						["buttermilk"] 		= 227,
						["parmesan cheese"] = 2*50,
						["chocolate chips"] = 170,
						["cinnamon sugar"] 	= 4*50,
						["coconut oil"] 	= 2*113,
						["cornmeal"] 		= 150,
						["cornstarch"] 		= 4*28,
						["cream"] 			= 227,
						["heavy whipping cream"] = 227,
						["light cream"] 	= 227,
						["half and half"] 	= 227,
						["cream cheese"] 	= 227,
						["eggs"]			= 220,
						["garlic"] 			= 8*28,
						["granola"] 		= 113,
						["honey"] 			= 16*21,
						["lard"]			= 2*113,
						["marshmallow"] 	= 43,
						["mashed potato"] 	= 213,
						["mayonnaise"]		= 2*113,
						["mayo"] 			= 2*113,
						["milk"] 			= 227,
						["olive oil"] 		= 200,
						["olives"] 			= 142,
						["onions"]			= 142,
						["peanut butter"] 	= 2*135,
						["pumpkin"] 		= 227,
						["raisins"] 		= 149,
						["rice"] 			= 198,
						["salt"] 			= 16*18,
						["sour cream"] 		= 227,
						["sugar"] 			= 198,
						["vanilla extract"] = 16*14,
						["vegetable oil"] 	= 198,
						["water"] 			= 227,
						["yeast"] 			= (1/2.25)*48*7}

cookbook.essential_units = {"cup", "tsp", "tbsp", "fl oz", "ml", "g", "oz", "lb", "count"}

cookbook.volumes =  {cup 	= true,
					 tsp 	= true,
					 tbsp 	= true,
				 ["fl oz"]  = true,
					 ml 	= true,
					 l 		= true,
					 pint 	= true,
					 quart 	= true,
					 gallon = true,
					 dash 	= true,
					 pinch 	= true}

cookbook.masses =  {g  = true,
					oz = true,
					kg = true,
					lb = true}

cookbook.convertFromCup  = {cup 	= 1,
					   		tsp 	= 48,
					   		tbsp 	= 16,
						["fl oz"] 	= 8,
							ml 		= 236.6,
							l 		= 0.2366,
							pint 	= 0.5,
							quart  	= 0.25,
							gallon 	= 0.0625,
							dash 	= 385,	
							pinch	= 768}

cookbook.convertFromGram = {g 	= 1,
					   		kg 	= 0.001,
					   		oz 	= 1/28.35,
					   		lb  = 0.0022}

cookbook.ingredient_list = {["flour"] = "Flour-Graphic.png",
							["salt"]  = "Salt-Shaker-Graphic.png",
							["pepper"] = "Pepper-Shaker-Graphic.png",
							["cheese"] = "Cheese-Graphic.png",
							["butter"] = "Unsalted-Butter.png",
							["milk"] = false,
							["eggs"] = "Egg-Graphic.png",
							["waffle"] = "Waffle-Graphic.png",
							["red onion"] = "Red-Onion-Graphic.png",
							["yellow onion"] = "Yellow-Onion-Graphic.png",
							["cinnamon"] = false,
							["sugar"] = false,
							["brown sugar"] = false,
							["chicken"] = false,
							["pork"] = false,
							["beef"] = false,
							["lamb"] = false,
							["turkey"] = false,
							["basil"] = false,
							["parsley"] = false,
							["oregano"] = false,
							["bread crumbs"] = false,
							["olive oil"] = false,
							['garlic'] = false,
							['cream cheese'] = false,
							['vegetable oil'] = false}

cookbook.common_ingredients ={["Flour"] 		= true,
							  ["Salt"] 			= true,
							  ["Black pepper"] 	= true,
							  ["Cheese"] 		= true,
							  ["Milk"] 			= true,
							  ["Eggs"] 			= true,
							  ["Olive oil"] 	= true,
							  ["Vegetable oil"] = true,
							  ["Potato"] 		= true}

cookbook.meats = {["Chicken breasts"] 	= true,
				  ["Chicken legs"] 		= true,
				  ["Chicken thighs"] 	= true,
				  ["Chicken wings"]		= true,
				  ["Chicken - whole"] 	= true,
				  ["Lamb"]	 			= true,
				  ["Beef"]	 			= true,
				  ["Steak"]  			= true,
				  ["Pork sausage"]		= true,
				  ["Chicken sausage"] 	= true,
				  ["Turkey sausage"] 	= true,
				  ["Pork loins"]		= true,
				  ["Pork chops"] 		= true,
				  ['Shrimp']			= true,
				  ['Shrimp - jumbo']  	= true,
				  ['Scallops'] 			= true,
				  ['Fish']				= true,
				  ['Ham'] 				= true}

cookbook.fruits_and_veggies =  {["Broccoli"] 	= true,
							  	["Carrots"] 	= true,
							  	["Apples"]		= true,
							  	["Strawberries"]= true,
							  	["Celery"]	 	= true,
							  	["Cabbage"]  	= true,
							  	["Lettuce"] 	= true,
							  	["Tomato"]		= true,
							  	["Pumpkin"]		= true,
							  	["Potato"]	= true,
							  	["Eggplant"]	= true,
							  	["Butternut squash"] = true,
							  	["Zuchinni squash"]	 = true,
							  	["Beets"] 		= true,
							  	["Spinnach"]	= true,
							  	["Chick peas"]	= true,
							  	["Red beans"]	= true,
							  	["Black beans"]	= true,
							  	["Baked beans"] = true,
							  	["Green beans"] = true,
							  	["Peaches"] 	= true,
							  	["Plums"] 		= true,
							  	["Cherries"]	= true,
							  	["Pears"]		= true,
							  	["Raspberries"]	= true,
							  	["Blackberries"]= true,
							  	["Onions"]		= true,
							  	["Cucumbers"]	= true}

cookbook.starches =    {Potato = true,
						["Instant mashed potato"] = true,
						Penne = true,
						Linguini = true,
						Macaroni = true,
						["White rice"] = true,
						["Brown rice"] = true,
						Spaghetti = true,
						Fettuccini = true,
						}

cookbook.seasonings =  {["Black Pepper"] = true,
						Salt = true,
						["Garlic powder"] = true,
						["Onion powder"] = true,
						Cinnamon = true,
						["Garlic cloves"] = true,
						["Minced Garlic"] = true,
						["All Purpose Seasoning"] = true,
						Allspice = true,
						Thyme = true,
						Basil = true,
						Oregano = true,
						Parsley = true,
						["Bay Leaves"] = true,
						}

cookbook.dairy = {}

cookbook.sauces = {}

cookbook.nuts = {}

cookbook.newRecipeTitle = "test-recipe"
cookbook.newRecipeIngredientList = {}
cookbook.newRecipeSteps = {}
cookbook.newRecipeKeywords = {}


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

function cookbook.displayRecipe(name)
	local function insertIngredient(ingredient, amount, unit, amount_number)
		-- Make it look pretty
		for i = 1,#ingredient-2,1 do
			if string.sub(ingredient,i, i) == " " then
				ingredient = ingredient:sub(1,i) .. string.upper(ingredient:sub(i+1,i+1)) .. ingredient:sub(i+2)
			end
		end

		-- Still making it look pretty
		ingredient = string.upper(ingredient:sub(1,1)) .. ingredient:sub(2)
		unit = string.upper(unit:sub(1,1)) .. unit:sub(2)

		-- Ingredient Text
		ingredient_text_params = {text = ingredient,
								  x = 0.07*cookbook.div_x1,
								  y = cookbook.ingredient_level,
								  width = 0.9*cookbook.div_x1,
								  height = 0,
								  font = native.systemFont,
								  fontSize = 0.025*display.contentHeight}
		local ingredient_word = display.newText(ingredient_text_params)
		ingredient_word.anchorX = 0
		ingredient_word:setFillColor(0.2)

		while ingredient_word.height > cookbook.ingredient_level_delta do
			ingredient_word.size = 0.9*ingredient_word.size
		end

		-- Ingredient Amount Text
		if unit == "Count" then
			unit = ""
		end

		local amount_text_params = {text = amount .. "\n" .. unit,
									x = 0.5*(cookbook.div_x1 + cookbook.div_x2),
									y = cookbook.ingredient_level,
									width = 0.9*(cookbook.div_x2 - cookbook.div_x1),
									height = 0,
									font = native.systemFont,
									fontSize = 0.025*display.contentHeight,
									align = "center"}
		ingredient_amount = display.newText(amount_text_params)
		ingredient_amount:setFillColor(0.2)
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

			local new_panel = cookbook.createUnitTab(old_unit, self.y, self, old_value, food_name)
			cookbook.ingredient_group:insert(new_panel)
		end

		ingredient_amount:addEventListener("tap", ingredient_amount)

		local new_dividing_line = display.newLine(-display.contentWidth, cookbook.ingredient_level + 0.5*cookbook.ingredient_level_delta, cookbook.div_x2, cookbook.ingredient_level + 0.5*cookbook.ingredient_level_delta)
		new_dividing_line.strokeWidth = 2
		new_dividing_line:setStrokeColor(unpack(cookbook.sub_line_color))

		cookbook.ingredient_group:insert(ingredient_word)
		cookbook.ingredient_group:insert(ingredient_amount)
		cookbook.ingredient_group:insert(new_dividing_line)

		cookbook.ingredient_level = cookbook.ingredient_level + cookbook.ingredient_level_delta
	end

	function insertStep(step_text)
		if step_text == "" or step_text == nil then
			return
		end

		step_title_params = {text = "Step " .. cookbook.step_count,
							 x = cookbook.div_x2 + 0.07*(display.contentWidth - cookbook.div_x2),
							 y = cookbook.step_level,
							 width = 0.9*(display.contentWidth - cookbook.div_x2),
							 height = 0,
							 font = native.systemFontBold,
							 fontSize = globalData.titleFontSize}
		step_title = display.newText(step_title_params)

		cookbook.step_level = cookbook.step_level + cookbook.step_level_delta + step_title.height

		step_text_params = {text = step_text,
							x = cookbook.div_x2 + 0.12*(display.contentWidth - cookbook.div_x2),
							y = cookbook.step_level,
							width = 0.8*(display.contentWidth - cookbook.div_x2),
							height = 0,
							font = native.systemFont,
							fontSize = 0.025*display.contentHeight}

		step_text_paragraph = display.newText(step_text_params)
		step_text_paragraph.id = "step_text"

		cookbook.step_level = cookbook.step_level + 2*cookbook.step_level_delta + step_text_paragraph.height
		cookbook.step_count = cookbook.step_count + 1

		step_title:setFillColor(0)
		step_title.anchorX = 0
		step_title.anchorY = 0
		step_text_paragraph:setFillColor(0)
		step_text_paragraph.anchorX = 0
		step_text_paragraph.anchorY = 0

		cookbook.step_group:insert(step_title)
		cookbook.step_group:insert(step_text_paragraph)
	end

	cookbook.recipe_group 	  = display.newGroup()
	cookbook.ingredient_group = display.newGroup()
	cookbook.step_group 	  = display.newGroup()
	cookbook.title_group 	  = display.newGroup()

	globalData.relocateSearchBar(-display.contentCenterX, -display.contentCenterY)


	-----------------------------------------------------
	-------------------- PARAMETERS ---------------------
	-----------------------------------------------------
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
	-------------------------------------------------------
	-------------------------------------------------------


	local title_background = display.newRect(0, 0, display.contentWidth, cookbook.div_y)
	title_background.anchorX = 0
	title_background.anchorY = 0
	title_background:setFillColor(0.8)

	local back_button = display.newRect(display.contentWidth, 0, 0.15*display.contentWidth, 0.5*cookbook.div_y)
	back_button.anchorX = back_button.width
	back_button.anchorY = 0
	back_button:setFillColor(0.7)

	local favourite_button = display.newRect(display.contentWidth, back_button.height, back_button.width, back_button.height)
	favourite_button.anchorX = favourite_button.width
	favourite_button.anchorY = 0
	favourite_button:setFillColor(0.6)

	local ingredient_panel = display.newRect(0, cookbook.div_y, cookbook.div_x2, display.contentHeight-cookbook.div_y)
	ingredient_panel.anchorX = 0
	ingredient_panel.anchorY = 0
	ingredient_panel:setFillColor(0.7)

	local instruction_panel = display.newRect(display.contentWidth, cookbook.div_y, display.contentWidth-cookbook.div_x2, display.contentHeight-cookbook.div_y)
	instruction_panel.anchorX = instruction_panel.width
	instruction_panel.anchorY = 0
	instruction_panel:setFillColor(0.9)

	local horizontal_dividing_line = display.newLine(0, cookbook.div_y, display.contentWidth, cookbook.div_y)
	horizontal_dividing_line.strokeWidth = 3
	horizontal_dividing_line:setStrokeColor(unpack(cookbook.major_line_color))

	local small_div_line1 = display.newLine(display.contentWidth - back_button.width, 0, display.contentWidth - back_button.width, cookbook.div_y)
	small_div_line1.strokeWidth = 3
	small_div_line1:setStrokeColor(unpack(cookbook.major_line_color))

	local small_div_line2 = display.newLine(display.contentWidth - back_button.width, back_button.height, display.contentWidth, back_button.height)
	small_div_line2.strokeWidth = 3
	small_div_line2:setStrokeColor(unpack(cookbook.major_line_color))

	local vertical_dividing_line1 = display.newLine(cookbook.div_x1, cookbook.div_y, cookbook.div_x1, display.contentHeight)
	vertical_dividing_line1.strokeWidth = 2
	vertical_dividing_line1:setStrokeColor(unpack(cookbook.sub_line_color))

	local vertical_dividing_line2 = display.newLine(cookbook.div_x2, cookbook.div_y, cookbook.div_x2, display.contentHeight)
	vertical_dividing_line2.strokeWidth = 3
	vertical_dividing_line2:setStrokeColor(unpack(cookbook.major_line_color))

	local move_tab_line = display.newRect(cookbook.div_x2, cookbook.div_y, 0.05*display.contentWidth, display.contentHeight - cookbook.div_y)
	move_tab_line:setFillColor(1,1,1,0.01)
	move_tab_line.anchorY = 0

	-- Image Asset Load --
	local unfavourite_icon = display.newImageRect("Image Assets/Empty Star.png", 0.6*favourite_button.width, 0.6*favourite_button.width)
	unfavourite_icon.x = favourite_button.x - favourite_button.width/2
	unfavourite_icon.y = favourite_button.y + favourite_button.height/2

	local favourite_icon = display.newImageRect("Image Assets/Star.png", 0.6*favourite_button.width, 0.6*favourite_button.width)
	favourite_icon.x = favourite_button.x - favourite_button.width/2
	favourite_icon.y = favourite_button.y + favourite_button.height/2
	if not globalData.favourites[name] then
		favourite_icon.alpha = 0
	end

	-- Section Title Generation --
	title_text_params = {text = name,
						 x = 0.4*display.contentWidth,
						 y = 0.07*display.contentHeight,
						 height = 0,
						 width = 0.8*display.contentWidth,
						 font = native.systemFontBold,
						 fontSize = 0.05*display.contentHeight,
						 align = "center"}
	local title = display.newText(title_text_params)
	title:setFillColor(0.2)

	back_text_params = {text = "Back",
						x = back_button.x - 0.5*back_button.width,
						y = back_button.y + 0.5*back_button.height,
						height = 0,
						width = 0,
						font = native.systemFont,
						fontSize = 0.02*display.contentHeight,
						align = "center"}
	back_text = display.newText(back_text_params)
	back_text:setFillColor(0.1)

	-- Touch Listener Functions
	local function onTouchIngredient(event)
		if event.phase == "began" then
			ingredient_panel.y_start = event.y
			ingredient_panel.y0 = cookbook.ingredient_group.y
			display.getCurrentStage():setFocus(ingredient_panel)

		elseif event.phase == "moved" then
			cookbook.ingredient_group.y = math.max(math.min(ingredient_panel.y0 + event.y - ingredient_panel.y_start,0), -cookbook.ingredient_level + ingredient_panel.height + 2*cookbook.ingredient_level_delta)
		
		elseif event.phase == "ended" or event.phase == "cencalled" then
			display.getCurrentStage():setFocus(nil)
		end
	end

	local function onTouchStep(event)
		if event.phase == "began" then
			instruction_panel.y_start = event.y
			instruction_panel.y0 = cookbook.step_group.y
			display.getCurrentStage():setFocus(instruction_panel)

		elseif event.phase == "moved" then
			cookbook.step_group.y = math.max(math.min(instruction_panel.y0 + event.y - instruction_panel.y_start, 0), -cookbook.step_level + instruction_panel.height + 4*cookbook.step_level_delta)

		elseif event.phase == "ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus(nil)
		end
	end

	local function onTouchBack(event)
		if event.phase == "began" then
			back_text:setFillColor(0.2, 0.2, 0.5)
			back_button:setFillColor(0.5)
			display.getCurrentStage():setFocus(back_button)

		elseif event.phase == "ended" or event.phase == "cancelled" then
			back_text:setFillColor(0.1)
			back_button:setFillColor(0.7)

			if event.y < (back_button.height) and event.x > (back_button.x - back_button.width) then
				while cookbook.recipe_group.numChildren > 0 do
					cookbook.recipe_group:remove(1)
				end
				composer.gotoScene(globalData.activeScene)
				globalData.relocateSearchBar(unpack(globalData.search_bar_home))
			end

			display.getCurrentStage():setFocus(nil)
		end
	end

	local function moveTab(event)
		if event.phase == "began" then
			move_tab_line.left_offset = vertical_dividing_line2.x - event.x
			move_tab_line.right_offset = vertical_dividing_line1.x - event.x
			display.getCurrentStage():setFocus(move_tab_line)

		elseif event.phase == "moved" then
			vertical_dividing_line2.x = event.x + move_tab_line.left_offset
			ingredient_panel.width = event.x + move_tab_line.left_offset
			instruction_panel.width = display.contentWidth - ingredient_panel.width

		elseif event.phase == "ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus(nil)
		end
	end

	local function onFavouriteTouch(event)

		if globalData.favourites[name] then
			globalData.favourites[name] = nil
			favourite_icon.alpha = 0
			print("Removed " .. name .. " from Favourites")
		else
			globalData.favourites[name] = true
			favourite_icon.alpha = 1
			print("Added " .. name .. " to Favourites")
		end

		globalData.writeFavourites()
	end


	cookbook.recipe_group:insert(instruction_panel)
	cookbook.recipe_group:insert(ingredient_panel)

	cookbook.title_group:insert(title_background)
	cookbook.title_group:insert(title)
	cookbook.title_group:insert(back_button)
	cookbook.title_group:insert(back_text)
	cookbook.title_group:insert(favourite_button)
	cookbook.title_group:insert(unfavourite_icon)
	cookbook.title_group:insert(favourite_icon)

	for index, food_value in pairs(globalData.menu[name].ingredients) do
		table_val = globalData.menu[name].ingredients[index]
		step_val  = globalData.menu[name].steps[index]
		insertIngredient(table_val.name, table_val.text_amount, table_val.unit, table_val.amount)
		insertStep(step_val)
	end

	cookbook.recipe_group:insert(cookbook.step_group)
	cookbook.recipe_group:insert(cookbook.ingredient_group)
	cookbook.recipe_group:insert(cookbook.title_group)

	cookbook.recipe_group:insert(vertical_dividing_line1)
	cookbook.recipe_group:insert(vertical_dividing_line2)
	cookbook.recipe_group:insert(horizontal_dividing_line)
	cookbook.recipe_group:insert(small_div_line1)
	cookbook.recipe_group:insert(small_div_line2)
	cookbook.recipe_group:insert(move_tab_line)
	cookbook.recipe_group:insert(favourite_icon)
	move_tab_line:toBack()

	-- Add event listeners
	if cookbook.ingredient_level - 0.5*cookbook.ingredient_level_delta - cookbook.div_y > ingredient_panel.height then
		ingredient_panel:addEventListener("touch", onTouchIngredient)
	end

	if cookbook.step_level - 0.5*cookbook.step_level_delta - cookbook.div_y > instruction_panel.height then
		instruction_panel:addEventListener("touch", onTouchStep)
	end

	back_button:addEventListener("touch", onTouchBack)
	favourite_button:addEventListener("tap", onFavouriteTouch)
	-- move_tab_line:addEventListener("touch", moveTab)

	return cookbook.recipe_group
end




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
			print("Found it exactly")
		end

		for i = 1,#foodname,1 do 
			if foodname:lower():sub(i,i+word_length-1) == search_word then
				result_options[foodname] = true
				print("Found it")
			end
		end

	end

	return(result_options)
end 



function cookbook.createTabBar()
	local tab_group  = display.newGroup()
	local tab_height = globalData.tab_height

	local tab_titles 	= {'Browse','Favourites','Add Recipe','Settings'} --'Custom Search'
	local page_titles 	= {"BrowsePage", "FavouritesPage", "NewRecipePage", "Settings"} -- "CustomPage",
	local icon_paths 	= {"Recipe-App-Icon-Transparent.png", "Star.png", "Recipe-Card-Graphic.png", "Settings-Graphic.png"}
	local num_tabs 		= #tab_titles

	local tab_bar = display.newRect(tab_group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height)
	tab_bar:setFillColor(unpack(globalData.tab_color))
	tab_bar.strokeWidth = 2
	tab_bar:setStrokeColor(unpack(globalData.dark_grey))

	local icon_height 	= 0.5*tab_height
	local icon_spacing 	= 0.1*display.contentWidth
	local icon_loc		= 0.5*icon_spacing

	-- local tab_width  = 1/num_tabs*display.contentWidth

	for i = 1,num_tabs,1 do
		local icon_background = display.newRoundedRect(tab_group, icon_loc, 0.5*tab_height, 1.3*icon_height, 1.3*icon_height, 0.1*tab_height)
		icon_background:setFillColor(unpack(globalData.tab_color))
		icon_background.id = "bkgd-" .. page_titles[i]

		function icon_background:tap(event)
			globalData.activeScene = page_titles[i]
			composer.gotoScene(page_titles[i])
		end
		icon_background:addEventListener("tap", icon_background)

		local icon = display.newImageRect(tab_group, "Image Assets/"..icon_paths[i], icon_height, icon_height)
		icon.x = icon_loc
		icon.y = 0.5*tab_height

		icon_loc = icon_loc + icon_spacing
	end

	local searchGroup = display.newGroup()
	tab_group:insert(searchGroup)

	local function textListener(event)
		globalData.parseMenuSearch(event, searchGroup)
		return true
	end
	globalData.search_bar:addEventListener("userInput", textListener)

	return tab_group
end

function cookbook.updateTabBar(tab_group)
	for i = 1,tab_group.numChildren,1 do
		if tab_group[i].id then
			print(tab_group[i].id:sub(6))
			if tab_group[i].id:sub(6) == globalData.activeScene then
				tab_group[i]:setFillColor(unpack(globalData.dark_grey))
				print("Colour Filled")

			elseif tab_group[i].id:sub(1,4) == "bkgd" then
				tab_group[i]:setFillColor(unpack(globalData.tab_color))
				print("Set to invis")

			end
		end
	end

	return tab_group
end




function cookbook.getAlphabetizedList(table_input)
	local output = {}
	foods = table_input

	local function stringLessThan(a,b)
		for i = 1,#a,1 do
			if i > #b then
				return(false)
			end

			letter1 = a:sub(i,i)
			letter2 = b:sub(i,i)

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


function cookbook.createFoodPanel(title, x, y, width, height)
	local panel_group = display.newGroup()

	local panel = display.newRoundedRect(0, 0, width, height, 0.05*height)
	panel.id = "panel"
	panel:setFillColor(unpack(globalData.panel_color))
	-- panel.fill = {type = "image", filename = "Image Assets/Settings-Graphic.png"}
	panel.strokeWidth = 2
	panel:setStrokeColor(0.1)

	local panel_text_params = {text = title,
							   x = -0.47*panel.width,
							   y = -0.35*panel.height,
							   width = 0.8*panel.width,
							   height = 0,
							   font = native.systemFontBold,
							   fontSize = 0.1*math.sqrt(panel.height*panel.width),
							   align = "left"}
	local panel_text = display.newText(panel_text_params)
	panel_text:setFillColor(unpack(globalData.light_text_color))
	panel_text.anchorX = 0
	panel_text.anchorY = 0

	local ingredient_count = #globalData.menu[title].ingredients
	local step_count = #globalData.menu[title].steps
	local ingredient_text_params = panel_text_params
	ingredient_text_params.y = -panel_text_params.y
	ingredient_text_params.fontSize = 0.8*ingredient_text_params.fontSize
	ingredient_text_params.text = ingredient_count .. " Ingredients            " .. step_count .. " Steps"
	local ingredient_text = display.newText(ingredient_text_params)
	ingredient_text:setFillColor(0.3)
	ingredient_text.anchorX = 0

	panel_group:insert(panel)
	panel_group:insert(ingredient_text)
	panel_group:insert(panel_text)

	local star = display.newImageRect("Image Assets/Star.png", 0.07*panel.width, 0.07*panel.width)
	star.x = 0.4*panel.width
	star.y = ingredient_text.y
	panel_group:insert(star)

	local empty_star = display.newImageRect("Image Assets/Empty Star.png", 0.07*panel.width, 0.07*panel.width)
	empty_star.x = 0.4*panel.width
	empty_star.y = ingredient_text.y
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

	panel_group.x = x
	panel_group.y = y

	panel_group.id = title

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
		new_val  = gram_val*convertFromGram
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

	local labels = {'Cup', 'Tsp', 'Tbsp', 'Fl oz', 'mL'}

	if cookbook.densities[food:lower()] then
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
			elseif self.id == "Fl oz" or self.id == "oz" or self.id == "g" or self.id == "mL" then
				amount_text.text = (new_value - new_value % 1) .. "\n" .. self.id 
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

		for i = 1,#denom_table,1 do
			local fraction_value = math.round(decimal_value/(1/denom_table[i]))
			local error_value = math.abs((integer_value + fraction_value/denom_table[i]) - number)
			print(error_value)
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

		if string_number ~= "" then
			return string_number
		end

	end

	return string.format("%.2f",number)
end

function cookbook.breakdownFraction(string_number)
	print("Got :" .. string_number)

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
			print("Found space at " .. i)
		
		elseif string_number:sub(i,i) == "/" then
			has_fraction = true
			divide_index = i
			print("Found divide at " .. i)
		end
	end

	local integer; local numerator; local denominator;

	if has_fraction and has_integer then
		print("Integer and fraction")
		print(string_number)
		integer = string_number:sub(1,space_index-1)
		numerator = string_number:sub(space_index+1,divide_index-1)
		denominator = string_number:sub(divide_index+1)

	elseif has_integer then
		print("just integer")
		integer = string_number:sub(1,space_index-1)
		numerator = "0"
		denominator = "1"

	elseif has_fraction then
		print("just fraction")
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

return cookbook