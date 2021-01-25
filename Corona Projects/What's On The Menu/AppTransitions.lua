local globalData = require("globalData")
local composer   = require("composer")
local transition = {}

-- Transition effect duration
local transition_time = 300

-- The mapping of imaginary "locations" for each page
local order = {}
order["ViewLandscapeRecipe"] = {1, 1}
order["ViewRecipePage"]      = {1, 2}
order["BrowsePage"]          = {2, 2}
order["FavouritesPage"]      = {3, 2}
order["NewRecipePage"]       = {4, 2}
order["FriendPage"]          = {5, 2}
order["Settings"]            = {6, 2}
order["NetworkProfile"]      = {7, 2}
order["IngredientsPage"]     = {4, 3}
order["InsertStepsPage"]     = {5, 3}

local importantPages = {}
importantPages["BrowsePage"]     = true
importantPages["FavouritesPage"] = true
importantPages["NewRecipePage"]  = true
importantPages["Settings"]       = true

-- Handles swipe gestures
transition.touch_time = 0


-- Move to an aribrary scene
function transition.moveTo(scene, recipe_name)
	-- Get the name of the current page
	local current = composer.getSceneName("current")

	-- No transition effect if moving to the current page
	if scene == current then
		return true
	end

	-- Get the location of the current page
	local x = order[current][1]
	local y = order[current][2]

	-- Get the location of the new page
	local new_x = order[scene][1]
	local new_y = order[scene][2]

	-- Check to see which direction we're going
	local direction
	if (new_y > y) then
		direction = "Up"
	elseif (new_y < y) then
		direction = "Down"
	elseif (new_x < x) then
		direction = "Right"
	elseif (new_x > x) then
		direction = "Left"
	end

	-- Set the active page
	if importantPages[scene] then
		globalData.activeScene = scene
	end

	-- Move to the new scene
	composer.gotoScene(scene, {effect = "slide" .. direction, time = globalData.transition_time, params = {name = recipe_name}})
	globalData.tab_bar:update()
end


-- Move to the scene in an arbitrary direction
function transition.move(direction)
	-- Get the name of the current page
	local current = composer.getSceneName("current")

	-- Determine the "location" of this page in the map of pages
	local x = order[current][1]
	local y = order[current][2]

	-- Determine the "location" of the page to move to
	if (direction == "right") then
		x = math.min(x+1, 7)
	elseif (direction == "left") then
		x = math.max(x-1, 1)
	elseif (direction == "up") then
		y = math.max(y-1, 1)
	elseif (direction == "down") then
		y = math.min(y+1, 3)
	end

	-- Move to this new location
	for key, value in pairs(order) do
		if value[1] == x and value[2] == y then
			transition.moveTo(key)
		end
	end

end

function transition.swipeRight(event)
	-- Record when the touch started
	if event.phase == "began" then
		transition.touch_time = event.time

	-- Test to see if the swipe went far enough in a small enough time
	elseif event.phase == "moved" then
		local moveRight
		local swipeDist = math.abs(event.xDelta)
		local elapsed_time = event.time - transition.touch_time  -- milliseconds

		if event.xDelta < 0 then
			moveRight = true
		end

		if swipeDist > 0.2*display.contentWidth and elapsed_time < 500 and moveRight then
			transition.touch_time = 0 -- prevent multiple occurences
			transition.move("right")
			return true
		end

	end
end

function transition.swipeLeft(event)
	-- Record when the touch started
	if event.phase == "began" then
		transition.touch_time = event.time

	-- Test to see if the swipe went far enough in a small enough time
	elseif event.phase == "moved" then
		local moveLeft
		local swipeDist = math.abs(event.xDelta)
		local elapsed_time = event.time - transition.touch_time  -- milliseconds

		if event.xDelta > 0 then
			moveLeft = true
		end

		if swipeDist > 0.2*display.contentWidth and elapsed_time < 500 and moveLeft then
			transition.touch_time = 0 -- prevent multiple occurences
			transition.move("left")
			return true
		end

	end
end

return transition
