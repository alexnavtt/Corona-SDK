local json = require("json")
local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")

local function createHttpRequest(direction, new_user)
		-- Set up HTTP package
		local body = {username = app_network.config.username, password = app_network.config.encrypted_password}

		if direction == "upload" then
			body.data = json.encode(globalData.menu)
			body.friends = json.encode(app_network.config.friends)
			body.new_user = app_network.new_user
		end

		if not body.new_user then body.new_user = false end
		body = json.encode(body)

		local headers = {}
		headers["Content-Type"] = "application/json"
		headers["Accept"] = "application/json"

		local params = {headers = headers, body = body}
		return params
end

return createHttpRequest
