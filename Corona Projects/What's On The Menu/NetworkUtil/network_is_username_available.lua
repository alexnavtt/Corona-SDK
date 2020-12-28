local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")
local util = require("GeneralUtility")
local json = require("json")

local function isUsernameAvailable(name)
	local body = json.encode({username = name})
	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["Accept"] = "application/json"

	local params = {headers = headers, body = body}

	app_network.data_received = false
	app_network.username_free = false
	local function networkListener(event)
		if event.isError then
			native.showAlert(globalData.app_name, "Cannot connect to server", {"OK"})
			native.setActivityIndicator(false)
		else
			print(event.response)
			if event.response == "1" then
				app_network.username_free = true
			end

			app_network.data_received = true
			native.setActivityIndicator(false)
		end
	end
	native.setActivityIndicator(true)
	network.request(app_network.username_url, "GET", networkListener, params)
end

return isUsernameAvailable
