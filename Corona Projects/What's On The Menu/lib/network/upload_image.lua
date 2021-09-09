local json = require("json")
local util = require("GeneralUtility")

local IMG = system.pathForFile("Image Assets/Milk-Graphic.png", system.resourceDirectory)
local dest = system.pathForFile("test_image.png", system.TemporaryDirectory)
local file = io.open(IMG, "rb")
local data = file:read("*a")
file:close()

local dest_file = io.open(dest, "wb+")
dest_file:write(data)
dest_file:close()

-- local a = display.newImageRect("test_image.png", system.TemporaryDirectory, display.contentWidth, display.contentHeight)
-- a.x = display.contentCenterX
-- a.y = display.contentCenterY

local function networkListener(event)
	if (event.isError) then
		print("Network error")
	else
		print("Response:")
		print(event.response)
		print(event.response == data)
	end
end	

-- Set up HTTP package
local body = {test = 1,image = data}
body = json.encode(body)
-- print(body)
-- local body = data

local headers = {}
headers["Content-Type"] = "application/json"
headers["Accept"] = "application/json"

local params = {headers = headers, body = body}

network.request("http://www.recipes.bulldogtt.com/image_listener.php", "POST", networkListener, params)
