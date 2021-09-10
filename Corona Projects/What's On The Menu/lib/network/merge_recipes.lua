local widget = require("widget")
local composer = require("composer")

local tinker = require("ext_libs.tinker.tinker")
local globalData = require("globalData")
local app_network = require("lib.network.main")

local cX = display.contentCenterX
local cY = display.contentCenterY
local W  = display.contentWidth
local H  = display.contentHeight

local function insertRecipe(name, scrollView, y_level)
	local text = display.newText({text = name, x = 0.05*scrollView.width, y = y_level, width = 0.8*scrollView.width, fontSize = globalData.mediumFontSize})
	text:setFillColor(0)
	text.anchorX = 0
	scrollView:insert(text)

	local switch_params = {defaultState = "on"}
	local switch = tinker.newSlidingSwitch(0.9*scrollView.width, y_level, switch_params)
	scrollView:insert(switch)

	return text.height
end

local function queryKeepRecipes(new_recipes, to_delete, full_menu, delete)
	if #new_recipes == 0 and #to_delete == 0 then
		app_network.uploadData()
		return true
	end

	local group = display.newGroup()

	Runtime:removeEventListener("key", globalData.goBack)

	local glass_screen = display.newRect(group, cX, cY, W, H)
	glass_screen:setFillColor(0)
	glass_screen.alpha = 0.5

	function glass_screen:tap(event)
		return true
	end

	function glass_screen:touch(event)
		return true
	end

	glass_screen:addEventListener("tap", glass_screen)
	glass_screen:addEventListener("touch", glass_screen)

	local bkgd = display.newRect(group, cX, cY, 0.8*W, 0.8*H)
	bkgd:setFillColor(0.9)

	local form_params = {x = cX, y = cY,
						 width = bkgd.width, height = 0.8*bkgd.height,
						 horizontalScrollDisabled = true,
						 hideBackground = true}
	local form = widget.newScrollView(form_params)
	group:insert(form)

	local title = display.newText({text = "Found These New Recipes\nSelect Which Ones You'd Like to Keep",
								   x = bkgd.x - 0.45*bkgd.width,
								   y = bkgd.y - 0.48*bkgd.height,
								   width = 0.9*bkgd.width,
								   height = 0.1*bkgd.height,
								   parent = group,
								   fontSize = globalData.mediumFontSize,
								   font = native.systemFontBold})
	title.anchorX = 0
	title.anchorY = 0
	title:setFillColor(0)

	local y_level = 0.1*form.height
	local x_level = 0.05*form.width

	for index, name in pairs(new_recipes) do
		local dH = insertRecipe(name, form, y_level)
		y_level = y_level + dH + 0.05*H
	end

	-- Forward decleration of button and listeners
	local ok_button = {}
	local onOK, onOKDelete

	-- If we're querying which ones to keep
	local function onOK(event)
		local scrollview = form._collectorGroup
		for i = 2,scrollview.numChildren,2 do
			if scrollview[i]:getState() == 1 then
				globalData.menu[scrollview[i-1].text] = full_menu[scrollview[i-1].text]
			end
		end
		app_network.uploadData()

		if #to_delete > 0 then
			title.text = "These Recipes Were Deleted on Another Device\nWould You Like To Save Any Of Them?"

			for i = 1,scrollview.numChildren,1 do
				form:remove(scrollview[i])
			end

			local y_level = 0.1*form.height
			for name, value in pairs(to_delete) do
				local dH = insertRecipe(name, form, y_level)
				y_level = y_level + dH + 0.05*H
			end

			ok_button:removeEventListener("tap", onOK)
			ok_button:addEventListener("tap", onOKDelete)
		else
			composer.gotoScene(composer.getSceneName("current"))
			group:removeSelf()
		end
	end

	-- If we're querying which ones to delete
	local function onOKDelete(event)
		local scrollview = form._collectorGroup
		for i = 2,scrollview.numChildren,2 do
			if scrollview[i]:getState() ~= 1 then
				globalData.menu[scrollview[i-1].text] = nil
			end
		end
		app_network.uploadData()
		globalData.writeCustomMenu()
		group:removeSelf()
		composer.gotoScene(composer.getSceneName("current"))
	end

	local ok_params = {label = "OK", color = {0,0,0,0.01}, labelColor = {0}, displayGroup = group, tap_func = onOK}
	
	-- If there is nothing to add but stuff to delete
	if #new_recipes == 0 then 
		title.text = "These Recipes Were Deleted on Another Device\nWould You Like To Save Any Of Them?"
		for key, value in pairs(to_delete) do
			local dH = insertRecipe(name, form, y_level)
			y_level = y_level + dH + 0.05*H
		end
		ok_params.tap_func = onOKDelete
	end


	local ok_button = tinker.newButton(cX, bkgd.y + 0.45*bkgd.height, 0.5*bkgd.width, 0.08*bkgd.height, ok_params)

	return group
end

local function mergeRecipes(server_recipes)
	local new_server_recipes = {}
	local to_delete = {}
	local to_update = {}

	-- Search for new recipes
	for key, value in pairs(server_recipes) do
		if not globalData.menu[key] then
			table.insert(new_server_recipes, key)
		end
	end

	for key, value in pairs(globalData.menu) do
		-- Search for outdated recipes
		local local_timestamp = value.timestamp

		if server_recipes[key] then 
			local remote_timestamp = server_recipes[key].timestamp
		
			-- Update recipes if remote timestamp is more recent
			if local_timestamp < remote_timestamp then
				to_update[key] = true
			end
		else
			-- Find recipes that have been deleted
			if local_timestamp < app_network.config.last_upload_time then
				to_delete[key] = true
			end

		end
	end

	for key, value in pairs(to_update) do
		globalData.writeNetworkLog("Updated Recipe: " .. key)
		globalData.menu[key] = server_recipes[key]
	end
	globalData.writeCustomMenu()

	-- Query which ones to keep and which ones to delete
	queryKeepRecipes(new_server_recipes, to_delete, server_recipes)


end

return mergeRecipes
