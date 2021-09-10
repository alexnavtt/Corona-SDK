-- Solar2D Stuff
local widget = require("widget")
local composer = require("composer")

-- My Stuff
local palette = require("Palette")
local globalData = require("globalData")
local app_colors = require("AppColours")
local app_network = require("lib.network.library")
local app_transitions = require("AppTransitions")
local showFriendList = require("pages.FriendPage.show_friends_list")

local scene = composer.newScene()
scene.lib = {}

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

-- Create a bar with the name of a friend on it
local function friendPanel(name, email)
	local group = display.newGroup()
	group.x = cX
	group.name = name;
	group.email = email;

	-- Create the bar itself
	local panel = display.newRoundedRect(group, 0, 0, 0.9*W, 0.07*H, 0.05*W)
	panel:setFillColor(unpack(app_colors.browse.panel_2))

	-- The text that shows the friend's name
	local friend_label = display.newText({text = name, x = -0.45*panel.width, y = 0, font = native.systemFontBold, fontSize = globalData.titleFontSize, parent = group})
	friend_label:setFillColor(unpack(app_colors.browse.recipe_title))
	friend_label.anchorX = 0

	-- Make it so that tapping a panel will fetch the shared recipes with that user
	friend_label:addEventListener("tap", function(event) app_network.receiveRecipeNames(email) end)

	-- Listener for deleting a friend
	local function removeListener(event)
		if event.index == 1 then
			app_network.deleteFriend(group.email)
			group:removeSelf()
			group = nil
		end
		return true
	end

	-- Button for deleting a friend
	local delete_params = {label = " X ", labelColor = {1}, color = palette.dark.red, displayGroup = group,
		tap_func = function(event) 
			native.showAlert(globalData.app_name, "Are you sure you want to remove " .. name .. " from your friends list?", {"Yes", "Cancel"}, removeListener) 
		end}
	local delete_button = tinker.newDot(0.4*panel.width, 0, 0.2*panel.height, delete_params)

	return group
end

function scene:create( event )

	local sceneGroup = self.view
	local lib = self.lib

	-- Background
	lib.background = display.newRect(sceneGroup, cX, cY, W, H)
	lib.background:setFillColor(unpack(app_colors.settings.background))

	-- Status text for if connection cannot be made
	lib.background_text = display.newText({text = "Unable to sync with server", x = cX, y = cY, width = 0.8*W, height = 0.2*H, font = native.systemFontBold, fontSize = globalData.titleFontSize, parent = sceneGroup, align = "center"})
	if app_colors.scheme == "light" then 
		lib.background_text:setFillColor(unpack(palette.darken(app_colors.settings.background, 3)))
	else
		lib.background_text:setFillColor(unpack(palette.lighten(app_colors.settings.background, 3)))
	end

	lib.scroll_view = widget.newScrollView({x = cX, y = cY + 0.5*globalData.tab_bar.height, width = W, height = H - globalData.tab_bar.height, 
											hideBackground = true, horizontalScrollDisabled = true})
	lib.scroll_view._view._background:addEventListener("touch", app_transitions.swipeLeft)
	lib.scroll_view._view._background:addEventListener("touch", app_transitions.swipeRight)
	lib.scroll_view._view:addEventListener("touch", app_transitions.swipeRight)
	lib.scroll_view._view:addEventListener("touch", app_transitions.swipeLeft)
	sceneGroup:insert(lib.scroll_view)
end


function scene:show( event )

	local lib = self.lib
	local phase = event.phase
	local sceneGroup = self.view

	if ( phase == "will" ) then
		local y_level = 0.1*lib.scroll_view.height

		if app_network.friends_received then
			-- Remove failed connection text
			lib.background_text.text = ""

			local function printSelected(switches)
				for email, switch in pairs(switches) do
					if switch.state then
						print(email)
					end
				end
			end

			lib.list = showFriendList(nil, false)
			sceneGroup:insert(lib.list)
		end

	elseif ( phase == "did" ) then

	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	local lib = self.lib

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		for i = 1, lib.scroll_view._collectorGroup.numChildren do
			lib.scroll_view._collectorGroup[1]:removeSelf()
		end
	end
end


function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene