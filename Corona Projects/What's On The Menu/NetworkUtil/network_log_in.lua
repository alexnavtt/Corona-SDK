local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")

local function logIn(email, password)
	app_network.config.email = email
	local params = app_network.createHttpRequest("login", password)

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			if response.success then
				app_network.config.auth_token = response.token
				app_network.config.logged_in = true
				app_network.config.first_time = false
				globalData.writeNetwork()
				app_network.syncData()
			else
				native.showAlert("Login Error", tostring(response.message), {"OK"})
			end

			app_network.log(response)
		end

		if app_network.onComplete then 
			app_network.onComplete() 
			app_network.onComplete = nil
		end

		native.setActivityIndicator(false)
		return true
	end
	native.setActivityIndicator(true)
	network.request(app_network.url, "POST", networkListener, params)

	return true
end

return logIn
