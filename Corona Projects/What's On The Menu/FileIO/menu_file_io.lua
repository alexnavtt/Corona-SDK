local globalData 	= require("globalData")
local defaultMenu   = require("DefaultMenu")
local json 			= require("json")
local util          = require("GeneralUtility")

local menu_io = {}

function menu_io.writeCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	-- Remove default menu before we save
	for name, value in pairs(defaultMenu) do
		if util.tableEquals(globalData.menu[name], value) then
			globalData.menu[name] = nil
		end
	end

	file:write(json.encode(globalData.menu, {indent = true}))

	io.close(file)
	file = nil

	-- Re-add the default menu
	menu_io.readDefaultMenu()
end

function menu_io.readCustomMenu()
	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
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
		globalData.menu = json.decode(jsonString)
	else
		globalData.menu = {}
	end

	io.close(file)
	file = nil
end

function menu_io.deleteCustomMenu()
	globalData.menu = {}

	local path = system.pathForFile(globalData.custom_recipes_file, system.DocumentsDirectory)
	os.remove(path)
end

function menu_io.readDefaultMenu()
	if not globalData.settings.showDefaultRecipes then return true end
	for name, value in pairs(defaultMenu) do
		if not globalData.menu[name] then
			globalData.menu[name] = value
		end
	end
end

return menu_io
