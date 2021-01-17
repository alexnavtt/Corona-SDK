local json = require("json")
local util = require("GeneralUtility")
local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")

local function createHttpRequest(action, password)
		-- Set up HTTP package
		local body = {email = app_network.config.email, username = app_network.config.username, password = password, token = app_network.config.auth_token, 
					  action = action, timestamp = util.time(), last_timestamp = app_network.config.last_upload_time, device_id = globalData.settings.device_id}

		if action == "upload" then
			body.data = json.encode(globalData.menu)
		end

		body = json.encode(body)

		local headers = {}
		headers["Content-Type"] = "application/json"
		headers["Accept"] = "application/json"

		local params = {headers = headers, body = body}
		return params
end

return createHttpRequest
