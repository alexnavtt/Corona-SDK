local cookbook = require("cookbook")
local globalData = require("globalData")
local app_colors = require("AppColours")
local composer = require("composer")
local util = require("GeneralUtility")
local app_transitions = require("AppTransitions")

local tab_util = {}
local tab_titles 	= {'Cookbook','Favourites','New Recipe'} --,'Settings'} --'Custom Search'
local page_titles 	= {"BrowsePage", "FavouritesPage", "NewRecipePage", "FriendPage", "Settings"} -- "CustomPage",
local icon_paths 	= {"Small-Recipe-App-Icon-Transparent.png", "Small-Star.png", "Small-Recipe-Card-Graphic.png", "Small-Settings-Graphic.png"}
local num_tabs 		= #tab_titles

tab_util.tab_height = 0.05*display.contentHeight


-- Find the direction to transition in order to move pages naturally
function tab_util.findDirection(last_name, this_name)
	local last_index, this_index

	if this_name == "Settings" then return "slideRight" end

	for i = 1,#page_titles,1 do
		if page_titles[i] == last_name then
			last_index = i
		end

		if page_titles[i] == this_name then
			this_index = i
		end
	end

	if last_index < this_index then
		return "slideLeft"
	elseif last_index > this_index then
		return "slideRight"
	else
		return nil
	end
end



-- ------ Search Bar ------- --
local function createSearchBar(event)
	local tab_height = tab_util.tab_height
	local search_group = display.newGroup()
	local options_group = display.newGroup()
	search_group:insert(options_group)

	local options = {radius = 0.025*display.contentHeight, textColor = app_colors.tab_bar.search_text, backgroundColor = app_colors.tab_bar.search_bkgd, 
					 defaultText = "Search Recipes...", displayGroup = search_group, strokeWidth = 5, strokeColor = app_colors.tab_bar.outline}
	local search_bar = tinker.newTextField(display.contentCenterX, 2*tab_height, 0.8*display.contentWidth, 0.05*display.contentHeight, options)
	search_bar.alpha = 0

	local glass_screen = display.newRect(search_group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	glass_screen:setFillColor(0,0,0,0.3)
	glass_screen:addEventListener("tap", function(event) native.setKeyboardFocus(nil); search_group:removeSelf(); return true; end)
	glass_screen:addEventListener("touch", function(event) return true end)

	glass_screen:toBack()		

	transition.to(search_bar, {time = 300, alpha = 1})

	-- Search Bar Listener
	local function searchFoods(event)
		if not event.text then return end

		for i = 1,options_group.numChildren,1 do
			options_group:remove(1)
		end

		local possible_foods = cookbook.searchMenu(event.text)
		local delta_y = 1.5*search_bar:getHeight()
		local y = search_bar.y + delta_y
		local count = 0
		local strokeColor = {1}
		if app_colors.color_scheme == "light" then strokeColor = {0} end

		for name, value in pairs(possible_foods) do
			local function tap_func(event)
				globalData.activeRecipe = name
				local page = "ViewRecipePage"
				if globalData.settings.recipeStyle == "landscape" then page = "ViewLandscapeRecipe" end
				app_transitions.moveTo(page, name)
			end

			local params = {label = name, displayGroup = options_group, radius = 20, tap_func = tap_func, labelColor = app_colors.tab_bar.search_text,
							color = app_colors.tab_bar.search_bkgd, strokeColor = app_colors.tab_bar.search_outline, strokeWidth = 5}
			local option = tinker.newButton(display.contentCenterX, y, search_bar:getWidth(), search_bar:getHeight(), params)
		
			y = y + delta_y
			count = count + 1
			if count == 11 then break end
		end
	end
	search_bar:addEventListener("userInput", searchFoods)

	-- Set Keyboard Focus
	search_bar._background:dispatchEvent({name = "tap", x = display.contentCenterX})

	return true
end



function tab_util.createTabBar()
	local tab_group  = display.newGroup()
	local tab_height = tab_util.tab_height
	local width = 0.8*display.contentWidth

	local tab_bar = display.newRoundedRect(tab_group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height, 0.00*display.contentWidth)
	tab_bar:setFillColor(unpack(app_colors.tab_bar.background))
	tab_bar:setStrokeColor(unpack(app_colors.tab_bar.outline))

	local shadow = display.newRect(tab_group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height)
	shadow:setFillColor(0,0,0,0.2)
	shadow:translate(0, 0.1*tab_height)
	shadow:toBack()

	local underline = display.newLine(tab_group, 0, tab_height, display.contentWidth, tab_height)
	underline.strokeWidth = 4
	underline:setStrokeColor(unpack(app_colors.recipe.outline))

	local icon_height 	= 0.07*display.contentWidth
	local icon_spacing 	= 0.1*display.contentWidth
	local icon_loc		= 0.7*icon_spacing

	local tab_width  = 1/num_tabs*width

	local buttons = {}
	local active_index = 4

	for i = 1,num_tabs,1 do
		local button

		local function onTap(event)
			local old_one = globalData.activeScene

			globalData.activeScene = page_titles[i]
			for i = 1,#buttons,1 do
				buttons[i]:setBackgroundColor({1,1,1,0.1})
				if i == #buttons then buttons[i]:setBackgroundColor({1,1,1,0.01}) end
			end
			button:setBackgroundColor({1,1,1,0.2})

			if old_one == page_titles[i] then return true end
			app_transitions.moveTo(page_titles[i])
			return true
		end 

		local options = {label = tab_titles[i], color = {1,1,1,0.1}, labelColor = app_colors.tab_bar.button_text, tap_func = onTap, fontSize = globalData.smallFontSize, displayGroup = tab_group, font = native.systemFontBold, radius = 30}
		button = tinker.newButton((i-1)*tab_width + tab_width*0.7, 0.5*tab_height, 0.8*tab_width, 0.7*tab_height, options)
		button.id = "bkgd-" .. page_titles[i]
		button.count = i

		if globalData.activeScene == page_titles[i] then active_index = i end

		table.insert(buttons, button)
	end

	local friends_button
	local function goToFriend(event)
		for i = 1,#buttons,1 do
			buttons[i]:setBackgroundColor({1,1,1,0.1})
		end
		friends_button:setBackgroundColor({1,1,1,0.2})

		if globalData.activeScene == "FriendPage" then return true end

		globalData.activeScene = "FriendPage"
		app_transitions.moveTo("FriendPage")
		return true
	end

	local friends_options = {image = "Image Assets/Cheese-Graphic.png", tap_func = goToFriend, displayGroup = tab_group, color = {0,0,0,0.01}}
	friends_button = tinker.newDot(0.88*display.contentWidth, 0.5*tab_height, 0.4*tab_height, friends_options)
	friends_button.id = "bkgd-FriendPage"
	table.insert(buttons, friends_button)

	local settings_button
	local function goToSettings(event)
		for i = 1,#buttons,1 do
			buttons[i]:setBackgroundColor({1,1,1,0.1})
		end
		settings_button:setBackgroundColor({1,1,1,0.2})

		if globalData.activeScene == "Settings" then return true end

		globalData.activeScene = "Settings"
		app_transitions.moveTo("Settings")
		return true
	end 

	local options = {image = "Image Assets/Small-Settings-Graphic.png", tap_func = goToSettings, displayGroup = tab_group, color = {0,0,0,0.01}}
	settings_button = tinker.newDot(0.95*display.contentWidth, 0.5*tab_height, 0.4*tab_height, options)
	settings_button.id = "bkgd-Settings"
	table.insert(buttons, settings_button)

	buttons[active_index]:setBackgroundColor({1,1,1,0.2})


	-- ----------------------------- --
	-- ------- Search Button ------- --
	-- ----------------------------- --
	local search_button

	local options = {image = "Image Assets/Small-Magnifying-Glass-Graphic.png", tap_func = createSearchBar, displayGroup = tab_group, color = {0,0,0,0.01}}
	search_button = tinker.newButton(settings_button.width*0.65, settings_button.y, settings_button.width, settings_button.height, options)

	-- Update the tab bar so that it is at the current scene
	function tab_group:update()
		local current_scene = composer.getSceneName("current")
		local button = util.findID(self, "bkgd-" .. current_scene)
		if button then
			local tap_listener = util.findID(button, "button")
			tap_listener:dispatchEvent({name = "tap"})
		end
		return true
	end

	return tab_group
end

function tab_util.simpleTabBar(title, back_text, back_page, next_text, next_page)
	local group = display.newGroup()
	local tab_height = tab_util.tab_height

	local tab_bar = display.newRect(group, display.contentCenterX, 0.5*tab_height, display.contentWidth, tab_height)
	tab_bar:setFillColor(unpack(app_colors.tab_bar.background))
	tab_bar:setStrokeColor(unpack(app_colors.tab_bar.outline))
	tab_bar.strokeWidth = 3

	local function back_tap(event)
		globalData.activeScene = back_page
		if back_page == "NewRecipePage" then
			composer.gotoScene(back_page, {effect = "slideDown", time = globalData.transition_time})
		else
			composer.gotoScene(back_page, {effect = "slideRight", time = globalData.transition_time})
		end
	end

	local back_params = {label = back_text, tap_func = back_tap, color = {1,1,1,0.1}, labelColor = app_colors.tab_bar.button_text, radius = 0.02*display.contentWidth, fontSize = globalData.mediumFontSize}
	local back_button = tinker.newButton(0.03*display.contentWidth, 0.5*tab_height, 0.25*display.contentWidth, 0.8*tab_height, back_params)
	back_button.anchorX = 0
	back_button.id = back_page
	group:insert(back_button)

	local function next_tap(event)
		globalData.activeScene = next_page
		composer.gotoScene(next_page, {effect = "slideLeft", time = globalData.transition_time})
	end

	local next_params = {label = next_text, tap_func = next_tap, color = {1,1,1,0.1}, labelColor = app_colors.tab_bar.button_text, radius = 0.02*display.contentWidth, fontSize = globalData.mediumFontSize}
	local next_button = tinker.newButton(0.97*display.contentWidth, 0.5*tab_height, 0.25*display.contentWidth, 0.8*tab_height, next_params)
	next_button.anchorX = next_button.width
	next_button.id = next_page
	group:insert(next_button)

	local title = display.newText({text = title,
								   x = display.contentCenterX,
								   y = 0.5*tab_height,
								   width = 0.45*display.contentWidth,
								   fontSize = globalData.titleFontSize,
								   font = native.systemFontBold,
								   align = "center"})
	title:setFillColor(unpack(app_colors.tab_bar.title))
	group:insert(title)

	while title.height > 0.9*tab_height do
		title.size = 0.95*title.size
	end

	return group
end

return tab_util
