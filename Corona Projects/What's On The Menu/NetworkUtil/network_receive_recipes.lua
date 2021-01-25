local globalData = require("globalData")
local app_network = require("NetworkUtil.network_main")
local json = require("json")

local lib = {}

function lib.receiveRecipeNames(friend_email)
	local params = app_network.createHttpRequest("get shared recipe names")
	params.body = json.decode(params.body)
	params.body.recipient = friend_email
	params.body = json.encode(params.body)

	local function networkListener(event)
		if event.isError then
			app_network.log({message = "Connection Error"})
			return;
		end
		
		print(event.response)
		local response = json.decode(event.response)
		if not response then response = {} end

		app_network.log(response)
	end
	network.request(app_network.friend_url, "POST", networkListener, params)
end

function lib.receiveRecipe(friend_email, recipe_title)

end

return lib
