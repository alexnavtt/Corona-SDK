local app_network = require("lib.network.main")
local globalData = require("globalData")
local json = require("json")

local function logOut()
	local params = app_network.createHttpRequest("logout")

	local function networkListener(event)
		if event.isError then
			app_network.connectionError()
		else
			print(event.response)
			local response = json.decode(event.response)
			if not response then response = {} end

			if response.message then 
				app_network.log(response)
			end
			
		end

		app_network.config.auth_token = ""
		app_network.config.logged_in = false
		globalData.writeNetwork()

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

return logOut
