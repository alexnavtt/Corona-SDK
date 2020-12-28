local json = require("json")
local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")

local function syncData(hard_overwrite)
	if app_network.config.username == "" then
		native.showAlert(globalData.app_name, "Username cannot be empty")
		return false
	end
	
	local params = app_network.createHttpRequest("download")

	-- Data retrieval listener
	local function GETListener( event )
        if event.isError then
            native.showAlert(globalData.app_name, "Could not connect to the server, please check your network connection", {"OK"})
        else
            local received_data = event.response
            local decodedData = (json.decode(received_data))
            if decodedData == nil then 
            	native.showAlert(globalData.app_name, event.respose, {"OK"})
            else
            	app_network.mergeRecipes(json.decode(decodedData["1"].Menu))
            end

        end
	end
	network.request(app_network.url, "GET", GETListener, params)
end

return syncData
