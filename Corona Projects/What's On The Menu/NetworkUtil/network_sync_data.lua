local json = require("json")
local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")
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

            if response.message then 
                print(string.format("NETWORK: '%s' => %s", response.type, response.message))
            	-- native.showAlert(globalData.app_name, response.message, {"OK"})
            end

            if response.success then
                if response.data and response.data.Menu then
                	app_network.mergeRecipes(json.decode(response.data.Menu))
                else
                    app_network.uploadData()
                end
            else
                app_network.config.logged_in = false
                globalData.writeNetwork()
            end

            globalData.writeCustomMenu()
        end
	end
	network.request(app_network.url, "POST", networkListener, params)
end

return syncData
