local composer = require( "composer" )
local cookbook = require( "cookbook" )
local globalData = require( "globalData" )
local widget = require( "widget" )
local tinker = require("Tinker")
local colors = require("Palette")
local app_colors = require("AppColours")
local transition = require("transition")
local new_recipe_info = require("NewRecipeUtil.new_recipe_info")

 
local scene = composer.newScene()

local name_text_field
local prep_time_text_field
local cook_time_text_field 

 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view

	-- Create Background
	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor(unpack(app_colors.new_recipe.background))

	-- Create text field for the name of the recipe
	local field_height = 0.05*display.contentHeight
	local text_field_params = {	radius = field_height/2,
								defaultText = "Enter Recipe Name",
								font = native.systemFontBold,
								backgroundColor = app_colors.new_recipe.info_bar,
								textColor = app_colors.new_recipe.info_text,
								strokeColor = globalData.dark_grey,
								strokeWidth = 2,
								cursorColor = globalData.dark_grey}
	name_text_field = tinker.newTextField(display.contentCenterX, 0.25*display.contentHeight, 0.8*display.contentWidth, 0.05*display.contentHeight, text_field_params)
	sceneGroup:insert(name_text_field)

	-- Create a text field for the prep time of the recipe
	text_field_params.defaultText = "Prep Time"
	prep_time_text_field = tinker.newTextField(0.5*display.contentCenterX, 0.37*display.contentHeight, 0.4*display.contentWidth, 0.05*display.contentHeight, text_field_params)
	sceneGroup:insert(prep_time_text_field)

	-- Create a text field for the cook time of the recipe
	text_field_params.defaultText = "Cook Time"
	cook_time_text_field = tinker.newTextField(1.5*display.contentCenterX, 0.37*display.contentHeight, 0.4*display.contentWidth, 0.05*display.contentHeight, text_field_params)
	sceneGroup:insert(cook_time_text_field)

	-- Show the title of the page up at the top
	local title = display.newText({text = "Recipe Creator",
								   x = display.contentCenterX,
								   y = 0.15*display.contentHeight,
								   width = display.contentWidth,
								   height = 0,
								   font = native.systemFontBold,
								   fontSize = 2*globalData.titleFontSize,
								   align = "center"})
	sceneGroup:insert(title)
	title:setFillColor(unpack(app_colors.new_recipe.title))

	-- An image of a recipe for aesthetics
	local image = display.newImageRect(sceneGroup, "Image Assets/Recipe-Card-Graphic.png", 0.8*display.contentWidth, 0.35*display.contentHeight)
	image.x = display.contentCenterX
	image.y = 0.65*display.contentHeight
	image.strokeWidth = 10
	image:setStrokeColor(unpack(app_colors.new_recipe.outline))

	-- Proceed button to take the user to the next page
	local begin_button = display.newRect(sceneGroup, display.contentCenterX, 0.95*display.contentHeight, display.contentWidth, 0.1*display.contentHeight)
	begin_button:setFillColor(unpack(app_colors.new_recipe.start_button))
	begin_button:setStrokeColor(unpack(app_colors.new_recipe.outline))
	begin_button.strokeWidth = 3

	local begin_label = display.newText({text = "<< Start Recipe Creation >>",
										 x = display.contentCenterX,
										 y = display.contentHeight - 0.5*begin_button.height,
										 width = display.contentWidth,
										 font = native.systemFontBold,
										 fontSize = globalData.titleFontSize,
										 align = "center"})
	begin_label:setFillColor(unpack(app_colors.new_recipe.start_text))
	sceneGroup:insert(begin_label)

	function begin_button:tap(event)
		cookbook.is_editing = true
		cookbook.newRecipeTitle = name_text_field.text
		cookbook.newRecipeParams = {cook_time = cook_time_text_field.text, prep_time = prep_time_text_field.text}
		composer.gotoScene("IngredientsPage", {effect = "slideUp", time = globalData.transition_time})
	end
	begin_button:addEventListener("tap", begin_button)

end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase

	local name; local prep_time; local cook_time;

	if event.params then
		name = event.params.name
		prep_time = event.params.prep_time
		cook_time = event.params.cook_time
	end
 
	if ( phase == "will" ) then
		-- If the tab bar was previously hidden, show it again
		transition.to(globalData.tab_bar, {alpha = 1, time = globalData.transition_time})

		-- Fill in the text fields if this is a recipe edit call
		if name then name_text_field:replaceText(name) end
		if prep_time then prep_time_text_field:replaceText(prep_time) end
		if cook_time then cook_time_text_field:replaceText(cook_time) end

		-- Set the editing key to false, which becomes true when proceeding to the next page
		cookbook.is_editing = false
 
	end
end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		-- Cut off the keyboard if it is in use
		native.setKeyboardFocus(nil)
 
	elseif ( phase == "did" ) then

		if not cookbook.is_editing then 
			-- When leaving the page (not proceeding) clear all fields
			name_text_field:replaceText("")
			prep_time_text_field:replaceText("")
			cook_time_text_field:replaceText("")
			composer.removeScene("IngredientsPage")
			composer.removeScene("InsertStepsPage") 
		end

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