-- Solar2D Stuff
local widget = require("widget")
local composer = require("composer")

-- My Stuff
local palette = require("Palette")
local globalData = require("globalData")
local app_colors = require("AppColours")
local app_network = require("AppNetwork")

local scene = composer.newScene()
scene.lib = {}

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

local function friendPanel(name)
	local group = display.newGroup()
	group.x = cX

	local panel = display.newRoundedRect(group, 0, 0, 0.9*W, 0.07*H, 0.05*W)
	panel:setFillColor(unpack(app_colors.browse.panel_2))

	local friend_label = display.newText({text = name, x = -0.45*panel.width, y = 0, font = native.systemFontBold, fontSize = globalData.titleFontSize, parent = group})
	friend_label:setFillColor(unpack(app_colors.browse.recipe_title))
	friend_label.anchorX = 0

	local function removeListener(event)
		if event.index == 1 then
			app_network.deleteFriend(group.email)
			group:removeSelf()
			group = nil
		end
		return true
	end

	local delete_params = {label = "X", labelColor = {1}, color = palette.dark.red, displayGroup = group, fontSize = globalData.mediumFontSize,
		tap_func = function(event) 
			native.showAlert(globalData.app_name, "Are you sure you want to remove " .. name .. " from your friends list?", {"Yes", "Cancel"}, removeListener) 
		end}
	local delete_button = tinker.newDot(0.4*panel.width, 0, 0.4*panel.height, delete_params)

	return group
end

function scene:create( event )

	local sceneGroup = self.view
	local lib = self.lib

	lib.background = display.newRect(sceneGroup, cX, cY, W, H)
	lib.background:setFillColor(unpack(app_colors.settings.background))

	lib.background_text = display.newText({text = "Hi There", x = cX, y = cY, width = 0.8*W, height = 0.2*H, font = native.systemFontBold, fontSize = globalData.titleFontSize, parent = sceneGroup, align = "center"})
	if app_colors.scheme == "light" then 
		lib.background_text:setFillColor(unpack(palette.darken(app_colors.settings.background, 3)))
	else
		lib.background_text:setFillColor(unpack(palette.lighten(app_colors.settings.background, 3)))
	end

	lib.scroll_view = widget.newScrollView({x = cX, y = cY + 0.5*globalData.tab_bar.height, width = W, height = H - globalData.tab_bar.height, hideBackground = true, isHorizontalScrollDisabled = true})
	sceneGroup:insert(lib.scroll_view)
end


function scene:show( event )

	local lib = self.lib
	local phase = event.phase
	local sceneGroup = self.view

	if ( phase == "will" ) then
		local friends = app_network.getFriends();
		local t_handle
		local y_level = 0.1*lib.scroll_view.height
		t_handle = timer.performWithDelay(10, function(event) 
			if not friends.waiting then
				timer.cancel(t_handle)
				for key, value in pairs(friends) do
					if key ~= "waiting" then
						local panel = friendPanel(value.name)
						panel.email = value.email
						panel.y = y_level

						y_level = y_level + 0.1*H
						lib.scroll_view:insert(panel)
					end
				end
			end
		end, -1)

	elseif ( phase == "did" ) then

	end
end


-- hide()
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


-- destroy()
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