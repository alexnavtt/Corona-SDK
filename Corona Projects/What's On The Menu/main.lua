-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer 		= require("composer")
local globalData 	= require("globalData")
local json 			= require("json")
local cookbook 		= require("cookbook")
local colors 		= require("Palette")
local defaultMenu   = require("DefaultMenu")
local lfs 			= require("lfs")
local app_colors 	= require("AppColours")

local url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSsYVoMs9cpnRWNg-B7usduhVjY8GYzOb74rutaGxwtBhG8BcT7wdqKJ_3q34R2CtFCV8TagJktLVVO/pub?output=csv"
local ftcsv = require("ftcsv")

-- Data Storage
globalData.menu 		= {}
globalData.keywords 	= {}
globalData.favourites 	= {}
globalData.custom_menu 	= {}
globalData.gallery 		= {}
globalData.textures 	= {}
globalData.settings 	= {}

-- List of all composer scenes in the project
globalData.all_scenes = {"BrowsePage", "FavouritesPage", "NewRecipePage", "IngredientsPage", "MeasurementPage", "InsertStepsPage","ViewRecipePage"}

-- Default Settings for the App
globalData.defaultSettings = {
	colorScheme 		= "blue",
	showDefaultRecipes 	= true,
	recipeStyle 		= "portrait",
}

-- Private Parameters
globalData.info_received = false
globalData.search_bar 			= native.newTextField(-500,-500,100,100)
globalData.numeric_text_field 	= native.newTextField(-500,-500,100,100)
globalData.steps_text_field 	= native.newTextBox(-500,-500,100,100)
globalData.numeric_text_field.inputType = "number"
globalData.activeTextDisplayLimit = 4
globalData.colorOptions = {blue = "blue", red = "red", light = "white", dark = "purple", bright = "green"}

function globalData.numeric_text_field:userInput(event)
	if event.phase == "began" then
		self.text = globalData.activeTextDisplay.text

	elseif event.phase == "editing" then

		if #event.text <= globalData.activeTextDisplayLimit then
			globalData.activeTextDisplay.text = event.text

		else
			globalData.activeTextDisplay.text = event.text:sub(1,#event.text - 1)
			self.text = event.text:sub(1,#event.text - 1)
		end

	elseif event.phase == "ended" or event.phase == "submitted" then
		if self.text == "" then
			globalData.activeTextDisplay.text = "0"
		end
		self.text = ""
	end
end
globalData.numeric_text_field:addEventListener("userInput", globalData.numeric_text_field)

-- Visual Parameters

-- Browse Colours
globalData.panel_color 			= colors.blue
globalData.selection_color	 	= colors.grey
globalData.background_color 	= colors.dark.blue
globalData.tab_color 			= colors.pastel.blue
globalData.light_text_color 	= colors.white
globalData.dark_text_color 		= colors.black
globalData.outline_color 		= colors.black

-- View Recipe Colours
globalData.recipe_step_color 	= colors.light.grey
globalData.recipe_ing_color		= colors.light.grey
globalData.recipe_title_color 	= colors.grey
globalData.step_panel_color 	= colors.dark.blue
globalData.ing_panel_color 		= colors.blue
globalData.title_panel_color 	= colors.sky_blue

-- Make Recipe Colors
globalData.recipe_background_color 		= colors.blue
globalData.text_field_background_color 	= colors.pastel.blue

globalData.light_grey = {0.8}
globalData.dark_grey  = {0.4}
globalData.white = {1}
globalData.black = {0}

globalData.smallFontSize  = 0.02*display.contentHeight
globalData.mediumFontSize =	0.0225*display.contentHeight
globalData.titleFontSize  = 0.025*display.contentHeight

-- Geometry Parameters
globalData.panel_width 	= 0.9*display.contentWidth
globalData.panel_height = 0.2*display.contentHeight
globalData.tab_height 	= 0.05*display.contentHeight
globalData.label_height = 0.05*display.contentHeight
globalData.label_width  = 0.45*display.contentWidth

-- Text Field Parameters
local search_bar_x = 0.67*display.contentWidth
local search_bar_y = 0.50*globalData.tab_height
local search_bar_w = 0.50*display.contentWidth
local search_bar_h = 0.60*globalData.tab_height
globalData.search_bar_home = {search_bar_x, search_bar_y, search_bar_w, search_bar_h}

local steps_field_x = 0 --display.contentCenterX
local steps_field_y = globalData.tab_height + 0.15*(display.contentHeight - globalData.tab_height)
local steps_field_w = display.contentWidth
local steps_field_h = 0.2*(display.contentHeight - globalData.tab_height)
globalData.steps_field_home = {steps_field_x, steps_field_y, steps_field_w, steps_field_h}
globalData.steps_text_field.isEditable = true
globalData.steps_text_field.anchorX = 0

-- Scrollview Parmameters
function globalData.scroll_options()

	M ={x = display.contentCenterX, 
		y = display.contentCenterY + 0.5*globalData.tab_height, 
		width = display.contentWidth, 
		height = display.contentHeight - globalData.tab_height,
		friction = 0.97,
		horizontalScrollDisabled = true,
		isBounceEnabled = false,
		backgroundColor = globalData.background_color,
		maxVelocity = 4,
		bottomPadding = 0.3*display.contentWidth}
	return M
end

-- File Storage
globalData.favourites_file 		= "Favourites.txt"
globalData.custom_recipes_file 	= "CustomRecipes.txt"
globalData.images_file 			= "FoodImages.txt"
globalData.settings_file 		= "AppSettings.txt"

-- Other
globalData.transition_time = 300

function globalData.relocateSearchBar(x,y,width,height)
	globalData.search_bar.x = x
	globalData.search_bar.y = y
	if width then
		globalData.search_bar.width = width
	end

	if height then
		globalData.search_bar.height = height
	end

	globalData.search_bar.size = 0.7*globalData.search_bar.height
end

function globalData.relocateStepsField(x,y,width,height)
	globalData.steps_text_field.x = x
	globalData.steps_text_field.y = y
	if width then
		globalData.steps_text_field.width = width
	end

	if height then
		globalData.steps_text_field.height = height
	end

	globalData.steps_text_field.size = globalData.titleFontSize
end

-- Load favourites
function globalData.writeFavourites()
	local path = system.pathForFile(globalData.favourites_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.favourites, {indent = true}))

	io.close(file)
	file = nil
end


function globalData.readFavourites()
	local path = system.pathForFile(globalData.favourites_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	if not file then
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local jsonString = ""
	for data in file:lines() do
		jsonString = jsonString .. "\n" .. data
	end

	if jsonString ~= "" then
		globalData.favourites = json.decode(jsonString)
	else
		globalData.favourites = {}
	end

	io.close(file)
	file = nil
end

function globalData.deleteFavourites()
	globalData.favourites = {}

	local path = system.pathForFile(globalData.favourites_file, system.DocumentsDirectory)
	os.remove(path)
end

function globalData.writeCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.menu, {indent = true}))

	io.close(file)
	file = nil
end

function globalData.readCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	print("Loading file")

	if not file then
		print("File did not exist, creating now...")
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local jsonString = ""
	for data in file:lines() do
		jsonString = jsonString .. "\n" .. data
	end

	-- print(jsonString)

	if jsonString ~= "" then
		globalData.menu = json.decode(jsonString)
	else
		globalData.menu = {}
	end

	io.close(file)
	file = nil

	-- for name, value in pairs(globalData.menu) do
	-- 	print(" ")
	-- 	print(name)
	-- 	print(value)
	-- end
end

function globalData.deleteCustomMenu()
	globalData.menu = {}

	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	os.remove(path)
end

function globalData.readDefaultMenu()
	for name, value in pairs(defaultMenu) do
		if not globalData.menu[name] then
			globalData.menu[name] = value
		end
	end
end

-- Load favourites
function globalData.saveMenuImages()
	local path = system.pathForFile(globalData.images_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.gallery, {indent = true}))

	io.close(file)
	file = nil
end

function globalData.loadMenuImages()
	local path = system.pathForFile(globalData.images_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	if not file then
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local jsonString = ""
	for data in file:lines() do
		jsonString = jsonString .. "\n" .. data
	end

	if jsonString ~= "" then
		globalData.gallery = json.decode(jsonString)
	else
		globalData.gallery = {}
	end

	io.close(file)
	file = nil

	for foodname, value in pairs(globalData.gallery) do
		local texture = graphics.newTexture({type = "image", filename = "Food_Images__"..foodname..".png", baseDir = system.DocumentsDirectory})

		if texture then
			texture:preload()
			globalData.textures[foodname] = texture
		else
			globalData.gallery[foodname] = nil
			globalData.saveMenuImages()
		end
	end
end

function globalData.deleteFoodImage(title)
	local path = system.pathForFile("Food_Images__"..title..".png", system.DocumentsDirectory)
	os.remove(path)

	globalData.gallery[title] = nil
	globalData.textures[title] = nil
	globalData.saveMenuImages()
end

function globalData.cleanupFoodImages()
	local path = system.pathForFile(nil, system.DocumentsDirectory)

	for file in lfs.dir(path) do
		local extension = file:sub(file:len() - 2)

		if extension == "png" then
			local foodname = file:sub(14, file:len()-4)

			local function deleteListener(event)
				if event.index == 1 then
					globalData.deleteFoodImage(foodname)
				else
					return true
				end
			end

			if not globalData.menu[foodname] then
				native.showAlert("Corona", "Recipe Not Found For Image '" .. foodname .. "'. Delete image?", {"OK", "No, keep it"}, deleteListener)
			end
		end
	end
end

-- Load Settings
function globalData.writeSettings()
	local path = system.pathForFile(globalData.settings_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.settings, {indent = true}))

	io.close(file)
	file = nil
end


function globalData.readSettings()
	local path = system.pathForFile(globalData.settings_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	if not file then
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local jsonString = ""
	for data in file:lines() do
		jsonString = jsonString .. "\n" .. data
	end

	if jsonString ~= "" then
		globalData.settings = json.decode(jsonString)
	else
		globalData.settings = globalData.defaultSettings
	end

	io.close(file)
	file = nil
end

function globalData.deleteSettings()
	globalData.settings = globalData.defaultSettings

	local path = system.pathForFile(globalData.settings_file, system.DocumentsDirectory)
	os.remove(path)
end

function globalData.transitionTo(object,x,y,t)
	-- local dt = (1/60)*1000
	local dt = 10
	local iter_count = math.floor((1000*t)/dt)
	local dx = -(object.x - x)/iter_count
	local dy = -(object.y - y)/iter_count

	local function timerFunc(event)
		if object then 
			object:translate(dx,dy)
		else
			timer.cancel(event.source)
		end
	end

	timer.performWithDelay(dt, timerFunc, iter_count)
end


function globalData.parseMenuSearch(event, searchGroup, dims)
	-- Clear display group
	local result_index = 1
	local function addSearchResult(result_text)
		local resultBox = display.newRect(0, result_index*globalData.search_bar.height, dims.width - dims.strokeWidth, dims.height)
		resultBox.strokeWidth = 2
		resultBox:setStrokeColor(0.2)

		local result_text_params = {text = result_text,
									x = resultBox.x,
									y = resultBox.y,
									width = 0.8*resultBox.width,
									height = 0,
									font = native.systemFont,
									fontSize = 0.6*globalData.search_bar.size}
		local result_text = display.newText(result_text_params)
		result_text:setFillColor(0)

		local function onTouch(event)
			for i = 1,searchGroup.numChildren,1 do
				searchGroup:remove(1)
			end
			globalData.active_recipe = result_text.text
			composer.gotoScene("ViewRecipePage", {effect = "slideRight", time = globalData.transition_time, params = {name = globalData.active_recipe}})
			globalData.search_bar.text = ""
			native.setKeyboardFocus(nil)
			return true
		end

		result_index = result_index + 1
		resultBox:addEventListener("tap", onTouch)
		searchGroup:insert(resultBox)
		searchGroup:insert(result_text)
	end

	for i = 1,searchGroup.numChildren,1 do
		searchGroup:remove(1)
	end

	if event.phase == "editing" then
		if #event.text > 0 then
			-- result_foods = cookbook.findRecipe(event.text)
			result_foods = cookbook.searchMenu(event.text)

			for food, value in pairs(result_foods) do
				-- print(food)
				addSearchResult(food)
				if result_index > 5 then
					result_index = 1
					break
				end
			end
		end


	end
end

-- Add keyword to food
local function appendKeyword(keyword, value)
	keyword = string.lower(keyword)

	-- Avoid appending null keywords
	if keyword == "" or value == "" then
		return
	end

	-- print("Inserted " .. value .. " to " .. keyword)

	if globalData.keywords.keyword then
		table.insert(globalData.keywords[keyword], value)
	else
		globalData.keywords[keyword] = {}
		table.insert(globalData.keywords[keyword], value)
	end
end

-- Add food to menu
local function appendRecipe(Food, Ingredient, Amount, Unit, Step)

	if Food == "" then
		return
	end

	if not globalData.active_recipe then
		globalData.active_recipe = Food
	end

	-- if not globalData.keywords[Food] then
	-- 	globalData.keywords[Food] = {}
	-- 	table.insert(globalData.keywords[Food], food)
	-- end

	-- If recipe does not exist, create a table for it
	if not globalData.menu[Food] then
		globalData.menu[Food] = {}
		globalData.menu[Food].ingredients = {}
		globalData.menu[Food].steps = {}
	end

	local text_amount = Amount
	local slash_index = 0
	local integer_index = 0

	for i = 1,#Amount,1 do
		if Amount:sub(i,i) == "/" then
			slash_index = i
			break
		elseif Amount:sub(i,i) == " " or Amount:sub(i,i) == "&" then
			integer_index = i
		end
	end

	amount_val = 0

	if integer_index > 0 then
		amount_val = amount_val + tonumber(Amount:sub(integer_index-1, integer_index-1))
	end

	if slash_index > 0 then
		amount_val = amount_val + tonumber(Amount:sub(slash_index-1,slash_index-1))/tonumber(Amount:sub(slash_index+1,slash_index+1))
	end

	if integer_index == 0 and slash_index == 0 then
		amount_val = tonumber(Amount)
	end

	if Ingredient ~= "" then
		table.insert(globalData.menu[Food].ingredients, {name = Ingredient, amount = amount_val, unit = Unit, text_amount = text_amount})
	end

	if Step ~= "" then
		table.insert(globalData.menu[Food].steps, Step)
	end
end

-- Read Google Sheets file for data
local function readMenuFromWeb(event)

	-- perform basic error handling 
	if ( event.isError ) then 
		print( "Network error!") 
	else 
		local csvFile = event.response 
		local csvData, headers = ftcsv.parse(csvFile, ",", {loadFromString=true, headers=true}) 

		local foods_examined = {}

		for row, entries in pairs(csvData) do
			-- Check to see if a recipe already exists (and overwrite if it does)
			if not foods_examined[entries['Recipe']] then
				foods_examined[entries['Recipe']] = true
				globalData.menu[entries['Recipe']] = nil
			end

			-- Log all keywords and their associated foods
			appendKeyword(entries['Keywords'], entries['Recipe'])
			appendRecipe(entries['Recipe'], 
						 entries['Ingredients'], 
						 entries['Ingredient Amount'], 
						 entries['Unit'], 
						 entries['Steps'])
		end
	end

	globalData.info_received = true
end


function globalData.readWebMenu()

	local loading_text_params = {text = "Loading From Database...",
								 x = display.contentCenterX,
								 y = display.contentCenterY,
								 width = 0.8*display.contentWidth,
								 fontSize = 0.07*display.contentHeight,
								 font = native.systemFont,
								 align = "center"}
	local load_text = display.newText(loading_text_params)

	local testFunc = function(event)
		if globalData.info_received then
			globalData.activeScene = "BrowsePage"
			composer.gotoScene("BrowsePage")
			load_text:removeSelf()
			timer.cancel(event.source)
		end
	end

	network.request(url, "GET", readMenuFromWeb)

	globalData.functionHandle = timer.performWithDelay(100, testFunc, -1)

	return true
end

function globalData.reloadApp()
	composer.removeScene(globalData.activeScene)
	composer.gotoScene(globalData.activeScene)
	globalData.tab_bar:removeSelf()
	globalData.tab_bar = cookbook.createTabBar()

	for i = 1,#globalData.all_scenes,1 do
		composer.removeScene(globalData.all_scenes[i])
	end
end

-- globalData.info_received = true
local test = false
globalData.readSettings()
globalData.readFavourites()
globalData.readCustomMenu()
-- test = globalData.readWebMenu();
if globalData.settings.showDefaultRecipes then globalData.readDefaultMenu() end
globalData.loadMenuImages()
globalData.cleanupFoodImages()
app_colors.changeTo(globalData.settings.colorScheme or "blue")
if not app_colors.browse then
	app_colors.changeTo("blue")
end
-- app_colors.changeTo("light")

if not test then
	globalData.activeScene = "BrowsePage"
	globalData.tab_bar = cookbook.createTabBar()
	composer.gotoScene("BrowsePage")
end