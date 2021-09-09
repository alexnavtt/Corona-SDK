local app_network = require("lib.network.main")
local globalData = require("globalData")

local function changePasswordPanel()
	local W = display.contentWidth
	local H = display.contentHeight
	local cX = display.contentCenterX
	local cY = display.contentCenterY

	local group = display.newGroup()

	local glass_screen = display.newRect(group, cX, cY, W, H)
	glass_screen:setFillColor(0)
	glass_screen.alpha = 0.5

	local tapProof = function(event) return true end
	local touchProof = function(event) return true end
	glass_screen:addEventListener("tap", tapProof)
	glass_screen:addEventListener("touch", tapProof)

	local form = display.newRoundedRect(group, cX, cY, 3*W/4, H/2, W/10)
	form:setStrokeColor(0)
	form.strokeWidth = 5

	local title = display.newText({text = "Change Password", x = cX, y = form.y - 0.4*form.height, fontSize = globalData.titleFontSize, align = "center", parent = group})
	title:setFillColor(0)

	local password_field = native.newTextField(cX, cY - 0.3*form.height, 0.9*form.width, H/25)
	password_field.placeholder = "Current Password"

	local new_password_field = native.newTextField(cX, password_field.y + 2*password_field.height, password_field.width, password_field.height)
	new_password_field.placeholder = "New Password"
	new_password_field.isSecure = true

	local confirm_new_password_field = native.newTextField(cX, new_password_field.y + 2*new_password_field.height, new_password_field.width, new_password_field.height)
	confirm_new_password_field.placeholder = "Confirm New Password"
	confirm_new_password_field.isSecure = true

	local function destroyGroup(event)
		password_field:removeSelf()
		new_password_field:removeSelf()
		confirm_new_password_field:removeSelf()
		group:removeSelf()
		return true
	end

	local back_button_params = {displayGroup = group, tap_func = destroyGroup, label = "Cancel", strokeWidth = 3, strokeColor = {0}, radius = 0.05*form.height}
	local back_button = tinker.newButton(cX - 0.05*form.width, cY + 0.4*form.height, 0.3*form.width, 0.1*form.height, back_button_params)
	back_button.anchorX = back_button.width

	local function submit(event)
		if new_password_field.text ~= confirm_new_password_field.text then
			native.showAlert(globalData.app_name, "Passwords do not match", {"OK"})
			return true
		end

		app_network.changePassword(password_field.text, new_password_field.text)
		destroyGroup()

		return true
	end
	local submit_button_params = {displayGroup = group, tap_func = submit, label = "Submit", strokeWidth = 3, strokeColor = {0}, radius = back_button_params.radius}
	local submit_button = tinker.newButton(cX + 0.05*form.width, back_button.y, back_button.width, back_button.height, submit_button_params)
	submit_button.anchorX = 0

end

return changePasswordPanel
