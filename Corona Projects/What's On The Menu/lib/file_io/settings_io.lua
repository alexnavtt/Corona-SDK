local globalData = require("globalData")
local json = require("json")

local settings_io = {}

function settings_io.writeSettings()
	local path = system.pathForFile(globalData.settings_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.settings, {indent = true}))

	io.close(file)
	file = nil
end


function settings_io.readSettings()
	local path = system.pathForFile(globalData.settings_file, system.DocumentsDirectory)
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
		globalData.settings = json.decode(jsonString)
	else
		globalData.settings = globalData.defaultSettings
	end

	io.close(file)
	file = nil
end

function settings_io.deleteSettings()
	globalData.settings = globalData.defaultSettings

	local path = system.pathForFile(globalData.settings_file, system.DocumentsDirectory)
	os.remove(path)
end

return settings_io
