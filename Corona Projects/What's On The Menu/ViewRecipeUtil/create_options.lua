-- Solar2D Libraries
local composer = require("composer")

-- Custom Libraries
local cookbook = require("cookbook")
local globalData = require("globalData")
local app_colors = require("AppColours")
local app_network = require("AppNetwork")

-- Custom Functions
local showFriendsList = require("FriendsUtil.show_friends_list")

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

local function createOptions(name, scaling_factor, scene)
	local options = display.newGroup()
	options.x = W
	options.y = 0
	options.anchorX = 0
	options.anchorY = 0
	options.anchorChildren = true

	-- Display options
	local width = 0.7*W
	local height = H
	local spacing = 0.035*H
	local y_level = 0

	options.width = width
	options.height = height
	options.state = "hidden"

	local function ypp(dy)
		dy = dy or spacing
		y_level = y_level + dy
	end

	-- Visual Start
	local background = display.newRect(options, 0, y_level, width, height)
	background.anchorX = 0
	background.anchorY = 0
	background:addEventListener("tap", function(event) return true end)
	background:setFillColor(unpack(app_colors.medium_color))

	ypp()

	-- Back Button
	local arrow_image = "Image Assets/Small-Black-Up-Arrow-Graphic.png"
	if app_colors.scheme == "dark" then arrow_image = "Image Assets/Small-White-Up-Arrow-Graphic.png" end
	local back = display.newImageRect(options,arrow_image, 0.1*width, 0.1*width)
	back.x = back.width
	back.y = y_level
	back:rotate(270)

	ypp()

	-- Food Image
	local image = display.newRect(options, 0, y_level, width, math.min(width, 0.4*height))
	image.anchorX = 0
	image.anchorY = 0

	if globalData.textures[name] then
		image.height = math.min(width*globalData.gallery[name].height/globalData.gallery[name].width, 0.4*height)
		image.fill = {type = "image", filename = globalData.textures[name].filename, baseDir = globalData.textures[name].baseDir}
	else
		image.fill = {type = "image", filename = "Image Assets/Recipe-App-Icon.png"}
	end

	ypp(spacing/2 + image.height)


	-- Food Title
	local food_title = display.newText({text = name,
										x = width/2,
										y = y_level,
										width = 0.8*width,
										fontSize = globalData.titleFontSize,
										font = native.systemFontBold,
										align = "center"})
	food_title:setFillColor(unpack(app_colors.recipe.ing_text))
	food_title.anchorY = 0
	options:insert(food_title)

	ypp(spacing/2 + food_title.height)



	-- Food Info
	if globalData.menu[name].calories and globalData.menu[name].calories ~= "" then
		local calories = display.newText({	text = "- Calories: " .. globalData.menu[name].calories .. " kCal",
											x = 0.5*width,
											y = y_level,
											width = 0.8*width,
											fontSize = globalData.smallFontSize,
											align = "left"})

		calories:setFillColor(unpack(app_colors.recipe.ing_text))
		calories.anchorY = 0
		options:insert(calories)
		ypp(calories.height)
	end

	if globalData.menu[name].servings and globalData.menu[name].servings ~= "" then
		local servings = display.newText({	text = "- Serves:   " .. globalData.menu[name].servings,
											x = 0.5*width,
											y = y_level,
											width = 0.8*width,
											fontSize = globalData.smallFontSize,
											align = "left"})

		servings:setFillColor(unpack(app_colors.recipe.ing_text))
		servings.anchorY = 0
		options:insert(servings)
		ypp(servings.height)
	end

	ypp()


	-- Favourite Icon
	local favourite_text = display.newText({text = "Favourite",
											x = 0.05*width,
											y = y_level,
											width = 0.8*width,
											fontSize = globalData.mediumFontSize,
											font = native.systemFontBold})
	options:insert(favourite_text)
	favourite_text.anchorX = 0
	favourite_text:setFillColor(unpack(app_colors.recipe.ing_text))

	local star = display.newRect(options, favourite_text.width + 0.5*(width - favourite_text.width), y_level, 1.5*favourite_text.height, 1.5*favourite_text.height)

	if globalData.favourites[name] then
		star.fill = {type = "image", filename = "Image Assets/Small-Star.png"}
	else
		star.fill = {type = "image", filename = "Image Assets/Small-Empty Star.png"}
	end

	local function starTap(event)
		if globalData.favourites[name] then
			globalData.favourites[name] = nil
			star.fill = {type = "image", filename = "Image Assets/Small-Empty Star.png"}
		else
			globalData.favourites[name] = true
			star.fill = {type = "image", filename = "Image Assets/Small-Star.png"}
		end
	end
	star:addEventListener("tap", starTap)

	ypp(2*spacing)

	-- Edit Icon
	local edit = display.newText({	text = "Edit",
									x = favourite_text.x,
									y = y_level,
									width = favourite_text.width,
									font = native.systemFontBold,
									fontSize = globalData.mediumFontSize})
	edit:setFillColor(unpack(app_colors.recipe.ing_text))
	edit.anchorX = 0
	options:insert(edit)

	local edit_image = "Image Assets/Edit-Graphic.jpg"
	if app_colors.scheme == "dark" then edit_image = "Image Assets/White-Edit-Graphic.png" end
	local edit_icon = display.newImageRect(options,edit_image, star.width, star.height)
	edit_icon.x = star.x
	edit_icon.y = y_level

	edit_icon:addEventListener("tap", function(event) scene.glass_screen:dispatchEvent({name = "tap"}); return cookbook.editRecipe(name) end)

	ypp(2*spacing)

	-- Send to a Friend Icon
	local send = display.newText({text = "Send to a Friend",
								  x = edit.x, y = y_level,
								  width = edit.width,
								  font = native.systemFontBold,
								  fontSize = globalData.mediumFontSize})
	send:setFillColor(unpack(app_colors.recipe.ing_text))
	send.anchorX = 0
	options:insert(send)

	local send_image = "Image Assets/Cheese-Graphic.png"
	local send_icon  = display.newImageRect(options, send_image, star.width, star.height)
	send_icon.x = star.x
	send_icon.y = y_level

	local function sendToFriend(event)
		-- Find the coordinates of the screen center in the options frame
		local x, y = options:contentToLocal(cX, cY)

		-- Prevent touch propagation
		local tapProof = display.newRect(options, x, y, W, H)
		tapProof:setFillColor(0,0,0,0.3)
		tapProof:addEventListener("tap", function(event) return true end)
		tapProof:addEventListener("touch", function(event) return true end)

		-- Listener for when the user submits their choice
		local function onSubmit(switches)
			for email, switch in pairs(switches) do
				if switch.state then
					app_network.sendRecipe(email, name)
				end
			end
			tapProof:removeSelf()
		end

		local list = showFriendsList(onSubmit,true)

		options:insert(list)
		list.x, list.y = list:contentToLocal(list.x, list.y)
	end
	send_icon:addEventListener("tap", sendToFriend)

	ypp(3*spacing)

	-- Double And Half Buttons
	local function doubleIt(event)
		scene.glass_screen.alpha = 0
		composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = 2*scaling_factor}})
	end
	local double_params = {	color = app_colors.contrast_color,
							label = "Double Recipe",
							labelColor = app_colors.recipe.title_text,
							font = native.systemFontBold,
							fontSize = globalData.mediumFontSize,
							radius = 0.1*spacing,
							strokeWidth = 4,
							strokeColor = {0},
							displayGroup = options,
							tap_func = doubleIt}
	local double = tinker.newButton(0.5*width, y_level, 0.8*width, 1.3*spacing, double_params)

	ypp(2*spacing)

	local function halfIt(event)
		scene.glass_screen.alpha = 0
		composer.gotoScene("ViewRecipePage", {params = {name = name, scaling_factor = 0.5*scaling_factor}})
	end
	local half_params = double_params
	half_params.label = "Half Recipe"
	half_params.tap_func = halfIt
	local half = tinker.newButton(0.5*width, y_level, 0.8*width, 1.3*spacing, half_params)

	ypp()

	-- Delete Icon
	local delete_text = display.newText({	text = "Delete",
											x = edit.x,
											y = height - spacing,
											font = native.systemFontBold,
											fontSize = globalData.mediumFontSize})
	delete_text:setFillColor(unpack(app_colors.recipe.ing_text))
	delete_text.anchorX = 0
	options:insert(delete_text)

	local delete_image = "Image Assets/Trash-Graphic-Simple.png"
	if app_colors.scheme == "dark" then delete_image = "Image Assets/White-Trash-Graphic.png" end
	local delete = display.newImageRect(options, delete_image, star.width, star.height)
	delete.x = star.x
	delete.y = delete_text.y

	-- Function To Delete a Food From Memory
	function delete:tap(event)
		local function trash_listener(event)
			if event.index == 1 then
				scene.glass_screen:dispatchEvent({name = "tap"})
				globalData.menu[name] = nil
				globalData.favourites[name] = nil
				globalData.writeCustomMenu()
				globalData.deleteFoodImage(name)
				composer.gotoScene(globalData.activeScene)
			end
		end
		native.showAlert("What's On The Menu", "Are you sure you want to delete \"" .. name .. "\"?", {"Yes, I'm Sure", "Cancel"}, trash_listener )

		return true
	end
	delete:addEventListener("tap", delete)

	function options:toggle()
		if self.state == "hidden" then
			transition.to(self, {time = 200, x = W - width})
			transition.to(back, {time = 500, rotation = 90})
			self.state = "visible"
		else
			transition.to(self, {time = 200, x = W})
			transition.to(back, {time = 500, rotation = 270})
			self.state = "hidden"
		end

		return true
	end

	back:addEventListener("tap", function(e) scene.glass_screen:dispatchEvent({name = "tap"}) end)

	return options
end

return createOptions
