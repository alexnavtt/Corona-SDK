local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local tinker = require("Tinker")
local crypto = require("crypto")
local palette = require("Palette")

local function createProfile()
	local cX = display.contentCenterX
	local cY = display.contentCenterY
	local W = display.contentWidth
	local H = display.contentHeight

	local group = display.newGroup()

	-- Create a background to prevent undesired touches/taps
	local glass_screen = display.newRect(group, cX, cY, W, H)
	glass_screen:setFillColor(0)
	glass_screen.alpha = 0.3

	local tapProof = function(event) return true end
	local touchProof = function(event) return true end
	glass_screen:addEventListener("tap", tapProof)
	glass_screen:addEventListener("touch", tapProof)

	local form = display.newRoundedRect(group, cX, cY, 3*W/4, H/2, W/10)
	form:setStrokeColor(0)
	form.strokeWidth = 5

	local title = display.newText({text = "Create Profile", x = cX, y = form.y - 0.4*form.height, fontSize = globalData.titleFontSize, align = "center", parent = group})
	title:setFillColor(0)

	local email_field = native.newTextField(cX, cY - 0.3*form.height, 0.9*form.width, H/25)
	email_field.placeholder = "Email"

	local username_field = native.newTextField(cX, email_field.y + 2*email_field.height, email_field.width, email_field.height)
	username_field.placeholder = "Nickname: What your frinds will see"

	local password_field = native.newTextField(cX, username_field.y + 2*username_field.height, username_field.width, username_field.height)
	password_field.placeholder = "Password"
	password_field.isSecure = true

	local confirm_password_field = native.newTextField(cX, password_field.y + 2*password_field.height, password_field.width, password_field.height)
	confirm_password_field.placeholder = "Confirm Password"
	confirm_password_field.isSecure = true

	local query_text = display.newText({text = "Already have an account?  ", x = form.x - 0.45*form.width, y = confirm_password_field.y + confirm_password_field.height, fontSize = globalData.smallFontSize})
	query_text.anchorX = 0
	query_text:setFillColor(0)
	group:insert(query_text)

	local login_text = display.newText({text = "Log in", x = query_text.x + query_text.width, y = query_text.y, fontSize = globalData.mediumFontSize, parent = group})
	login_text.anchorX = 0
	login_text:setFillColor(unpack(palette.dark.blue))

	local function destroyGroup()
		email_field:removeSelf()
		username_field:removeSelf()
		password_field:removeSelf()
		confirm_password_field:removeSelf()
		group:removeSelf()
		return true
	end

	local function tapBack(event)
		app_network.onComplete = nil
		destroyGroup()
	end

	login_text:addEventListener("tap", function(event) app_network.createLoginPanel(); destroyGroup(); return true; end)


	local back_button_params = {displayGroup = group, tap_func = tapBack, label = "Cancel", strokeWidth = 3, strokeColor = {0}, radius = 0.05*form.height}
	local back_button = tinker.newButton(cX - 0.05*form.width, cY + 0.4*form.height, 0.3*form.width, 0.1*form.height, back_button_params)
	back_button.anchorX = back_button.width

	local function submit(event)
		-- Make sure that the email at least resembles a valid email
		local has_at, has_point
		local email = email_field.text
		for i = 1,#email do
			if email:sub(i,i) == "@" then
				has_at = true
			elseif has_at and email:sub(i,i) == "." then
				has_point = true
			end
		end
		if not has_at or not has_point then
			native.showAlert(globalData.app_name, "Please enter a valid E-mail", {"OK"})
			return true
		end

		-- Make sure the passwords match
		local password = password_field.text
		if password_field.text ~= confirm_password_field.text then
			native.showAlert(globalData.app_name, "Passwords do not match", {"OK"})
			return true
		end	

		-- Make sure there is a username
		local username = username_field.text
		if username == "" then
			native.showAlert(globalData.app_name, "Username cannot be empty", {"OK"})
			return true
		end

		app_network.sendNewProfileRequest(email, username, password)
		destroyGroup()
		
	end
	local submit_button_params = {displayGroup = group, tap_func = submit, label = "Submit", strokeWidth = 3, strokeColor = {0}, radius = back_button_params.radius}
	local submit_button = tinker.newButton(cX + 0.05*form.width, back_button.y, back_button.width, back_button.height, submit_button_params)
	submit_button.anchorX = 0
end

return createProfile
