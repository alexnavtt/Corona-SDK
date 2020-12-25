local globalData = require("globalData")
local json = require("json")
local defaultMenu = require("DefaultMenu")

local image_io = {}

function image_io.saveMenuImages()
	local path = system.pathForFile(globalData.images_file, system.DocumentsDirectory)
	local file = io.open(path, "w+")

	file:write(json.encode(globalData.gallery, {indent = true}))

	io.close(file)
	file = nil
end

function image_io.loadMenuImages()
	local path = system.pathForFile(globalData.images_file, system.DocumentsDirectory)
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
		globalData.gallery = json.decode(jsonString)
	else
		globalData.gallery = {}
	end

	io.close(file)
	file = nil

	for foodname, value in pairs(globalData.gallery) do
		local texture = graphics.newTexture({type = "image", filename = "Food_Images__"..foodname..".png", baseDir = system.DocumentsDirectory})

		if texture then
			texture:preload()
			globalData.textures[foodname] = texture
		else
			globalData.gallery[foodname] = nil
			globalData.saveMenuImages()
		end
	end
end

function image_io.deleteFoodImage(title)
	local path = system.pathForFile("Food_Images__"..title..".png", system.DocumentsDirectory)
	os.remove(path)

	globalData.gallery[title] = nil
	globalData.textures[title] = nil
	globalData.saveMenuImages()
end

function image_io.cleanupFoodImages()
	local path = system.pathForFile(nil, system.DocumentsDirectory)

	for file in lfs.dir(path) do
		local extension = file:sub(file:len() - 2)

		if extension == "png" then
			local foodname = file:sub(14, file:len()-4)

			local function deleteListener(event)
				if event.index == 1 then
					globalData.deleteFoodImage(foodname)
				else
					return true
				end
			end

			if not globalData.menu[foodname] and not defaultMenu[foodname] then
				native.showAlert("What's on the Menu", "Recipe Not Found For Image '" .. foodname .. "'. Delete saved image?", {"OK", "No, keep it"}, deleteListener)
			end
		end
	end
end

return image_io
