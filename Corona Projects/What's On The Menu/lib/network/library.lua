local app_network = require("lib.network.main")
local globalData = require("globalData")

-- Network Data
app_network.url = "http://www.recipes.bulldogtt.com/update_listener.php"
app_network.username_url = "http://www.recipes.bulldogtt.com/check_username_availability.php"
app_network.new_user = false
app_network.password = ""

-- Mutable configuration parameters
app_network.config = {}
app_network.config.username = ""
app_network.config.auth_token = ""
app_network.config.logged_in = false
app_network.config.first_time = true
app_network.config.last_upload_time = 0

-- Network Functions
app_network.createHttpRequest     = require("lib.network.create_http_request")
app_network.changeUsername        = require("lib.network.change_username")
app_network.changePassword        = require("lib.network.change_password")
app_network.createProfile         = require("lib.network.create_profile")
app_network.sendNewProfileRequest = require("lib.network.send_new_profile_request")
app_network.logIn                 = require("lib.network.log_in")
app_network.logOut				  = require("lib.network.log_out")
app_network.uploadData            = require("lib.network.upload_data")
app_network.syncData              = require("lib.network.sync_data")
app_network.mergeRecipes          = require("lib.network.merge_recipes")
app_network.createLoginPanel      = require("lib.network.login_panel")
app_network.changePasswordPanel   = require("lib.network.change_password_panel")
app_network.log                   = require("lib.network.log")

-- Friends
app_network.friends = {}
app_network.friend_url = "http://www.recipes.bulldogtt.com/friend_listener.php"
app_network.sendRecipe             = require("lib.network.send_recipe")
app_network.getFriends             = require("lib.network.get_friends")
app_network.deleteFriend           = require("lib.network.delete_friend")
app_network.sendFriendRequest      = require("lib.network.send_friend_request")
app_network.checkForFriendRequest  = require("lib.network.check_for_friend_request")
app_network.respondToFriendRequest = require("lib.network.respond_to_friend_request")

local network_recipes = require("lib.network.receive_recipes")
app_network.receiveRecipeNames = network_recipes.receiveRecipeNames
app_network.receiveRecipe = network_recipes.receiveRecipe

function app_network.connectionError()
	native.showAlert(globalData.app_name, "Cannot connect to server, please check your network connection", {"OK"})
end

return app_network
