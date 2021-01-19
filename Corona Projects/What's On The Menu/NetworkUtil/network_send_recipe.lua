local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")

local function sendRecipe(friend_email, food_name)
	local body = {email = app_network.config.email, username = app_network.config.username, token = app_network.config.auth_token, 
				  action = "send recipe", device_id = globalData.settings.device_id, recipient = friend_email, data = json.encode(globalData.menu[food_name]), title = food_name}
	body = json.encode(body)

	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["Accept"]       = "application/json"

	local params = {headers = headers, body = body}

	local function networkListener(event)
		if event.isError then
			app_network.log("Network Error")
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			native.showAlert(globalData.app_name, tostring(response.message), {"OK"})
		end
	end
	network.request(app_network.friend_url, "POST", networkListener, params)
end

return sendRecipe
