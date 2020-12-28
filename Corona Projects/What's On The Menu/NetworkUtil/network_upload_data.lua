local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")

local function uploadData()
	if app_network.config.username == "" then
		native.showAlert(globalData.app_name, "Username cannot be empty")
		return false
	end

	local params = app_network.createHttpRequest("upload")

	-- HTTP POST event callback
	local function POSTListener(event)
		if event.isError then
			native.showAlert(globalData.app_name, "Could not connect to the server, please check your network connection", {"OK"})
		else
			native.showAlert(globalData.app_name, event.response, {"OK"})
			if event.response == "New user profile successfully created!" then
				app_network.new_user = false
				app_network.config.first_time = false
				app_network.config.logged_in = true
			end
		end
	end

	network.request(app_network.url, "POST", POSTListener, params)
end

return uploadData
