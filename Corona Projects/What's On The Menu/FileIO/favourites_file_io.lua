local globalData = require("globalData")
local json = require("json")

local file_io = {}

function file_io.writeFavourites()
	local path = system.pathForFile(globalData.favourites_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.favourites, {indent = true}))

	io.close(file)
	file = nil
end


function file_io.readFavourites()
	local path = system.pathForFile(globalData.favourites_file, system.DocumentsDirectory)
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
		globalData.favourites = json.decode(jsonString)
	else
		globalData.favourites = {}
	end

	io.close(file)
	file = nil
end

function file_io.deleteFavourites()
	globalData.favourites = {}

	local path = system.pathForFile(globalData.favourites_file, system.DocumentsDirectory)
	os.remove(path)
end

return file_io
