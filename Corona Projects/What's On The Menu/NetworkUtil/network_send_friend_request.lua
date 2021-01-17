local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")

local function sendFriendRequest(friend_email)
	local body = {email = app_network.config.email, username = app_network.config.username, token = app_network.config.auth_token, 
				  action = "friend request", device_id = globalData.settings.device_id, recipient = friend_email}
	body = json.encode(body)

	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["Accept"] = "application/json"

	local params = {headers = headers, body = body}

	local function networkListener(event)
		if event.isError then
			app_network.log("Network Error")
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			native.showAlert(globalData.app_name, tostring(response.message), {"OK"})
			if response.success then
				table.insert(app_network.friends, {name = response.name, email = friend_email, confirmed = false})
			end
		end
	end
	network.request(app_network.friend_url, "POST", networkListener, params)
end

return sendFriendRequest
