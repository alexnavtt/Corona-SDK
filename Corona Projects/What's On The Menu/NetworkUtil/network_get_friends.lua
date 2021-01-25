local app_network = require("NetworkUtil.network_main")
local json = require("json")

local function getFriends()
	local params = app_network.createHttpRequest("get friends")

	local function networkListener(event)
		if event.isError then
			return ("Connection Error")
		else
			local response = json.decode(event.response)
			if not response then response = {} end
			if not response.friends then response.friends = {} end

			app_network.log(response)

			for index, value in pairs(response.friends) do
				app_network.friends[index] = value
			end
			app_network.friends_received = true;
		end
	end
	network.request(app_network.friend_url, "POST", networkListener, params)

	return friends
end

return getFriends
