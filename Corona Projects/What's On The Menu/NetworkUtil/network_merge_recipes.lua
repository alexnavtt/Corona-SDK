local widget = require("widget")
local composer = require("composer")

local util = require("GeneralUtility")
local tinker = require("Tinker")
local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")

local cX = display.contentCenterX
local cY = display.contentCenterY
local W  = display.contentWidth
local H  = display.contentHeight

local function queryKeepRecipes(new_recipes, full_menu)
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
		local text = display.newText({text = name, x = x_level, y = y_level, width = 0.8*form.width, fontSize = globalData.mediumFontSize})
		text:setFillColor(0)
		text.anchorX = 0
		form:insert(text)

		local switch_params = {defaultState = true}
		local switch = tinker.newSlidingSwitch(0.9*form.width, y_level, switch_params)
		form:insert(switch)

		y_level = y_level + text.height + 0.05*H
	end

	local function onOK(event)
		local scrollview = form._collectorGroup
		for i = 1,scrollview.numChildren,1 do
			print(scrollview[i]._state)
			if scrollview[i].id == "Tinker_Sliding_Switch" and scrollview[i]._state == 1 then
				globalData.menu[scrollview[i-1].text] = full_menu[scrollview[i-1].text]
			end
		end
		app_network.uploadData()
		group:removeSelf()
		composer.gotoScene(composer.getSceneName("current"))
	end
	local ok_params = {label = "OK", color = {0,0,0,0.01}, labelColor = {0}, displayGroup = group, tap_func = onOK}
	local ok_button = tinker.newButton(cX, bkgd.y + 0.45*bkgd.height, 0.5*bkgd.width, 0.08*bkgd.height, ok_params)

	return group
end

local function mergeRecipes(server_recipes)
	local new_server_recipes = {}

	-- Search for new recipes
	for key, value in pairs(server_recipes) do
		if not globalData.menu[key] then
			table.insert(new_server_recipes, key)
		end
	end

	-- Query which ones to keep
	if #new_server_recipes > 0 then
		util.printTable(new_server_recipes)
		queryKeepRecipes(new_server_recipes, server_recipes)
	end

	local to_delete = {}
	for key, value in pairs(globalData.menu) do
		-- Search for outdated recipes
		local local_timestamp = value.timestamp

		if server_recipes[key] then 
			local remote_timestamp = server_recipes[key].timestamp
		
			-- Update recipes if remote timestamp is more recent
			if local_timestamp < remote_timestamp then
				print("Updated " .. key)
				value = server_recipes[key]
			end
		else
			-- Find recipes that have been deleted
			if value.timestamp < app_network.config.last_upload_time then
				print("Deleted " .. key .. " from server")
				table.insert(to_delete, key)
			end

		end
	end

	for i = 1,#to_delete,1 do
		globalData.menu[to_delete[i]] = nil
	end
	globalData.writeCustomMenu()
	composer.gotoScene(composer.getSceneName("current"))



end

return mergeRecipes
