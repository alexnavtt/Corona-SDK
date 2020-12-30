local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")

local function logIn(username, password)
	app_network.config.username = username
	local params = app_network.createHttpRequest("login", password)

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			if response.message then 
				print(string.format("NETWORK: '%s' => %s", response.type, response.message))
				-- native.showAlert(globalData.app_name, response.message, {"OK"})
			end

			if response.success then
				app_network.config.auth_token = response.token
				app_network.config.logged_in = true
				app_network.config.first_time = false
				globalData.writeNetwork()
				app_network.syncData()
				print("HI")
			end
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
