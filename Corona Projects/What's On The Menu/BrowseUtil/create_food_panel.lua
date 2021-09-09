local globalData = require("globalData")
local cookbook = require("cookbook")
local app_colors = require("AppColours")
local app_network = require("lib.network.library")
local app_transitions = require("AppTransitions")
local composer = require("composer")
local util = require("GeneralUtility")

local function createFoodPanel(title, x, y, width, height, parent, color, text_color)
	local panel_group = display.newGroup()

	-- Create the main background rectangle
	local panel = display.newRoundedRect(panel_group, 0, 0, width, height, 0.1*height)
	panel.id = "panel"
	panel:setFillColor(unpack(color))

	local has_image = globalData.gallery[title] ~= nil
	if globalData.gallery[title] then

		panel.fill = {	type 		= "image",
						filename 	= globalData.textures[title].filename,
						baseDir 	= globalData.textures[title].baseDir}

	end

	function panel:tap(event)
		globalData.activeRecipe = title
		if globalData.settings.recipeStyle == "portrait" then
			app_transitions.moveTo("ViewRecipePage", title)
		else
			app_transitions.moveTo("ViewLandscapeRecipe", title)
		end
	end
	panel:addEventListener("tap", panel)

	-- Add a dark copy of the panel to appear as a shadow
	local panel_shadow = display.newRoundedRect(panel_group, -0.015*display.contentWidth, 0.02*display.contentWidth, width, height, 0.1*height)
	panel_shadow.id = "panel_shadow"
	panel_shadow:setFillColor(0,0,0,0.4)

	-- Add a faint background to text with an image to make it more readable
	if has_image then
		local front_shadow = display.newRoundedRect(panel_group, 0, 0, width, height, 0.1*height)
		front_shadow.id = "panel_front_shadow"
		front_shadow:setFillColor(0, 0, 0, 0.1)
	end

	-- Label the panel with the recipe title
	local panel_text_params = {text = title,
							   x = -0.47*panel.width,
							   y = -0.15*panel.height,
							   width = 0.6*panel.width,
							   height = 0,
							   font = native.systemFontBold,
							   fontSize = 0.08*math.sqrt(panel.height*panel.width),
							   align = "left"}
	local panel_text = display.newText(panel_text_params)
	panel_text:setFillColor(has_image and 1 or unpack(app_colors.browse.recipe_title))
	panel_text.anchorX = 0
	panel_text.anchorY = 0
	panel_group:insert(panel_text)

	-- Show the prep time
	local prep_text = globalData.menu[title].prep_time
	if prep_text and prep_text ~= "" then
		local prep_time = display.newText({	text = "Prep Time: " .. prep_text,
										 	x = -0.45*width,
										 	y = 0.25*panel.height,
										 	width = 0.6*width,
										 	fontSize = globalData.smallFontSize})
		prep_time.anchorY = 0
		prep_time.anchorX = 0
		prep_time:setFillColor(has_image and 1 or unpack(app_colors.browse.recipe_info))
		panel_group:insert(prep_time)
	end

	-- Show the cook time
	local cook_text = globalData.menu[title].cook_time
	if cook_text and cook_text ~= "" then
		local cook_time = display.newText({	text = "Cook Time: " .. cook_text,
										 	x = -0.45*width,
										 	y = 0.25*panel.height + 0.1*height,
										 	width = 0.6*width,
										 	fontSize = globalData.smallFontSize})
		cook_time.anchorY = 0
		cook_time.anchorX = 0
		cook_time:setFillColor(has_image and 1 or unpack(app_colors.browse.recipe_info))
		panel_group:insert(cook_time)
	end

	-- Add a favourite icon
	local star = display.newImageRect("Image Assets/Small-Star.png", 0.07*panel.width, 0.07*panel.width)
	star.x = 0.4*panel.width
	star.y = 0.35*panel.height
	panel_group:insert(star)

	local empty_star = display.newImageRect("Image Assets/Small-Empty Star.png", 0.07*panel.width, 0.07*panel.width)
	empty_star.x = 0.4*panel.width
	empty_star.y = star.y
	panel_group:insert(empty_star)

	-- Determine what state the star should be in (favourite or not favourite)
	if not globalData.favourites[title] then
		star.alpha = 0
	end

	-- Add tap function to add/remove the recipe from the favourites list
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

	-- Edit Icon
	local edit_image = "Image Assets/White-Edit-Graphic.png"
	if app_colors.scheme == "light" and not has_image then edit_image = "Image Assets/Edit-Graphic.jpg" end
	local edit_params = {image = edit_image, tap_func = function(event) return cookbook.editRecipe(title) end, color = {0,0,0,0.01}}
	local edit_button = tinker.newButton(0.4*width, -0.15*height, 0.2*height, 0.2*height, edit_params)
	panel_group:insert(edit_button)

	-- Trash Icon
	local trash_image = "Image Assets/White-Trash-Graphic.png"
	if app_colors.scheme == "light" and not has_image then trash_image = "Image Assets/Trash-Graphic-Simple.png" end
	local trash_icon = display.newImageRect(panel_group, trash_image, empty_star.width, empty_star.height)
	trash_icon.x = 0.25*panel.width
	trash_icon.y = empty_star.y

	-- Function To Delete a Food From Memory
	function trash_icon:tap(event)
		local function trash_listener(event)
			if event.index == 1 then 
				globalData.menu[title] = nil
				globalData.favourites[title] = nil
				globalData.writeCustomMenu()
				globalData.deleteFoodImage(title)

				if app_network.config.logged_in then
					app_network.uploadData()
					app_network.log({message = "Deleted " .. title, type = "local"})
					globalData.writeNetwork()
				end

				composer.gotoScene(globalData.activeScene)
			end
		end
		native.showAlert("What's On The Menu", "Are you sure you want to delete \"" .. title .. "\"?", {"Yes, I'm Sure", "Cancel"}, trash_listener )

		return true
	end
	trash_icon:addEventListener("tap", trash_icon)

	-- Function to add an image to a recipe
	local function image_listener(event)

		local function selectListener(event)
			if event.index == 1 then
				cookbook.captureFoodImage(title)

			elseif event.index == 2 then
				cookbook.selectFoodImage(title)

			elseif event.index == 3 then
				globalData.deleteFoodImage(title)
				composer.gotoScene(globalData.activeScene)
			end
		end

		local options = {"Take Photo", "Select From Device"}
		if globalData.gallery[title] then
			table.insert(options, "Delete Photo")
		end
		native.showAlert("Corona", "Select Photo Method", options, selectListener)
		return true
	end

	local image_image = "Image Assets/Small-White-Camera-Graphic.png"
	if app_colors.scheme == "light" and not has_image then image_image = "Image Assets/Small-Camera-Graphic.png" end
	local image_params = {image = image_image, color = {0,0,0,0.01}, tap_func = image_listener}
	local image_button = tinker.newButton(trash_icon.x - 0.15*width, trash_icon.y, trash_icon.width, trash_icon.height, image_params)
	panel_group:insert(image_button)

	panel_group.x = x
	panel_group.y = y

	panel_group.id = title

	panel_shadow:toBack()

	return panel_group
end

return createFoodPanel
