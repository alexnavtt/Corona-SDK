local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")
local util = require("GeneralUtility")

local function changePassword(old_password, new_password)
	local params = app_network.createHttpRequest("change password", old_password)
	local body = json.decode(params.body)
	body.new_password = new_password
	params.body = json.encode(body)

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			local response = json.decode(event.response)
			if not response then return true end

			if response and response.message then
				native.showAlert(globalData.app_name, response.message, {"OK"})
			end

			if response.success then
				app_network.config.auth_token = response.token
				app_network.config.logged_in = true
				globalData.writeNetwork()
			end
		end

		return true
	end
	network.request(app_network.url, "POST", networkListener, params)

	return true
end

return changePassword
