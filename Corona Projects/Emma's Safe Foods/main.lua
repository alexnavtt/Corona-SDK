-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget   = require "widget"
local composer = require "composer"


-- event listeners for tab buttons:
local function onFirstView( event )
	composer.gotoScene( "view1" )
end

local function onSecondView( event )
	composer.gotoScene( "view2" )
end

-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons =
{
	{ 	label="Search Foods", 
		-- defaultFile="button1.png", 
		-- overFile="button1-down.png", 
		width = 32, height = 32, 
		onPress=onFirstView, selected=true,
		labelYOffset = -10,
	},

	{ 	label="Allergies",
		-- defaultFile="button2.png", 
		-- overFile="button2-down.png", 
		width = 32, height = 32, 
		onPress=onSecondView,
		labelYOffset = -10,
	},
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
	top = 0, --display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons,
	height = 50
}

local globalData = require('globalData')

globalData.BackTextColor = {0.2, 0.0, 1.0}

globalData.Keywords  = {}
globalData.Foods 	 = {}
globalData.Allergies = {}
globalData.Allergies.FruitAndVeg  = {}
globalData.Allergies.DairyAndNuts = {}
globalData.Allergies.Seasonings   = {}
globalData.Allergies.Caution 	  = {}

-- Link to Google sheet 
local URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRiEz5crxkwIK4QVtlTbikZQu7a2vbQoa_ZqcyuED_ySo9TN9sLx6LEd3gjYkPJvhyzniK6Lk_MWsra/pub?output=csv"
local ftcsv = require('ftcsv') 

local function loginCallback(event)

	print("Loading from database...")
	print(" ")

	-- perform basic error handling 
	if ( event.isError ) then 
		print( "Network error!") 
	else 
		local csvFile = event.response 
		local csvData, headers = ftcsv.parse(csvFile, ",", {loadFromString=true, headers=true}) 

		local row = 2
		local cloumn_label = "Safe Foods"

		for row, entries in pairs(csvData) do 

			if #entries["Food"] > 0 then
				-- allowed = tonumber(entries["Allowable"])
				brand 	= entries["Brand"]
				flavour = entries["Type"]
				food 	= entries["Food"]

				if not globalData.Foods[food] then
					-- Add Food if not already in table
					globalData.Foods[food] = {}  -- Brand table
					globalData.Foods[food][brand] = {} -- Flavour table
					globalData.Foods[food][brand][flavour] = true

				else
					-- Add Brand if not already associated with the food
					if not globalData.Foods[food][brand] then
						globalData.Foods[food][brand] = {}
						globalData.Foods[food][brand][flavour] = true
					else
						-- Add flavour if not already associated with the brand
						if not globalData.Foods[food][brand][flavour] then
							globalData.Foods[food][brand][flavour] = true
						end
					end
				end

				-- Associate keywords wtih foods
				if entries["Keywords"] ~= "" then
					keys = ftcsv.parse(entries["Keywords"], ",", {loadFromString=true, headers = false})

					for i = 1,#keys[1],1 do
						key = string.lower(keys[1][i])
						if string.sub(key, 1, 1) == " " then
							key = string.sub(key,2,-1)
						end

						if globalData.Keywords[key] == nil then
							globalData.Keywords[key] = {food}
							-- print("Creating keyword " .. key .. " with entry " .. food)
						else
							for index, foods in pairs(globalData.Keywords[key]) do
								if foods == food then
									double_found = true
									break
								else
									double_found = false
								end
							end

							if not double_found then
								-- print("New Entry: Adding " .. food .. " to " .. key)
								table.insert(globalData.Keywords[key], food)
							end
						end
					end
				end

				-- Associate recipes with foods
				if entries["Recipes"] ~= "" then
					recipes = ftcsv.parse(entries["Recipes"], ",", {loadFromString=true, headers = false})

					for i = 1,#recipes[1],1 do
						key = string.lower(recipes[1][i])
						if string.sub(key, 1, 1) == " " then
							key = string.sub(key,2,-1)
						end

						if globalData.Keywords[key] == nil then
							globalData.Keywords[key] = {food}
							-- print("Creating keyword " .. key .. " with entry " .. food)
						else
							for index, foods in pairs(globalData.Keywords[key]) do
								if foods == food then
									double_found = true
									break
								else
									double_found = false
								end
							end

							if not double_found then
								-- print("New Entry: Adding " .. food .. " to " .. key)
								table.insert(globalData.Keywords[key], food)
							end
						end
					end
				end

			end

			-- Record Vegetable Allergies
			if #entries["Fruit and Vegetable Allergies"] > 0 then
				globalData.Allergies.FruitAndVeg[entries["Fruit and Vegetable Allergies"]] = entries["Vegetable Severity"]
			end

			-- Record Vegetable Allergies
			if #entries["Dairy and Nut Allergies"] > 0 then
				globalData.Allergies.DairyAndNuts[entries["Dairy and Nut Allergies"]] = entries["Dairy Severity"]
			end

			-- Record Vegetable Allergies
			if #entries["Seasoning Allergies"] > 0 then
				globalData.Allergies.Seasonings[entries["Seasoning Allergies"]] = entries["Seasoning Severity"]
			end

			-- Record Vegetable Allergies
			if #entries["Caution Allergies"] > 0 then
				globalData.Allergies.Caution[entries["Caution Allergies"]] = entries["Caution Severity"]
			end

		end 

	end 

	-- print("Foods recorded:")
	-- for fields, something in pairs(globalData.Foods) do
	-- 	print(fields)
	-- end
	-- print(" ")

	-- print("Allergies recorded:")
	-- for fields, badness in pairs(globalData.Allergies) do
	-- 	print(fields .. ":    \tseverity " .. badness)
	-- end
	-- print(" ")

	-- print("Keywords:")
	-- for fields, key in pairs(globalData.Keywords) do
	-- 	print("Field: " .. fields)
	-- 	for something, key_word in pairs(key) do
	-- 		print(something .. ": " .. key_word)
	-- 	end
	-- end
	-- print(" ")
	globalData.ReceivedData = true

end 


network.request( URL, "GET", loginCallback )

testFunc = function(event)
	if globalData.ReceivedData then
		onFirstView() 
		timer.cancel(event.source)
	end
end

globalData.functionHandle = timer.performWithDelay(100, testFunc, -1)