-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer 		= require("composer")
local globalData 	= require("globalData")
local json 			= require("json")
local cookbook 		= require("cookbook")
local colors 		= require("Palette")
local lfs 			= require("lfs")
local app_colors 	= require("AppColours")
local tab_bar_util  = require("TabBarUtil.tab_bar_util")

system.setTapDelay(0.5)

-- Data Storage
globalData.menu 		= {}
globalData.keywords 	= {}
globalData.favourites 	= {}
globalData.custom_menu 	= {}
globalData.gallery 		= {}
globalData.textures 	= {}
globalData.settings 	= {}

-- List of all composer scenes in the project
globalData.all_scenes = {"BrowsePage", "FavouritesPage", "NewRecipePage", "IngredientsPage", "InsertStepsPage","ViewRecipePage"}

-- Default Settings for the App
globalData.defaultSettings = {
	colorScheme 		= "blue",
	showDefaultRecipes 	= true,
	recipeStyle 		= "portrait",
}

-- Private Parameters
globalData.info_received = false
globalData.colorOptions = {blue = "blue", red = "red", light = "white", dark = "purple", bright = "green"}

-- Visual Parameters
globalData.smallFontSize  = 0.02*display.contentHeight
globalData.mediumFontSize =	0.0225*display.contentHeight
globalData.titleFontSize  = 0.025*display.contentHeight

-- Geometry Parameters
globalData.panel_width 	= 0.9*display.contentWidth
globalData.panel_height = 0.2*display.contentHeight
globalData.label_height = 0.05*display.contentHeight
globalData.label_width  = 0.45*display.contentWidth

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


function globalData.reloadApp()
	composer.removeScene(globalData.activeScene)
	composer.gotoScene(globalData.activeScene)
	globalData.tab_bar:removeSelf()
	globalData.tab_bar = tab_bar_util.createTabBar()

	for i = 1,#globalData.all_scenes,1 do
		composer.removeScene(globalData.all_scenes[i])
	end
end

-- globalData.info_received = true
local test = false
globalData.readSettings()
globalData.readFavourites()
globalData.readCustomMenu()
-- test = globalData.readWebMenu();
if globalData.settings.showDefaultRecipes then globalData.readDefaultMenu() end
globalData.loadMenuImages()
globalData.cleanupFoodImages()
app_colors.changeTo(globalData.settings.colorScheme or "blue")
if not app_colors.browse then
	app_colors.changeTo("blue")
end
-- app_colors.changeTo("light")

if not test then
	globalData.activeScene = "BrowsePage"
	globalData.tab_bar = tab_bar_util.createTabBar()
	composer.gotoScene("BrowsePage")
end