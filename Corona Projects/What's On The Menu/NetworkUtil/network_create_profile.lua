local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local tinker = require("Tinker")
local crypto = require("crypto")

local function createProfile()
	local cX = display.contentCenterX
	local cY = display.contentCenterY
	local W = display.contentWidth
	local H = display.contentHeight

	local group = display.newGroup()

	-- Create a background to prevent undesired 
	local glass_screen = display.newRect(group, cX, cY, W, H)
	glass_screen:setFillColor(0)
	glass_screen.alpha = 0.3

	local tapProof = function(event) return true end
	local touchProof = function(event) return true end
	glass_screen:addEventListener("tap", tapProof)
	glass_screen:addEventListener("touch", tapProof)

	local form = display.newRoundedRect(group, cX, cY, W/2, H/2, W/10)
	form:setStrokeColor(0)
	form.strokeWidth = 5

	local title = display.newText({text = "Create Profile", x = cX, y = form.y - 0.4*form.height, fontSize = globalData.titleFontSize, align = "center", parent = group})
	title:setFillColor(0)

	local username_field = native.newTextField(cX, cY - 0.3*form.height, 3*W/8, H/25)
	username_field.placeholder = "Username"

	local password_field = native.newTextField(cX, username_field.y + 2*username_field.height, username_field.width, username_field.height)
	password_field.placeholder = "Password"
	password_field.isSecure = true

	local confirm_password_field = native.newTextField(cX, password_field.y + 2*password_field.height, password_field.width, password_field.height)
	confirm_password_field.placeholder = "Confirm Password"
	confirm_password_field.isSecure = true

	local function destroyGroup(event)
		username_field:removeSelf()
		password_field:removeSelf()
		confirm_password_field:removeSelf()
		group:removeSelf()
		return true
	end
	local back_button_params = {displayGroup = group, tap_func = destroyGroup, label = "Cancel", strokeWidth = 3, strokeColor = {0}, radius = 0.05*form.height}
	local back_button = tinker.newButton(cX - 0.05*form.width, cY + 0.4*form.height, 0.3*form.width, 0.1*form.height, back_button_params)
	back_button.anchorX = back_button.width

	local function submit(event)
		if password_field.text ~= confirm_password_field.text then
			native.showAlert(globalData.app_name, "Passwords do not match", {"OK"})
			return true
		end	

		if username_field.text == "" then
			native.showAlert(globalData.app_name, "Username cannot be empty", {"OK"})
			return true
		end

		app_network.isUsernameAvailable(username_field.text)

		local t_handle
		t_handle = timer.performWithDelay(10, function(event)
			if app_network.data_received then 
				timer.cancel(t_handle)
				if not app_network.username_free then
					native.showAlert(globalData.app_name, "That username is already taken", {"OK"})
				else
					-- Store details and create profile
					app_network.config.username = username_field.text
					app_network.config.encrypted_password = crypto.hmac( crypto.md5, password_field.text, "" )
					app_network.new_user = true
					-- globalData.writeNetworkConfig()
					destroyGroup()
					app_network.uploadData()
				end
			end
			return true 
		end,	
		20000)
	end
	local submit_button_params = {displayGroup = group, tap_func = submit, label = "Submit", strokeWidth = 3, strokeColor = {0}, radius = back_button_params.radius}
	local submit_button = tinker.newButton(cX + 0.05*form.width, back_button.y, back_button.width, back_button.height, submit_button_params)
	submit_button.anchorX = 0
end

return createProfile
