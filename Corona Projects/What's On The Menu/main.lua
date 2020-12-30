-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer 		  = require("composer")
local json 			  = require("json")
local lfs 			  = require("lfs")

local globalData 	  = require("globalData")
local cookbook 		  = require("cookbook")
local colors 		  = require("Palette")
local app_colors 	  = require("AppColours")
local tab_bar_util    = require("TabBarUtil.tab_bar_util")
local util            = require("GeneralUtility")
local app_network     = require("AppNetwork")
local app_transitions = require("AppTransitions")

system.setTapDelay(0.5)
globalData.app_name = "What's On the Menu"

-- Data Storage
globalData.menu 		= {}
globalData.keywords 	= {}
globalData.favourites 	= {}
globalData.custom_menu 	= {}
globalData.gallery 		= {}
globalData.textures 	= {}
globalData.settings 	= {}

-- List of all composer scenes in the project
globalData.all_scenes = {"BrowsePage", "FavouritesPage", "NewRecipePage", "IngredientsPage", "InsertStepsPage","ViewRecipePage","ViewLandscapeRecipe", "NetworkProfile"}

-- Default Settings for the App
globalData.defaultSettings = {
	colorScheme 		= "blue",
	showDefaultRecipes 	= true,
	recipeStyle 		= "portrait",
	allow_idle_timeout  = true,
	network_is_enabled  = false
}

-- Private Parameters
globalData.info_received = false

-- Visual Parameters
globalData.smallFontSize  = 0.02*display.contentHeight
globalData.mediumFontSize =	0.0225*display.contentHeight
globalData.titleFontSize  = 0.025*display.contentHeight

-- Text Field Parameters
local tab_height = tab_bar_util.tab_height

-- Scrollview Parmameters
function globalData.scroll_options()

	M ={x = display.contentCenterX, 
		y = display.contentCenterY + 0.5*tab_height, 
		width = display.contentWidth, 
		height = display.contentHeight - tab_height,
		friction = 0.97,
		horizontalScrollDisabled = true,
		isBounceEnabled = false,
		backgroundColor = globalData.background_color,
		maxVelocity = 4,
		bottomPadding = 0.3*display.contentWidth}
	return M
end

-- File Storage
globalData.favourites_file 		= "Favourites.txt"
globalData.custom_recipes_file 	= "CustomRecipes.txt"
globalData.images_file 			= "FoodImages.txt"
globalData.settings_file 		= "AppSettings.txt"
globalData.network_config_file  = "NetworkConfig.txt"

-- Other
globalData.transition_time = 300

-- File IO
local menu_io = require("FileIO.menu_file_io")
globalData.writeCustomMenu  = menu_io.writeCustomMenu
globalData.readCustomMenu   = menu_io.readCustomMenu
globalData.deleteCustomMenu = menu_io.deleteCustomMenu
globalData.readDefaultMenu  = menu_io.readDefaultMenu

local favourites_io = require("FileIO.favourites_file_io")
globalData.writeFavourites  = favourites_io.writeFavourites
globalData.readFavourites   = favourites_io.readFavourites
globalData.deleteFavourites = favourites_io.deleteFavourites 

local image_io = require("FileIO.food_image_io")
globalData.saveMenuImages  = image_io.saveMenuImages
globalData.loadMenuImages  = image_io.loadMenuImages
globalData.deleteFoodImage = image_io.deleteFoodImage
globalData.cleanupFoodImages = image_io.cleanupFoodImages

local settings_io = require("FileIO.settings_io")
globalData.writeSettings  = settings_io.writeSettings
globalData.readSettings   = settings_io.readSettings
globalData.deleteSettings = settings_io.deleteSettings

local network_io = require("FileIO.network_file_io")
globalData.writeNetwork  = network_io.writeNetworkConfig
globalData.readNetwork   = network_io.readNetworkConfig
globalData.deleteNetwork = network_io.deleteNetworkConfig


function globalData.reloadApp()
	composer.removeScene(globalData.activeScene)
	composer.gotoScene(globalData.activeScene, {params = {reload = true}})
	globalData.tab_bar:removeSelf()
	globalData.tab_bar = tab_bar_util.createTabBar()

	for i = 1,#globalData.all_scenes,1 do
		composer.removeScene(globalData.all_scenes[i])
	end
end

-- Overwrite the back button on the phone
function globalData.goBack(event)
	if (event.keyName == "back" and event.phase == "down") then
		local last_scene = composer.getSceneName("previous")
		local current_scene = composer.getSceneName("current")

		-- Notable exceptions
		if last_scene == "InsertStepsPage" and current_scene == "BrowsePage"    then return globalData.tab_bar:update() end
		if last_scene == "IngredientsPage" and current_scene == "NewRecipePage" then return globalData.tab_bar:update() end

		app_transitions.moveTo(last_scene, globalData.activeRecipe)
		globalData.tab_bar:update()
	end

	return true
end
Runtime:addEventListener("key", globalData.goBack)

-- Start the app
globalData.readSettings()
globalData.readFavourites()
globalData.readCustomMenu()
globalData.readDefaultMenu() 
globalData.readNetwork()

globalData.loadMenuImages()
globalData.cleanupFoodImages()
app_colors.changeTo(globalData.settings.colorScheme or "blue")

-- Runs only the first time the app is loaded
if not globalData.settings.initialized then
	globalData.settings.unique_id = math.random(0, 1000000000)
	globalData.settings.initialized = true
	globalData.writeSettings()
end

if globalData.settings.network_is_enabled and app_network.config.logged_in then
	app_network.syncData()
end

globalData.activeScene = "BrowsePage"
globalData.lastScene = "BrowsePage"
globalData.tab_bar = tab_bar_util.createTabBar()
composer.gotoScene("BrowsePage")
