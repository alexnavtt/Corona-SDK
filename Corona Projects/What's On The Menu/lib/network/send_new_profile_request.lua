local app_network = require("lib.network.main")
local globalData = require("globalData")
local json = require("json")

local function sendNewProfileRequest(email, username, password)
	app_network.config.username = username
	app_network.config.email = email
	local params = app_network.createHttpRequest("create profile", password)

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			local response = json.decode(event.response)
			if not response then response = {} end

			app_network.log(response)

			if response.success then
				globalData.settings.device_id = response.device_id
				globalData.writeSettings()

				app_network.config.auth_token = response.token
				app_network.config.first_time = false
				app_network.config.logged_in = true
				globalData.writeNetwork()

				app_network.uploadData()
			else
				native.showAlert("Network Error", tostring(response.message), {"OK"})
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
