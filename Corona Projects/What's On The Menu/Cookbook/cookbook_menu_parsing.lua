local globalData = require("globalData")
local cookbook = require("Cookbook.cookbook_main")

local menu_parser = {}

function menu_parser.findRecipe(search_word)
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


function menu_parser.searchMenu(search_word)
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

function menu_parser.searchIngredients(search_word)
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


return menu_parser
