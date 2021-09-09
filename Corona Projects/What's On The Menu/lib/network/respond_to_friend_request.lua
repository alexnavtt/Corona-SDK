local app_network = require("lib.network.main")
local globalData = require("globalData")
local json = require("json")

local function respondToFriendRequest(name, email, answer)
	-- Set up HTTP package
	local body = {email = app_network.config.email, token = app_network.config.auth_token, device_id = globalData.settings.device_id,
				 answer = answer, action = "respond", requestor = email}
	body = json.encode(body)

	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["Accept"]       = "application/json"

	local params = {headers = headers, body = body}

	local function networkListener(event)
		if event.isError then
			app_network.log("Network Error. Could not respond to friend request")
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			app_network.log(response)

			if response.success and answer == "confirm" then
				native.showAlert(globalData.app_name, "You and " .. name .. " are now friends!", {"OK"})
			end
		end

		native.setActivityIndicator(false)
	end
	native.setActivityIndicator(true)
	network.request(app_network.friend_url, "POST", networkListener, params)
end

return respondToFriendRequest