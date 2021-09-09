local globalData = require("globalData")
local app_network = require("lib.network.main")
local json = require("json")

local function deleteFriend(email)
	local body = {email = app_network.config.email, username = app_network.config.username, token = app_network.config.auth_token, 
				  action = "delete friend", device_id = globalData.settings.device_id, recipient = email}
	body = json.encode(body)

	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["Accept"] = "application/json"

	local params = {headers = headers, body = body}

	local function networkListener(event)
		if event.isError then
			app_network.log("Connection Error: Did not delete " .. email)
		else
			local response = json.decode(event.response)
			if not response then response = {} end

			app_network.log(response)
		end
	end
	network.request(app_network.friend_url, "POST", networkListener, params)

	return friends
end

return deleteFriend
