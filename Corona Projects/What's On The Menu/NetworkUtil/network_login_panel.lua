local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local tinker = require("Tinker")

local function createLoginPanel()
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

	local form = display.newRoundedRect(group, cX, cY, 3*W/4, H/2, W/10)
	form:setStrokeColor(0)
	form.strokeWidth = 5

	local title = display.newText({text = "Log In", x = cX, y = form.y - 0.4*form.height, fontSize = globalData.titleFontSize, align = "center", parent = group})
	title:setFillColor(0)

	local email_field = native.newTextField(cX, cY - 0.3*form.height, 0.9*form.width, H/25)
	email_field.placeholder = "Email"
	email_field.text = app_network.config.email

	local password_field = native.newTextField(cX, email_field.y + 2*email_field.height, email_field.width, email_field.height)
	password_field.placeholder = "Password"
	password_field.isSecure = true

	local function destroyGroup()
		email_field:removeSelf()
		password_field:removeSelf()
		if group.onComplete then group.onComplete() end
		group:removeSelf()
		return true
	end

	local function tapBack(event)
		app_network.onComplete = nil
		destroyGroup()
	end
	local back_button_params = {displayGroup = group, tap_func = tapBack, label = "Cancel", strokeWidth = 3, strokeColor = {0}, radius = 0.05*form.height}
	local back_button = tinker.newButton(cX - 0.05*form.width, cY + 0.4*form.height, 0.3*form.width, 0.1*form.height, back_button_params)
	back_button.anchorX = back_button.width

	local function submit(event)
		if email_field.text == "" then
			native.showAlert(globalData.app_name, "Email cannot be empty", {"OK"})
			return true
		end

		app_network.logIn(email_field.text, password_field.text)
		destroyGroup()
	end
	local submit_button_params = {displayGroup = group, tap_func = submit, label = "Submit", strokeWidth = 3, strokeColor = {0}, radius = back_button_params.radius}
	local submit_button = tinker.newButton(cX + 0.05*form.width, back_button.y, back_button.width, back_button.height, submit_button_params)
	submit_button.anchorX = 0

	local logo = display.newImageRect(group, "Image Assets/Recipe-App-Icon-Transparent.png", 0.35*form.height, 0.35*form.height)
	logo.x = form.x
	logo.y = form.y + 0.125*form.height

	return group
end

return createLoginPanel
