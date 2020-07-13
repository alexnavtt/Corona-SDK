local composer = require("composer")
local cookbook = require("cookbook")
local widget = require("widget")
local globalData = require("globalData")
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function finalizeRecipe(event)
	local recipe_title
	if not globalData.menu[cookbook.newRecipeTitle] then
		recipe_title = cookbook.newRecipeTitle
	else
		for i = 1,10000,1 do
			if not globalData.menu[cookbook.newRecipeTitle .. " " .. i] then
				recipe_title = cookbook.newRecipeTitle .. " " .. i
				break
			end
		end
	end

	globalData.menu[recipe_title] = {ingredients = {}, steps = {}}

	for ingredient_name, values in pairs(cookbook.newRecipeIngredientList) do
		table.insert(globalData.menu[recipe_title].ingredients, {name = ingredient_name, amount = values.amount, unit = values.unit, text_amount = values.text_amount})
		print("Added Ingredient:\n\tName: " .. ingredient_name .. "\n\tAmount: " .. values.amount .. "\n\tUnit: " .. values.unit .. "\n\tText Amount " .. values.text_amount)
	end

	for index, step_text in pairs(cookbook.newRecipeSteps) do
		table.insert(globalData.menu[recipe_title].steps, step_text)
		print("Added step: " .. step_text)
	end

	cookbook.newRecipeIngredients = {}
	cookbook.newRecipeSteps = {}

	globalData.writeCustomMenu()

	globalData.activeScene = 'BrowsePage'
	composer.gotoScene('BrowsePage')
	composer.removeScene('NewRecipePage')
end

local function stepFieldInputListener(event)

 	if event.phase == "editing" then
 		local STR = string.format("%q",globalData.steps_text_field.text)
 		print(STR)
 		print(#STR)
 		-- for i = 1,#STR,1 do
 		if STR:sub(#STR-4,#STR-2) == "\\r\\" then
 			table.insert(cookbook.newRecipeSteps, globalData.steps_text_field.text)
 			globalData.steps_text_field.text = ""
 			scene.glass_screen:toBack()
 			native.setKeyboardFocus(nil)
 		end

 		print("Want to be equal:")
 		print(STR:sub(#STR-4,#STR-1))
 		print("\\r\\")
	 	-- end

 		-- print(string.format("%q","\r" ))
 	end
end

globalData.steps_text_field:addEventListener("userInput", stepFieldInputListener)
 
local function updateStepText(event)

 	local non_indented_x = 0.05*display.contentWidth
 	local indented_x = 1.5*non_indented_x
 	local Y = 0.05*(display.contentHeight - globalData.tab_height)
 	local dY = Y

 	for i = 1,scene.steps_scroll_view._collectorGroup.numChildren,1 do
 		scene.steps_scroll_view:remove(1)
 	end

 	for i = 1,#cookbook.newRecipeSteps,1 do
 		local trash_step = display.newRect(	display.contentWidth - indented_x,
 											Y,
 											2*globalData.titleFontSize,
 											2*globalData.titleFontSize)
 		trash_step.anchorY = 0
 		trash_step.fill = {type = "image", filename = "Image Assets/Trash-Graphic-Simple.png"}
 		scene.steps_scroll_view:insert(trash_step)

 		function trash_step:tap(event)
 			for j = 1,#cookbook.newRecipeSteps,1 do
 				if j > i then
 					cookbook.newRecipeSteps[j-1] = cookbook.newRecipeSteps[j]
 				end
 			end
 			cookbook.newRecipeSteps[#cookbook.newRecipeSteps] = nil
 			print("tapped " .. i)
 			return true
 		end
 		trash_step:addEventListener("tap", trash_step)

 		local title = display.newText( {text = "Step " .. i,
 										x = non_indented_x,
 										y = Y,
 										width = display.contentWidth,
 										height = 0,
 										font = native.systemFontBold,
 										fontSize = globalData.titleFontSize,
 										align = "left"})
 		title:setFillColor(unpack(globalData.dark_text_color))
 		title.anchorX = 0
 		title.id = 'Step Title ' .. i
 		scene.steps_scroll_view:insert(title)

 		Y = Y + 0.5*dY

 		local step = display.newText({text = cookbook.newRecipeSteps[i],
 									  x = indented_x,
 									  y = Y,
 									  width = 0.8*display.contentWidth,
 									  height = 0,
 									  fontSize = globalData.titleFontSize,
 									  align = "left"})
 		step:setFillColor(unpack(globalData.dark_text_color))
 		step.anchorX = 0
 		step.anchorY = 0
 		step.id = "Step " .. i
 		scene.steps_scroll_view:insert(step)

 		Y = Y + dY + step.height
 	end

end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view

	-- BACKGROUND GROUP DEFINITION
	self.back_group = display.newContainer(sceneGroup, display.contentWidth, (display.contentHeight - globalData.tab_height))
 	self.back_group.y = globalData.tab_height + 0.5*(display.contentHeight - globalData.tab_height)
 	self.back_group.x = display.contentCenterX

 	local backgroud = display.newRect(self.back_group, display.contentCenterX, 0, 2*display.contentWidth, self.back_group.height)
 	backgroud:setFillColor(unpack(globalData.dark_grey))

 	local insert_step_text = display.newText({text = "Insert Your Instructions Here",
 											  x = 0,
 											  y = -0.475*self.back_group.height,
 											  width = display.contentWidth,
 											  font = native.systemFontBold,
 											  fontSize = globalData.titleFontSize,
 											  align = "center"})
 	insert_step_text:setFillColor(unpack(globalData.light_text_color))
 	-- insert_step_text:setFillColor(0)
 	self.back_group:insert(insert_step_text)


	-- TAB GROUP DEFINITION
 	local tempTabGroup = display.newGroup()
 	sceneGroup:insert(tempTabGroup)

 	local temp_tab = display.newRect(tempTabGroup, display.contentCenterX, 0.5*globalData.tab_height, display.contentWidth, globalData.tab_height)
 	temp_tab:setFillColor(unpack(globalData.tab_color))
 	temp_tab.strokeWidth = 2
 	temp_tab:setStrokeColor(unpack(globalData.dark_grey))

 	local back_button = display.newRoundedRect(tempTabGroup, 0.2*display.contentWidth, 0.5*temp_tab.height, 0.37*display.contentWidth, 0.9*temp_tab.height, 0.1*temp_tab.height)
 	back_button:setFillColor(unpack(globalData.tab_color))
 	back_button:setStrokeColor(unpack(globalData.dark_grey))
 	back_button.strokeWidth = 2

 	local back_text = display.newText({text = "Back to Measurement Selection", x = back_button.x, y = back_button.y, width = back_button.width, fontSize = globalData.smallFontSize, align = "center"})
 	tempTabGroup:insert(back_text)
 	back_text:setFillColor(unpack(globalData.blue))

 	local forward_button = display.newRoundedRect(tempTabGroup, display.contentWidth - back_button.x, back_button.y, back_button.width, back_button.height, 0.1*temp_tab.height)
 	forward_button:setFillColor(unpack(globalData.tab_color))
 	forward_button:setStrokeColor(unpack(globalData.dark_grey))
 	forward_button.strokeWidth = 2

 	local forward_text = display.newText({text = "Finish", x = forward_button.x, y = forward_button.y, width = forward_button.width, fontSize = globalData.smallFontSize, align = "center"})
 	tempTabGroup:insert(forward_text)
 	forward_text:setFillColor(unpack(globalData.blue))

 	forward_button:addEventListener("tap", finalizeRecipe)

 	function back_button:tap(event)
 		composer.gotoScene("MeasurementPage")
 	end
 	back_button:addEventListener("tap", back_button) 

 	local options = {left = -display.contentCenterX, top = -0.2*self.back_group.height, 
					 width = display.contentWidth, height = 0.7*(display.contentHeight - globalData.tab_height),
					 horizontalScrollDisabled = true, 
					 isBounceEnabled = false,
					 backgroundColor = globalData.background_color,
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
		globalData.relocateSearchBar(-500,-500)
		self.update_handle = timer.performWithDelay(100, updateStepText, -1)
		-- Code here runs when the scene is still off screen (but is about to come on screen)
 
	elseif ( phase == "did" ) then
		globalData.relocateStepsField(unpack(globalData.steps_field_home)) 
		self.submit_button = display.newRect(sceneGroup, 
										  globalData.steps_text_field.x, 
										  globalData.steps_text_field.y + 0.5*globalData.steps_text_field.height,
										  0.5*globalData.steps_text_field.width,
										  0.5*(display.contentHeight - globalData.tab_height - self.steps_scroll_view.height - globalData.steps_text_field.height))
		self.submit_button.anchorX = 0
		self.submit_button.anchorY = 0
		self.submit_button:setFillColor(unpack(globalData.dark_grey))
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
 			if globalData.steps_text_field.text ~= "" then
	 			table.insert(cookbook.newRecipeSteps, globalData.steps_text_field.text)
	 			globalData.steps_text_field.text = ""
	 			native.setKeyboardFocus(nil)
	 		end
	 		return true
 		end
 		self.submit_button:addEventListener("tap", submitStep)

		self.erase_button = display.newRect(sceneGroup,
											self.submit_button.x + 0.5*globalData.steps_text_field.width, 
											self.submit_button.y,-- + 0.5*globalData.steps_text_field.height,
											self.submit_button.width, 
											self.submit_button.height)
		self.erase_button.anchorX = 0
		self.erase_button.anchorY = 0
		-- self.erase_button.fill = {type = "image", filename = "Image Assets/Trash-Graphic.png"}
		self.erase_button:setFillColor(unpack(globalData.dark_grey))
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
 			globalData.steps_text_field.text = ""
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
		-- Code here runs when the scene is on screen (but is about to go off screen)
 
	elseif ( phase == "did" ) then
		globalData.relocateStepsField(-500, -500)
		self.submit_button:removeSelf()
		self.erase_button:removeSelf()
		timer.cancel(self.update_handle)
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