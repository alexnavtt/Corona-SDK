local app_network = require("NetworkUtil.network_main")

-- Network Data
app_network.url = "http://www.recipes.bulldogtt.com/update_listener.php"
app_network.username_url = "http://www.recipes.bulldogtt.com/check_username_availability.php"
app_network.new_user = false

-- Mutable configuration parameters
app_network.config = {}
app_network.config.username = ""
app_network.config.encrypted_password = ""
app_network.config.friends = {}
app_network.config.logged_in = false
app_network.config.first_time = true

-- Network Functions
app_network.createHttpRequest = require("NetworkUtil.network_create_http_request")
app_network.uploadData = require("NetworkUtil.network_upload_data")
app_network.syncData   = require("NetworkUtil.network_sync_data")
app_network.createProfile = require("NetworkUtil.network_create_profile")
app_network.isUsernameAvailable = require("NetworkUtil.network_is_username_available")

return app_network
