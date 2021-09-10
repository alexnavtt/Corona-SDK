local app_network = require("lib.network.main")
local globalData = require("globalData")
local json = require("json")

local function changeUsername(new_username)
	local params = app_network.createHttpRequest("change username")
	local body = json.decode(params.body)
	body.new_username = new_username
	params.body = json.encode(body)

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			local response = json.decode(event.response)
			if not response then response = {} end
			app_network.log(response)

			if response.success then
				app_network.config.username = new_username
				globalData.writeNetwork()
			end
		end

		return true
	end
	network.request(app_network.url, "POST", networkListener, params)

	return true
end

return changeUsername
