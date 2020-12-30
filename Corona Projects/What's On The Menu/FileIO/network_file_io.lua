local globalData = require("globalData")
local app_network = require("AppNetwork")
local json = require("json")

local file_io = {}

function file_io.writeNetworkConfig()
	local path = system.pathForFile(globalData.network_config_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(app_network.config, {indent = true}))

	io.close(file)
	file = nil
end


function file_io.readNetworkConfig()
	local path = system.pathForFile(globalData.network_config_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	if not file then
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local jsonString = ""
	for data in file:lines() do
		jsonString = jsonString .. "\n" .. data
	end

	if jsonString ~= "" then
		app_network.config = json.decode(jsonString)
	end

	io.close(file)
	file = nil
end

function file_io.deleteNetworkConfig()
	package.loaded.AppNetwork = nil
	app_network = require("AppNetwork")

	local path = system.pathForFile(globalData.network_config_file, system.DocumentsDirectory)
	os.remove(path)
end

return file_io
