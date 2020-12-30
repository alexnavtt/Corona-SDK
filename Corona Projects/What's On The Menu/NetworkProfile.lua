local composer = require("composer")
local globalData = require("globalData")
local app_colors = require("AppColours")
local app_network = require("AppNetwork")
local app_transitions = require("AppTransitions")
 
local scene = composer.newScene()

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

function scene:create( event )
 
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, cX, cY, W, H)
	background:setFillColor(unpack(app_colors.settings.background))
	background:addEventListener("touch", app_transitions.swipeLeft)

	local y_level = 0.12*H
	local x_level = 0.08*W

	local title = display.newText({text = "User Profile", x = 0.05*W, y = y_level, fontSize = 1.5*globalData.titleFontSize, font = native.systemFontBold})
	title.anchorX = 0
	title:setFillColor(unpack(app_colors.settings.text))
	sceneGroup:insert(title)

	y_level = y_level + 0.1*H

	--------------
	-- USERNAME --
	--------------

	local usernameText = display.newText({text = "Change Username", x = x_level, y = y_level, fontSize = globalData.mediumFontSize, parent = sceneGroup})
	usernameText.anchorX = 0
	usernameText:setFillColor(unpack(app_colors.settings.text))

	self.username = display.newText({text = app_network.config.username, x = 0.9*W, y = y_level, fontSize = globalData.smallFontSize, parent = sceneGroup})
	self.username.anchorX = self.username.width
	self.username:setFillColor(unpack(app_colors.settings.text))

	local function inputUsername(event)
		local glass_screen = display.newRect(cX, cY, W, H)
		glass_screen.alpha = 0.5
		glass_screen:setFillColor(0)

		local NTF = native.newTextField(cX, cY, 0.9*W, 0.05*H)
		NTF.text = app_network.config.username

		local function inputListener(event)
			if event.phase == "ended" or event.phase == "submitted" then
				if NTF.text == "" then
					native.showAlert(globalData.app_name, "Username cannot be empty", {"OK"})
					return true
				end

				local text = NTF.text
				app_network.onComplete = function() self.username.text = text end
				app_network.changeUsername(NTF.text)
				self.username.text = app_network.config.username
				self.username.anchorX = self.username.width
				glass_screen:dispatchEvent({name = "tap"})
			end
		end
		NTF:addEventListener("userInput", inputListener)

		glass_screen:addEventListener("tap", function (event)
			native.setKeyboardFocus(nil)
			glass_screen:removeSelf()
			NTF:removeSelf()
		end)

		native.showAlert(globalData.app_name, "This will log you out of all other devices", {"OK"})
	end
	usernameText:addEventListener("tap", inputUsername)

	y_level = y_level + 0.1*H

	--------------
	-- PASSWORD --
	--------------

	local passwordText = display.newText({text = "Change Password", x = x_level, y = y_level, fontSize = globalData.mediumFontSize, parent = sceneGroup})
	passwordText.anchorX = 0
	passwordText:setFillColor(unpack(app_colors.settings.text))

	passwordText:addEventListener("tap", function(event) app_network.changePasswordPanel(); return true; end)

	y_level = y_level + 0.1*H
	--------------------
	-- CREATE PROFILE --
	--------------------

	local createProfile = display.newText({text = "Create New Profile", x = x_level, y = y_level, fontSize = globalData.mediumFontSize, parent = sceneGroup})
	createProfile.anchorX = 0
	createProfile:setFillColor(unpack(app_colors.settings.text))

	local function tapCreateProfile(event)
		app_network.onComplete = function()
			self.login_button:replaceLabel("Log Out")
		end
		app_network.createProfile()
	end
	createProfile:addEventListener("tap", tapCreateProfile)

	y_level = y_level + 0.1*H

	--------------
	--- LOG IN ---
 	--------------

 	local login_button
 	local function tapLogin(event)
 		if app_network.config.first_time then
 			app_network.createProfile()
 			app_network.onComplete = function()
				if app_network.config.logged_in then
					self.login_button:replaceLabel("Log Out")
				end
			end

 		elseif app_network.config.logged_in then
 			app_network.logOut()
 			self.login_button:replaceLabel("Log In")

 		else
	 		login_panel = app_network.createLoginPanel()
	 		app_network.onComplete = function()
				if app_network.logged_in then
					self.login_button:replaceLabel("Log Out")
				end
			end

	 	end
 		return true
 	end
 	local login_params = {label = "Log In", displayGroup = sceneGroup, tap_func = tapLogin, radius = 0.025*H, color = {0,0,0,0.5}, strokeWidth = 5, strokeColor = {0}}
 	
 	if app_network.config.first_time then 
 		login_params.label = "Create Profile" 
 	elseif app_network.config.logged_in then
 		login_params.label = "Log Out"
 	end

 	self.login_button = tinker.newButton(cX, 0.9*H, 0.5*W, 0.05*H, login_params)
 
end
 
 
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
 
	end
end
 
 
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
 
	elseif ( phase == "did" ) then
		composer.removeScene("NetworkProfile")
 
	end
end
 
 
function scene:destroy( event )
 
	local sceneGroup = self.view
 
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