local globalData = require("globalData")
local widget = require("widget")
local composer = require("composer")
local json = require("json")
local tinker = require("ext_libs.tinker.tinker")
local colors = require("Palette")
local app_colors = require("AppColours")
local transition = require("transition")
local new_recipe_info = require("pages.FriendPage.new_recipe_info")

-- Custom library for the cookbook app
local cookbook = require("lib.cookbook.cookbook_main")


-- Foods and Ingredients ----------------------------------
local foods = require("lib.cookbook.cookbook_foods")
cookbook.common_ingredients = foods.common_ingredients
cookbook.meats 				= foods.meats
cookbook.fruits_and_veggies = foods.fruits_and_veggies
cookbook.starches 			= foods.starches
cookbook.seasonings 		= foods.seasonings
cookbook.dairy 				= foods.dairy
cookbook.sauces 			= foods.sauces
cookbook.nuts 				= foods.nuts
-- ========================================================



-- Measurements and Conversions ---------------------------
local measurements = require("lib.cookbook.cookbook_measurements")
cookbook.densities 		 = measurements.densities
cookbook.essential_units = measurements.essential_units
cookbook.volumes 		 = measurements.volumes
cookbook.masses  		 = measurements.masses
cookbook.convertFromCup  = measurements.convertFromCup
cookbook.convertFromGram = measurements.convertFromGram
cookbook.convertUnit     = measurements.convertUnit

-- Populate the ingredient list with the imported foods
cookbook.ingredientList = {}
local categories = {"common_ingredients", "meats", "fruits_and_veggies", "dairy", "nuts", "sauces", "seasonings", "starches"} 
for i = 1,#categories,1 do
	for food, value in pairs(cookbook[categories[i]]) do
		cookbook.ingredientList[food] = true
	end
end
-- ========================================================



-- Searching through the menu -----------------------------
local menu_parser = require("lib.cookbook.cookbook_menu_parsing")
cookbook.findRecipe = menu_parser.findRecipe
cookbook.searchMenu = menu_parser.searchMenu
cookbook.searchIngredients = menu_parser.searchIngredients
-- ========================================================



-- Edit an existing recipe --------------------------------
function cookbook.editRecipe(title)
	new_recipe_info.edit_existing_recipe = true
	new_recipe_info.newRecipeTitle = title
	new_recipe_info.oldRecipeTitle = title
	new_recipe_info.newRecipeIngredientList = {}
	new_recipe_info.newRecipeSteps = {}
	new_recipe_info.newRecipeParams = {}

	for index, ingredient in pairs(globalData.menu[title].ingredients) do
		new_recipe_info.newRecipeIngredientList[ingredient.name] = {amount = ingredient.amount, text_amount = ingredient.text_amount, unit = ingredient.unit} 
	end

	for index, step in pairs(globalData.menu[title].steps) do
		table.insert(new_recipe_info.newRecipeSteps, step)
	end

	new_recipe_info.newRecipeParams = {cook_time = globalData.menu[title].cook_time, prep_time = globalData.menu[title].prep_time}
	globalData.activeScene = "NewRecipePage"
	composer.gotoScene("NewRecipePage", {params = {name = title, prep_time = globalData.menu[title].prep_time, cook_time = globalData.menu[title].cook_time}})
	globalData.tab_bar:update()
	return true
end
-- ========================================================


-- Camera Functions ---------------------------------------

-- Import an image from the device camera
function cookbook.captureFoodImage(title)

	local filename = "Food_Images__"..title..".png"
	local function recordImage(event) 
		local test_image = display.newImage(filename, system.DocumentsDirectory)
		if not test_image then return true end

		globalData.gallery[title] = {width = test_image.width, height = test_image.height, source = "camera"}
		test_image:removeSelf()

		if globalData.textures[title] then
			globalData.textures[title]:releaseSelf()
			globalData.textures[title] = nil
		end
		composer.removeScene(globalData.activeScene)

		globalData.saveMenuImages()
		
		composer.gotoScene(globalData.activeScene)
	end

	media.capturePhoto( { listener = recordImage, destination = {baseDir = system.DocumentsDirectory, filename = filename }} )
end

-- Import an image from the device memory
function cookbook.selectFoodImage(title)

	local filename = "Food_Images__"..title..".png"
	local function recordImage(event)
		local test_image = display.newImage(filename, system.DocumentsDirectory)
		if not test_image then return true end

		globalData.gallery[title] = {width = test_image.width, height = test_image.height, source = "gallery"}
		test_image:removeSelf()

		if globalData.textures[title] then
			globalData.textures[title]:releaseSelf()
			globalData.textures[title] = nil
		end
		composer.removeScene(globalData.activeScene)

		globalData.saveMenuImages()

		composer.gotoScene(globalData.activeScene)
	end

	media.selectPhoto({ listener = recordImage , mediaSource = media.PhotoLibrary, destination = {baseDir = system.DocumentsDirectory, filename = "Food_Images__"..title..".png"}} )
end
-- ========================================================

return cookbook