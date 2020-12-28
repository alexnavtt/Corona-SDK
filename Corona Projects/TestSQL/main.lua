local json = require("json")

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

local background = display.newRect(cX, cY, W, H)
background:setFillColor(0.5)

-- URL of the database listener
local url = "http://www.recipes.bulldogtt.com/update_listener.php"

-- Set up HTTP package
local data = {first_name = "Alex", last_name = "Navarro", favourite_foods = {"steak", "pancakes"}}
local body = {username = "A", password = "1", data = json.encode(data), new_user = true, friends = json.encode({"Alex"})}
body = json.encode(body)

local headers = {}
headers["Content-Type"] = "application/json"
headers["Accept"] = "application/json"

local params = {headers = headers, body = body}

-- Data retrieval listener
local function GETListener( event )
        if event.isError then
                print( "Network error!")
        else
        		print(" ")
        		print("Retrieved Data:")
                myNewData = event.response
                print (myNewData)

                decodedData = (json.decode( myNewData))
                -- print(decodedData)
                print("----------")
        end
end
network.request(url, "GET", GETListener, params)


local function POSTListener(event)
	if event.isError then
		print("Network error!")
	else
		print(" ")
		print("Post results:")
		print(event.response)
		print("----------")
	end
end
network.request(url, "POST", POSTListener, params)

-- local crypto = require("crypto")
-- print(crypto.hmac(crypto.md5, "tesa", ""))
