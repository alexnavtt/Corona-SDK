local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")
local util = require("GeneralUtility")

local function sendNewProfileRequest(username, password)
	app_network.config.username = username
	local params = app_network.createHttpRequest("create profile", password)

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			if response and response.message then
				print("Response message for '" .. response.type .. "': " .. response.message)
				-- native.showAlert(globalData.app_name, response.message, {"OK"})
			end

			if response.success then
				app_network.config.auth_token = response.token
				app_network.config.first_time = false
				app_network.config.logged_in = true
				globalData.writeNetwork()

				app_network.uploadData()
			end

			if app_network.onComplete then
				app_network.onComplete()
				app_network.onComplete = nil
			end
		end

		return true
	end
	network.request(app_network.url, "POST", networkListener, params)

	return true
end

return sendNewProfileRequest
