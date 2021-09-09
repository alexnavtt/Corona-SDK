local json = require("json")
local globalData = require("globalData")
local app_network = require("lib.network.main")
local util = require("GeneralUtility")

local function syncData()
	if app_network.config.username == "" then
		native.showAlert(globalData.app_name, "Username cannot be empty")
		return false
	end
	
	local params = app_network.createHttpRequest("download")

	-- Data retrieval listener
	local function networkListener( event )
        if event.isError then
            native.showAlert(globalData.app_name, "Could not connect to the server, please check your network connection", {"OK"})
        else
            local response = json.decode(event.response)
            if not response then response = {} end

            app_network.log(response)

            if response.success then
                if response.data and response.data.Menu then
                    -- Promt the user to select which recipes to keep
                	app_network.mergeRecipes(json.decode(response.data.Menu))
                else
                    -- If there is no menu data, publish what is on the device
                    app_network.uploadData()
                end
            else
                native.showAlert("Network Error", tostring(response.message), {"OK"})
                app_network.config.logged_in = false
                globalData.writeNetwork()
            end

            globalData.writeCustomMenu()
        end
	end
	network.request(app_network.url, "POST", networkListener, params)
    -- print("Send request with auth ID " .. app_network.config.auth_token)
end

return syncData
