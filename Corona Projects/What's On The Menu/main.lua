-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer 		= require("composer")
local globalData 	= require("globalData")
local json 			= require("json")
local cookbook 		= require("cookbook")

local url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSsYVoMs9cpnRWNg-B7usduhVjY8GYzOb74rutaGxwtBhG8BcT7wdqKJ_3q34R2CtFCV8TagJktLVVO/pub?output=csv"
local ftcsv = require("ftcsv")

-- Data Storage
globalData.menu 		= {}
globalData.keywords 	= {}
globalData.favourites 	= {}
globalData.custom_menu 	= {}

-- Private Parameters
globalData.info_received = false
globalData.search_bar = native.newTextField(-500,-500,100,100)
globalData.numeric_text_field = native.newTextField(-500,-500,100,100)
globalData.steps_text_field = native.newTextBox(-500,-500,100,100)
globalData.numeric_text_field.inputType = "number"
globalData.activeTextDisplayLimit = 4

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
globalData.panel_color 			= {0.5, 0.5, 0.5}
globalData.panel_color_touched 	= {0.3, 0.3, 0.3}
globalData.background_color 	= {0.9}
globalData.tab_color 			= {0.8}
globalData.tab_text_color 		= {0.2}
globalData.light_text_color 	= {1}
globalData.dark_text_color 		= {0}

globalData.purple = {0.6, 0.0, 0.6}
globalData.pink   = {0.9, 0.0, 0.6}
globalData.blue   = {0.0, 0.4, 0.8}
globalData.red 	  = {0.9, 0.1, 0.1}
globalData.orange = {0.9, 0.5, 0.0}
globalData.green  = {0.0, 1.0, 0.4}
globalData.brown  = {0.4, 0.2, 0.0}
globalData.light_grey = {0.8}
globalData.dark_grey  = {0.4}
globalData.white = {1}
globalData.black = {0}

globalData.smallFontSize = 0.02*display.contentHeight
globalData.titleFontSize = 0.025*display.contentHeight

-- Geometry Parameters
globalData.panel_width 	= 0.9*display.contentWidth
globalData.panel_height = 0.2*display.contentHeight
globalData.tab_height 	= 0.085*display.contentHeight
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
globalData.scroll_options ={x = display.contentCenterX, 
							y = display.contentCenterY + 0.5*globalData.tab_height, 
							width = display.contentWidth, 
							height = display.contentHeight - globalData.tab_height,
							friction = 1.0,
							horizontalScrollDisabled = true,
							isBounceEnabled = false,
							backgroundColor = globalData.background_color,
							bottomPadding = 0.3*display.contentWidth}

-- File Storage
globalData.favourites_file = "Favourites.txt"
globalData.custom_recipes_file = "CustomRecipes.txt"

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

	globalData.steps_text_field.size = globalData.smallFontSize
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

	print(jsonString)

	if jsonString ~= "" then
		globalData.menu = json.decode(jsonString)
	else
		globalData.menu = {}
	end

	io.close(file)
	file = nil

	for name, value in pairs(globalData.menu) do
		print(" ")
		print(name)
		print(value)
	end
end

function globalData.deleteCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	os.remove(path)
end

function globalData.transitionTo(object,x,y,t)
	local dt = (1/60)*1000
	local iter_count = math.floor((1000*t)/dt)
	local dx = -(object.x - x)/iter_count
	local dy = -(object.y - y)/iter_count

	local function timerFunc(event)
		object:translate(dx,dy)
	end

	timer.performWithDelay(dt, timerFunc, iter_count)
end


function globalData.parseMenuSearch(event, searchGroup)
	-- Clear display group
	local result_index = 1
	local function addSearchResult(result_text)
		local resultBox = display.newRect(globalData.search_bar.x, globalData.search_bar.y + result_index*globalData.search_bar.height, globalData.search_bar.width, globalData.search_bar.height)
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
		-- composer.gotoScene("MainMenu")
		globalData.activeScene = "BrowsePage"
		composer.gotoScene("BrowsePage")
		load_text:removeSelf()
		timer.cancel(event.source)
	end
end

globalData.readFavourites()
globalData.readCustomMenu()
network.request(url, "GET", readMenuFromWeb)
globalData.functionHandle = timer.performWithDelay(100, testFunc, -1)