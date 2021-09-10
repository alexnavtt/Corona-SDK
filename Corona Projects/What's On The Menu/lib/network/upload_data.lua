local globalData = require("globalData")
local app_network = require("lib.network.main")
local json = require("json")
local time_util = require("lib.util.time")

local function uploadData()
	-- Ensure that all recipes going up have a timestamp
	for key, value in pairs(globalData.menu) do
		if not value.timestamp then
			value.timestamp = time_util.time()
		end
	end
	globalData.writeCustomMenu()

	-- Prevent empty username
	if app_network.config.username == "" then
		native.showAlert(globalData.app_name, "Username cannot be empty")
		return false
	end

	-- Get HTTP request message
	local params = app_network.createHttpRequest("upload")
	local body = json.decode(params.body)
	local timestamp = body.timestamp

	-- HTTP POST event callback
	local function POSTListener(event)
		if event.isError then
			app_network.connectionError()
		else
			local response = json.decode(event.response)
			if not response then response = {} end

			app_network.log(response)

			if response.success then
				app_network.config.last_upload_time = timestamp
				globalData.writeNetwork()
			else
				native.showAlert("Network Error", tostring(response.message), {"OK"})
			end
		end
	end

	network.request(app_network.url, "POST", POSTListener, params)
end

return uploadData
