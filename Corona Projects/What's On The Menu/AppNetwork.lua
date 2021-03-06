local app_network = require("NetworkUtil.network_main")
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
app_network.createHttpRequest     = require("NetworkUtil.network_create_http_request")
app_network.changeUsername        = require("NetworkUtil.network_change_username")
app_network.changePassword        = require("NetworkUtil.network_change_password")
app_network.createProfile         = require("NetworkUtil.network_create_profile")
app_network.sendNewProfileRequest = require("NetworkUtil.network_send_new_profile_request")
app_network.logIn                 = require("NetworkUtil.network_log_in")
app_network.logOut				  = require("NetworkUtil.network_log_out")
app_network.uploadData            = require("NetworkUtil.network_upload_data")
app_network.syncData              = require("NetworkUtil.network_sync_data")
app_network.mergeRecipes          = require("NetworkUtil.network_merge_recipes")
app_network.createLoginPanel      = require("NetworkUtil.network_login_panel")
app_network.changePasswordPanel   = require("NetworkUtil.network_change_password_panel")
app_network.log                   = require("NetworkUtil.network_log")

-- Friends
app_network.friends = {}
app_network.friend_url = "http://www.recipes.bulldogtt.com/friend_listener.php"
app_network.sendRecipe             = require("NetworkUtil.network_send_recipe")
app_network.getFriends             = require("NetworkUtil.network_get_friends")
app_network.deleteFriend           = require("NetworkUtil.network_delete_friend")
app_network.sendFriendRequest      = require("NetworkUtil.network_send_friend_request")
app_network.checkForFriendRequest  = require("NetworkUtil.network_check_for_friend_request")
app_network.respondToFriendRequest = require("NetworkUtil.network_respond_to_friend_request")

local network_recipes = require("NetworkUtil.network_receive_recipes")
app_network.receiveRecipeNames = network_recipes.receiveRecipeNames
app_network.receiveRecipe = network_recipes.receiveRecipe

function app_network.connectionError()
	native.showAlert(globalData.app_name, "Cannot connect to server, please check your network connection", {"OK"})
end

return app_network
