local composer = require("composer")
local cookbook = require("cookbook")
local widget = require("widget")
local globalData = require("globalData")
local tinker = require("Tinker")
local app_colors = require("AppColours")
local transition = require("transition")
local new_recipe_info = require("NewRecipeUtil.new_recipe_info")
local tab_bar_util = require("TabBarUtil.tab_bar_util")
local util = require("GeneralUtility")
local app_network = require("AppNetwork")
 
local scene = composer.newScene()

local current_index

local steps_text_field = native.newTextBox(-500,-500,100,100)
steps_text_field.isEditable = true
steps_text_field.anchorX = 0

local steps_field_x = 0
local steps_field_y = tab_bar_util.tab_height + 0.15*(display.contentHeight - tab_bar_util.tab_height)
local steps_field_w = display.contentWidth
local steps_field_h = 0.2*(display.contentHeight - tab_bar_util.tab_height)
local steps_field_home = {steps_field_x, steps_field_y, steps_field_w, steps_field_h}

local function relocateStepsField(x,y,width,height)
	steps_text_field.x = x
	steps_text_field.y = y
	if width then
		steps_text_field.width = width
	end

	if height then
		steps_text_field.height = height
	end

	steps_text_field.size = globalData.titleFontSize
end
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function finalizeRecipe(event)
	util.printTable(new_recipe_info)

	local recipe_title
	if globalData.menu[new_recipe_info.newRecipeTitle] == nil then
		recipe_title = new_recipe_info.newRecipeTitle
	else
		for i = 1,10000,1 do
			if not globalData.menu[new_recipe_info.newRecipeTitle .. " " .. i] then
				recipe_title = new_recipe_info.newRecipeTitle .. " " .. i
				break
			end
		end
	end

	-- Overwrite Value if editing
	if new_recipe_info.edit_existing_recipe then recipe_title = new_recipe_info.newRecipeTitle end

	globalData.menu[recipe_title] = {ingredients = {}, steps = {}}

	for ingredient_name, values in pairs(new_recipe_info.newRecipeIngredientList) do
		table.insert(globalData.menu[recipe_title].ingredients, {name = ingredient_name, amount = values.amount, unit = values.unit, text_amount = values.text_amount})
	end

	for index, step_text in pairs(new_recipe_info.newRecipeSteps) do
		table.insert(globalData.menu[recipe_title].steps, step_text)
	end

	globalData.menu[recipe_title].cook_time = new_recipe_info.newRecipeParams.cook_time
	globalData.menu[recipe_title].prep_time = new_recipe_info.newRecipeParams.prep_time
	globalData.menu[recipe_title].timestamp = util.time()

	app_network.config.last_update_time = util.time()

	new_recipe_info.newRecipeIngredients = {}
	new_recipe_info.newRecipeSteps = {}
	new_recipe_info.newRecipeTitle = nil
	new_recipe_info.newRecipeParams = {}
	new_recipe_info.is_editing = false
	new_recipe_info.edit_existing_recipe = false

	globalData.writeCustomMenu()
	if app_network.config.logged_in and globalData.settings.network_is_enabled then
		app_network.uploadData()
	end
	
	globalData.activeScene = 'BrowsePage'
	composer.gotoScene('BrowsePage')
	composer.removeScene('NewRecipePage')
	composer.removeScene('IngredientsPage')
	composer.removeScene('InsertStepsPage')

	globalData.tab_bar:update()
end
 
local function updateStepText(event)

 	local non_indented_x = 0.05*display.contentWidth
 	local indented_x = 1.5*non_indented_x
 	local Y = 0.05*(display.contentHeight - tab_bar_util.tab_height)
 	local dY = Y

 	for i = 1,scene.steps_scroll_view._collectorGroup.numChildren,1 do
 		scene.steps_scroll_view:remove(1)
 	end

 	for i = 1,#new_recipe_info.newRecipeSteps,1 do

 		local title = display.newText( {text = "Step " .. i,
 										x = non_indented_x,
 										y = Y,
 										width = 0,
 										height = 0,
 										font = native.systemFontBold,
 										fontSize = globalData.titleFontSize,
 										align = "left"})
 		title:setFillColor(unpack(app_colors.steps.step_text))
 		title.anchorX = 0
 		title.id = 'Step Title ' .. i
 		scene.steps_scroll_view:insert(title)

 		local trash_step = display.newRect(	display.contentWidth - 3*indented_x,
 											title.y,
 											1.5*globalData.titleFontSize,
 											1.5*globalData.titleFontSize)
 		local trash_image = "Image Assets/White-Trash-Graphic.png"
 		if app_colors.scheme == "light" then trash_image = "Image Assets/Trash-Graphic-Simple.png" end
 		trash_step.fill = {type = "image", filename = trash_image}
 		scene.steps_scroll_view:insert(trash_step)

 		function trash_step:tap(event)
 			for j = 1,#new_recipe_info.newRecipeSteps,1 do
 				if j > i then
 					new_recipe_info.newRecipeSteps[j-1] = new_recipe_info.newRecipeSteps[j]
 				end
 			end
 			new_recipe_info.newRecipeSteps[#new_recipe_info.newRecipeSteps] = nil
 			print("tapped " .. i)
 			updateStepText()
 			return true
 		end
 		trash_step:addEventListener("tap", trash_step)

 		local function editStep()
 			current_index = i
 			steps_text_field.text = new_recipe_info.newRecipeSteps[i]
 		end

 		local edit_image = "Image Assets/White-Edit-Graphic.png"
 		if app_colors.scheme == "light" then edit_image = "Image Assets/Edit-Graphic.jpg" end
 		local edit_params = {image = edit_image, color = {0,0,0,0.01}, tap_func = editStep}
 		local edit_button = tinker.newButton(title.x + 1.4*title.width, title.y, 1.5*title.height, 1.5*title.height, edit_params)
 		scene.steps_scroll_view:insert(edit_button)

 		local function decreaseIndex()
 			local temp_text = new_recipe_info.newRecipeSteps[i]
 			local new_index = i-1

 			if new_index == 0 then return true end

 			new_recipe_info.newRecipeSteps[i] = new_recipe_info.newRecipeSteps[new_index]
 			new_recipe_info.newRecipeSteps[new_index] = temp_text

 			updateStepText()
 		end

 		local function increaseIndex()
 			local temp_text = new_recipe_info.newRecipeSteps[i]
 			local new_index = i+1

 			if new_index == #new_recipe_info.newRecipeSteps+1 then return true end

 			new_recipe_info.newRecipeSteps[i] = new_recipe_info.newRecipeSteps[new_index]
 			new_recipe_info.newRecipeSteps[new_index] = temp_text

 			updateStepText()
 		end

 		local arrow_image = "Image Assets/White-Up-Arrow-Graphic.png"
 		if app_colors.scheme == "light" then arrow_image = "Image Assets/Small-Black-Up-Arrow-Graphic.png" end

 		local up_arrow_params = {image = arrow_image, color = {0,0,0,0.01}, tap_func = decreaseIndex}
 		local up_arrow = tinker.newButton(trash_step.x + 1.5*indented_x, trash_step.y, trash_step.width, trash_step.height, up_arrow_params)
 		scene.steps_scroll_view:insert(up_arrow)

 		local down_arrow_params = {image = arrow_image, color = {0,0,0,0.01}, tap_func = increaseIndex}
 		local down_arrow = tinker.newButton(up_arrow.x + 0.7*indented_x, trash_step.y, trash_step.width, trash_step.height, down_arrow_params)
 		down_arrow:rotate(180)
 		scene.steps_scroll_view:insert(down_arrow)

 		-- Increment Text Level
 		Y = Y + 0.5*dY

 		local step = display.newText({text = new_recipe_info.newRecipeSteps[i],
 									  x = indented_x,
 									  y = Y,
 									  width = 0.8*display.contentWidth,
 									  height = 0,
 									  fontSize = globalData.titleFontSize,
 									  align = "left"})
 		step:setFillColor(unpack(app_colors.steps.step_text))
 		step.anchorX = 0
 		step.anchorY = 0
 		step.id = "Step " .. i
 		scene.steps_scroll_view:insert(step)

 		Y = Y + dY + step.height
 	end

end


local function stepFieldInputListener(event)

 	if event.phase == "editing" then
 		local STR = string.format("%q",steps_text_field.text)

 		if STR:sub(#STR-4,#STR-2) == "\\r\\" or STR:sub(#STR-4,#STR-2) == "\\n\\" then
 			table.insert(new_recipe_info.newRecipeSteps, steps_text_field.text)
 			steps_text_field.text = ""
 			-- scene.glass_screen:toBack()
 			native.setKeyboardFocus(nil)
 			updateStepText()
 		end
 	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view

	-- steps_text_field = native.newTextBox(-500,-500,100,100)
	steps_text_field.isEditable = true
	steps_text_field.anchorX = 0
	steps_text_field:addEventListener("userInput", stepFieldInputListener)

	-- BACKGROUND GROUP DEFINITION
	self.back_group = display.newContainer(sceneGroup, display.contentWidth, (display.contentHeight - tab_bar_util.tab_height))
 	self.back_group.y = tab_bar_util.tab_height + 0.5*(display.contentHeight - tab_bar_util.tab_height)
 	self.back_group.x = display.contentCenterX

 	local background = display.newRect(self.back_group, display.contentCenterX, 0, 2*display.contentWidth, self.back_group.height)
 	background:setFillColor(unpack(app_colors.steps.title_bkgd))

 	local insert_step_text = display.newText({text = "Insert Steps One By One",
 											  x = 0,
 											  y = -0.475*self.back_group.height,
 											  width = display.contentWidth,
 											  font = native.systemFontBold,
 											  fontSize = globalData.titleFontSize,
 											  align = "center"})
 	insert_step_text:setFillColor(unpack(app_colors.steps.title_text))
 	self.back_group:insert(insert_step_text)

 	local temp_tab = tab_bar_util.simpleTabBar("Insert Steps", "Back to Ingredients", "IngredientsPage", "Finish", "BrowsePage")
 	local finalize_button = util.findID(temp_tab, "BrowsePage")
 	finalize_button:addEventListener("tap", finalizeRecipe)
 	sceneGroup:insert(temp_tab) 

 	local options = {left = -display.contentCenterX, top = -0.2*self.back_group.height, 
					 width = display.contentWidth, height = 0.7*(display.contentHeight - tab_bar_util.tab_height),
					 horizontalScrollDisabled = true, 
					 isBounceEnabled = false,
					 backgroundColor = app_colors.steps.background,
					 bottomPadding = 0.1*display.contentHeight
					}
	self.steps_scroll_view = widget.newScrollView(options)
	self.back_group:insert(self.steps_scroll_view)

end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		steps_text_field = native.newTextBox(-500,-500,100,100)
		steps_text_field.isEditable = true
		steps_text_field.anchorX = 0

		relocateStepsField(unpack(steps_field_home)) 
		sceneGroup:insert(steps_text_field)
		updateStepText()
		-- self.update_handle = timer.performWithDelay(100, updateStepText, -1)
		-- Code here runs when the scene is still off screen (but is about to come on screen)
 
	elseif ( phase == "did" ) then
		self.submit_button = display.newRect(sceneGroup, 
										  steps_text_field.x, 
										  steps_text_field.y + 0.5*steps_text_field.height,
										  0.5*steps_text_field.width,
										  0.5*(display.contentHeight - tab_bar_util.tab_height - self.steps_scroll_view.height - steps_text_field.height))
		self.submit_button.anchorX = 0
		self.submit_button.anchorY = 0
		self.submit_button:setFillColor(unpack(app_colors.steps.title_bkgd))
		-- self.submit_button.fill = {type = "image", filename = "Image Assets/Check-Graphic.png"}

		local submit_button = self.submit_button
		local submit_text = display.newText({text = "Submit Step",
											 x = submit_button.x + 0.5*submit_button.width,
											 y = submit_button.y + 0.5*submit_button.height,
											 width = submit_button.width,
											 fontSize = globalData.smallFontSize,
											 align = "center"})
		sceneGroup:insert(submit_text)

		local function submitStep(event)
			if not current_index then 
				current_index = #new_recipe_info.newRecipeSteps + 1 
			else
				table.remove(new_recipe_info.newRecipeSteps, current_index)
			end

 			if steps_text_field.text ~= "" then
	 			table.insert(new_recipe_info.newRecipeSteps, current_index, steps_text_field.text)
	 			steps_text_field.text = ""
	 			native.setKeyboardFocus(nil)
	 			updateStepText()
	 		end

	 		current_index = nil
	 		return true
 		end
 		self.submit_button:addEventListener("tap", submitStep)

		self.erase_button = display.newRect(sceneGroup,
											self.submit_button.x + 0.5*steps_text_field.width, 
											self.submit_button.y,-- + 0.5*steps_text_field.height,
											self.submit_button.width, 
											self.submit_button.height)
		self.erase_button.anchorX = 0
		self.erase_button.anchorY = 0
		-- self.erase_button.fill = {type = "image", filename = "Image Assets/Trash-Graphic.png"}
		self.erase_button:setFillColor(unpack(app_colors.steps.title_bkgd))
		self.erase_button.strokeWidth = 2
		self.erase_button:setStrokeColor(0)

		local erase_button = self.erase_button
		local erase_text = display.newText({text = "Clear Text",
											 x = erase_button.x + 0.5*erase_button.width,
											 y = erase_button.y + 0.5*erase_button.height,
											 width = erase_button.width,
											 fontSize = globalData.smallFontSize,
											 align = "center"})
		sceneGroup:insert(erase_text)

		-- Need to do this after so as not to affect the height value
		self.submit_button.strokeWidth = 2
		self.submit_button:setStrokeColor(0)

		local function clearText(event)
			current_index = nil
 			steps_text_field.text = ""
 			return true
 		end
 		self.erase_button:addEventListener("tap", clearText)

	end
end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		self.submit_button:removeSelf()
		self.erase_button:removeSelf()
		-- timer.cancel(self.update_handle)
		-- Code here runs when the scene is on screen (but is about to go off screen)
 
	elseif ( phase == "did" ) then
		sceneGroup:remove(steps_text_field)
		relocateStepsField(-1000, -1000)

		globalData.lastScene = "InsertStepsPage" 
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