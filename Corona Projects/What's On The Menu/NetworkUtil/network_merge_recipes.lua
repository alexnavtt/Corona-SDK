local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")

local function queryKeepRecipes(new_recipes)

end

local function mergeRecipes(server_recipes)
	local new_server_recipes = {}

	-- Search for new recipes
	for key, value in pairs(server_recipes) do
		if not globalData.menu[key] then
			table.insert(new_server_recipes, key)
		end
	end

	-- Search for outdated recipes
	for key, value in pairs(globalData.menu) do
		local local_timestamp = value.timestamp
		local remote_timestamp

		if server_recipes[key] then 
			remote_timestamp = server_recipes[key].timestamp
		else
			-- Easiest way to implement continue in Lua
			-- goto continue
		end

		-- Update recipes if remote timestamp is more recent
		if local_timestamp < remote_timestamp then
			value = server_recipes[key]
		end


		-- ::continue::
	end

end

return mergeRecipes
