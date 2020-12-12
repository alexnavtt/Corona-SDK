local globalData = require("globalData")
local ftcsv = require("ftcsv")
local composer = require("composer")

local url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSsYVoMs9cpnRWNg-B7usduhVjY8GYzOb74rutaGxwtBhG8BcT7wdqKJ_3q34R2CtFCV8TagJktLVVO/pub?output=csv"

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


local function readWebMenu()

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