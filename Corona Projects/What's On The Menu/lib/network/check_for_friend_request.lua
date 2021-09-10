local json = require("json")
local tinker = require("ext_libs.tinker.tinker")
local widget = require("widget")
local palette = require("Palette")
local globalData = require("globalData")
local app_network = require("lib.network.main")

local W  = display.contentWidth
local H  = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY 

local function showFriendRequests(request_table)
	local group = display.newGroup()

	local glass_screen = display.newRect(group, cX, cY, W, H)
	glass_screen:setFillColor(0,0,0,0.3)

	local function tapProof(event) return true end
	glass_screen:addEventListener("tap", tapProof)
	glass_screen:addEventListener("touch", tapProof)

	local panel = display.newRoundedRect(group, cX, cY, 0.8*W, 0.8*H, 0.1*W)
	panel:setFillColor(1)

	local title = display.newText({text = "Friend Requests", x = cX, y = cY-0.45*panel.height, parent = group, 
								  font = native.systemFondBold, fontSize = globalData.titleFontSize, align = "center"})
	title:setFillColor(0)

	local scroll_view = widget.newScrollView({x = cX, y = cY, width = panel.width, height = 0.8*panel.height, isHorizontalScrollDisabled = true})
	group:insert(scroll_view)

	local y_level = 0.05*scroll_view.height
	for _, request in pairs(request_table) do
		local text = display.newText({text = request.name, x = 0.05*scroll_view.width, y = y_level, fontSize = globalData.mediumFontSize})
		text:setFillColor(0)
		text.anchorX = 0
		scroll_view:insert(text)

		-- Set up the accept or reject buttons
		local accept_button, reject_button
		local function acceptFriendRequest(event)
			app_network.respondToFriendRequest(request.name, request.email, "confirm")
			local replacement_text = display.newText({text = "Accepted", x = accept_button.x, y = accept_button.y, width = 0.5*panel.width, fontSize = globalData.mediumFontSize})
			replacement_text:setFillColor(0)
			replacement_text.anchorX = 0
			scroll_view:insert(replacement_text)

			accept_button:removeSelf()
			reject_button:removeSelf()
		end

		local function rejectFriendRequest(event)
			app_network.respondToFriendRequest(request.name, request.email, "reject")
			local replacement_text = display.newText({text = "Rejected", x = accept_button.x, y = accept_button.y, width = 0.5*panel.width, fontSize = globalData.mediumFontSize})
			replacement_text:setFillColor(0)
			replacement_text.anchorX = 0
			scroll_view:insert(replacement_text)

			accept_button:removeSelf()
			reject_button:removeSelf()
		end


		local accept_params = {radius = 0.05*panel.width, tap_func = acceptFriendRequest, color = palette.green, label = "Accept"}
		accept_button = tinker.newButton(0.5*scroll_view.width, y_level, 0.2*scroll_view.width, 0.05*scroll_view.height, accept_params)
		accept_button.anchorX = 0
		scroll_view:insert(accept_button)

		local reject_params = {radius = 0.05*panel.width, tap_func = rejectFriendRequest, color = palette.dark.red, label = "Reject"}
		reject_button = tinker.newButton(0.75*scroll_view.width, y_level, 0.2*scroll_view.width, 0.05*scroll_view.height, reject_params)
		reject_button.anchorX = 0
		scroll_view:insert(reject_button)

		y_level = y_level + 0.1*scroll_view.height
	end

	local done_params = {displayGroup = group, label = "\n\n\nDone", radius = 0.1*W, color = palette.dark.blue, labelColor = {1}, tap_func = function(event) group:removeSelf() end, fontSize = globalData.titleFontSize}
	local done_button = tinker.newButton(cX, cY + 0.4*panel.height, panel.width, 0.2*panel.height, done_params)

	scroll_view:toFront()
end

local function checkForFriendRequests()
	local params = app_network.createHttpRequest("check requests")

	local function networkListener(event)
		if event.isError then
			app_network.log("Network Error - Could not connect")
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			if response.success and response.requests["1"] then
				showFriendRequests(response.requests)
			end

			app_network.log(response)
		end
	end
	network.request(app_network.friend_url, "POST", networkListener, params)
end

return checkForFriendRequests
