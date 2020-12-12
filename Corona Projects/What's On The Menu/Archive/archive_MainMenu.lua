local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local tabGroup
local iconGroup
local searchGroup = display.newGroup()
local globalData = require("globalData")
local cookbook = require("cookbook")

local function parseMenuSearch(event)
	-- Clear display group
	local result_index = 1
	local function addSearchResult(result_text)
		local resultBox = display.newRect(globalData.search_bar.x, globalData.search_bar.y + result_index*globalData.search_bar.height, globalData.search_bar.width, globalData.search_bar.height)
		resultBox.strokeWidth = 2
		resultBox:setStrokeColor(0.2)

		local result_text_params = {text = result_text,
									x = resultBox.x,
									y = resultBox.y,
									width = 0.8*resultBox.width,
									height = 0,
									font = native.systemFont,
									fontSize = 0.6*globalData.search_bar.size}
		local result_text = display.newText(result_text_params)
		result_text:setFillColor(0)

		local function onTouch(event)
			if event.phase == "began" then
				display.getCurrentStage():setFocus(resultBox)

			elseif event.phase == "ended" or event.phase == "cancelled" then
				for i = 1,searchGroup.numChildren,1 do
					searchGroup:remove(1)
				end
				cookbook.displayRecipe(result_text.text)
				globalData.search_bar.text = ""
				display.getCurrentStage():setFocus(nil)
			end
		end

		result_index = result_index + 1
		resultBox:addEventListener("touch", onTouch)
		searchGroup:insert(resultBox)
		searchGroup:insert(result_text)
	end

	for i = 1,searchGroup.numChildren,1 do
		searchGroup:remove(1)
	end

	if event.phase == "editing" then
		if #event.text > 0 then
			result_foods = cookbook.findRecipe(event.text)

			for food, value in pairs(result_foods) do
				addSearchResult(food)
				if result_index > 5 then
					result_index = 1
					break
				end
			end
		end


	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    tabGroup = display.newGroup()
    iconGroup = display.newGroup()

    --------------------------
    ------- PARAMETERS -------
    --------------------------
    local big_panel_width 	 = 0.80*display.contentWidth
    local big_panel_height   = 0.10*display.contentHeight
    local small_panel_width  = 0.37*display.contentWidth
    local small_panel_height = 0.25*display.contentHeight

    local y_levels = {0.2*display.contentHeight, 0.4*display.contentHeight, 0.67*display.contentHeight}
    local x_levels = {display.contentCenterX, display.contentCenterX - 0.5*big_panel_width + 0.5*small_panel_width,  display.contentCenterX + 0.5*big_panel_width - 0.5*small_panel_width}

    local small_label_text_params = {text = "label", x = 0, y = 0, width = 0.8*small_panel_width, font = "Impact", fontSize = 0.025*display.contentHeight, align = "center"}
 	local big_label_text_params   = {text = "label", x = 0, y = 0, width = 0.8*big_panel_width,   font = native.systemFont, fontSize = 0.02*display.contentHeight, align = "center"}
    -------------------------
    ------------------------- 

    local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    background:setFillColor( 0.8 )

    local searchTab 	= display.newRect(x_levels[1], y_levels[1], big_panel_width, big_panel_height)
    local favouritesTab = display.newRect(x_levels[2], y_levels[2], small_panel_width, small_panel_height)
    local browseTab 	= display.newRect(x_levels[3], y_levels[2], small_panel_width, small_panel_height)
    local searchByIngredientsTab = display.newRect(x_levels[2], y_levels[3], small_panel_width, small_panel_height)
    local makeYourOwnTab = display.newRect(x_levels[3], y_levels[3], small_panel_width, small_panel_height)

 	local tabGradient = {type = "gradient", color1 = {0.5, 0.5, 0.6}, color2 = {0.3, 0.3, 0.7}, direction = "left"}
 	local tabColour   = unpack({0.7, 0.7, 0.7})
 	searchTab:setFillColor(tabColour)
 	favouritesTab:setFillColor(tabColour)
 	browseTab:setFillColor(tabColour)
 	searchByIngredientsTab:setFillColor(tabColour)
 	makeYourOwnTab:setFillColor(tabColour)

 	-- Section Labels
 	local favourites_label_params = small_label_text_params
 	favourites_label_params.x = favouritesTab.x-- + 0.5*favouritesTab.width
 	favourites_label_params.y = favouritesTab.y + 0.38*favouritesTab.height
 	favourites_label_params.text = "Favourites"
 	local favourites_label = display.newText(favourites_label_params)
 	favourites_label:setFillColor(0)
 	local favourite_label_tag = display.newRect(favourites_label.x, favourites_label.y, 0.9*small_panel_width, 0.15*small_panel_height)

 	local make_your_own_params = small_label_text_params
 	make_your_own_params.x = makeYourOwnTab.x
 	make_your_own_params.y = makeYourOwnTab.y + 0.38*makeYourOwnTab.height
 	make_your_own_params.text = "Enter New Recipe"
 	local make_your_own_label = display.newText(make_your_own_params)
 	make_your_own_label:setFillColor(0)
	local make_your_own_tag = display.newRect(make_your_own_label.x, make_your_own_label.y, 0.9*small_panel_width, 0.15*small_panel_height)
 	
 	local browse_params = small_label_text_params
 	browse_params.x = browseTab.x
 	browse_params.y = browseTab.y + 0.38*browseTab.height
 	browse_params.text = "Browse Recipes"
 	local browse_label = display.newText(browse_params)
 	browse_label:setFillColor(0)
 	local browse_tag = display.newRect(browse_label.x, browse_label.y, 0.9*small_panel_width, 0.15*small_panel_height)

 	local ingredients_params = small_label_text_params
 	ingredients_params.x = searchByIngredientsTab.x
 	ingredients_params.y = searchByIngredientsTab.y + 0.38*searchByIngredientsTab.height
 	ingredients_params.text = "Search by Ingredients"
 	ingredients_params.fontSize = 0.8*ingredients_params.fontSize
 	local ingredients_label = display.newText(ingredients_params)
 	ingredients_label:setFillColor(0)
 	local ingredient_tag = display.newRect(ingredients_label.x, ingredients_label.y, 0.9*small_panel_width, 0.15*small_panel_height)
 	-- Load Image Assets
 	local favourites_icon = display.newImageRect("Image Assets/Star.png", 0.9*favouritesTab.width, 0.75*favouritesTab.height)
 	favourites_icon.x = favouritesTab.x-- + 0.5*favouritesTab.width
 	favourites_icon.y = favouritesTab.y - 0.1*favouritesTab.height

 	local make_your_own_icon = display.newImageRect("Image Assets/Make-Your-Own-Graphic.png", 0.9*favouritesTab.width, 0.75*makeYourOwnTab.height)
 	make_your_own_icon.x = makeYourOwnTab.x
 	make_your_own_icon.y = makeYourOwnTab.y - 0.1*makeYourOwnTab.height

 	local browse_icon = display.newImageRect("Image Assets/Recipe-App-Icon.png", 0.9*browseTab.width, 0.75*browseTab.height)
 	browse_icon.x = browseTab.x
 	browse_icon.y = browseTab.y - 0.1*browseTab.height 

 	-- Insert all objects into SceneGroups
 	-- local recipe_group = cookbook.displayRecipe("Caramelized Baked Onions")
 	-- local recipe_group = cookbook.displayRecipe("Classic Waffle")
 	-- local recipe_group = cookbook.displayRecipe("Banana Bread")
 	-- local recipe_group = cookbook.displayRecipe("Hot Chocolate")

 	sceneGroup:insert(background)
 	sceneGroup:insert(tabGroup)
 	-- sceneGroup:insert(recipe_group)

 	tabGroup:insert(searchTab)
 	tabGroup:insert(favouritesTab)
 	tabGroup:insert(favourites_icon)
 	tabGroup:insert(browseTab)
 	tabGroup:insert(searchByIngredientsTab)
 	tabGroup:insert(makeYourOwnTab)

 	iconGroup:insert(favourites_icon)
 	iconGroup:insert(favourite_label_tag)
 	iconGroup:insert(favourites_label)
 	iconGroup:insert(make_your_own_icon)
 	iconGroup:insert(make_your_own_tag)
 	iconGroup:insert(make_your_own_label)
 	iconGroup:insert(browse_icon)
 	iconGroup:insert(browse_tag)
 	iconGroup:insert(browse_label)
 	iconGroup:insert(ingredient_tag)
 	iconGroup:insert(ingredients_label)

 	sceneGroup:insert(tabGroup)
 	sceneGroup:insert(iconGroup)
 	sceneGroup:insert(searchGroup)

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
    	globalData.relocateSearchBar(display.contentCenterX, 0.2*display.contentHeight, 0.64*display.contentWidth, 0.05*display.contentHeight)
	 	-- globalData.relocateSearchBar2(searchByIngredientsTab.x, searchByIngredientsTab.y, 0.8*searchByIngredientsTab.width, 0.5*searchByIngredientsTab.height)

	 	globalData.search_bar:addEventListener("userInput", parseMenuSearch)
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene