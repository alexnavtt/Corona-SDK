local app_network = require("NetworkUtil.network_main")
local json = require("json")

local function getFriends()
	local params = app_network.createHttpRequest("get friends")
	local friends = {waiting = true}

	local function networkListener(event)
		if event.isError then
			return ("Connection Error")
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			app_network.log(response)

			for index, value in pairs(response.friends) do
				friends[index] = value
			end
			friends.waiting = false;
		end
	end
	network.request(app_network.friend_url, "POST", networkListener, params)

	return friends
end

return getFriends
