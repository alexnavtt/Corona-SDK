local globalData = require("globalData")
local app_network = require("lib.network.library")
local json = require("json")

local file_io = {}

function file_io.writeNetworkLog(message)
	local path = system.pathForFile(globalData.network_log_file, system.DocumentsDirectory)

	local prevString = file_io.readNetworkLog()

	local newString
	if prevString then
		newString = prevString .. "\n" .. message
	else
		newString = message
	end


	local file = io.open(path, "w+")
	file:write(newString)

	io.close(file)
	file = nil
end


function file_io.readNetworkLog()
	local path = system.pathForFile(globalData.network_log_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	if not file then
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local logString
	for data in file:lines() do
		if logString then
			logString = logString .. "\n" .. data
		else
			logString = data
		end
	end

	io.close(file)
	file = nil

	return logString
end

function file_io.deleteNetworkLog()
	local path = system.pathForFile(globalData.network_log_file, system.DocumentsDirectory)
	os.remove(path)
end

return file_io
