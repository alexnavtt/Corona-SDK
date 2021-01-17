local app_network = require("NetworkUtil.network_main")
local globalData = require("globalData")
local json = require("json")

local function log(response)
	if response.message then
		globalData.writeNetworkLog(os.date("%c") .. "\nType => '" .. response.type .. "''\nMessage => '" .. response.message .. "'\n\n")
	end
end

return log
