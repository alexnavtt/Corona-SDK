local globalData 	= require("globalData")
local defaultMenu   = require("DefaultMenu")
local json 			= require("json")

local menu_io = {}

function menu_io.writeCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.menu, {indent = true}))

	io.close(file)
	file = nil
end

function menu_io.readCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	local file = io.open(path, "r")

	print("Loading file")

	if not file then
		print("File did not exist, creating now...")
		file = io.open(path, "w+")
		io.close(file)
		file = io.open(path, "r")
	end

	local jsonString = ""
	for data in file:lines() do
		jsonString = jsonString .. "\n" .. data
	end

	-- print(jsonString)

	if jsonString ~= "" then
		globalData.menu = json.decode(jsonString)
	else
		globalData.menu = {}
	end

	io.close(file)
	file = nil

	-- for name, value in pairs(globalData.menu) do
	-- 	print(" ")
	-- 	print(name)
	-- 	print(value)
	-- end
end

function menu_io.deleteCustomMenu()
	globalData.menu = {}

	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	os.remove(path)
end

function menu_io.readDefaultMenu()
	for name, value in pairs(defaultMenu) do
		if not globalData.menu[name] then
			globalData.menu[name] = value
		end
	end
end

return menu_io
