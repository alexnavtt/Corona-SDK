local composer = require("composer")
local cookbook = require("cookbook")
local widget   = require("widget")
local globalData = require("globalData")
local tinker = require("Tinker")
local app_colors = require("AppColours")
local new_recipe_info = require("NewRecipeUtil.new_recipe_info")
local tab_bar_util = require("TabBarUtil.tab_bar_util")
local util = require("GeneralUtility")

local scene = composer.newScene()

local Cx = display.contentCenterX
local Cy = display.contentCenterY
local W  = display.contentWidth
local H  = display.contentHeight

-- ############### --
-- LOCAL FUNCTIONS --
-- ############### --

local function updateIngredients()

	for i = 1,scene.ingredient_group.numChildren,1 do
		scene.ingredient_group:remove(1)
	end

	local iter = 1
	for name, value in pairs(new_recipe_info.newRecipeIngredientList) do
		local tag_options = {label = name .. " [" .. value.text_amount .. " " .. value.unit .. "]", strokeWidth = 5, color = app_colors.ingredients.known_ing, labelColor = app_colors.ingredients.known_text, displayGroup = scene.ingredient_group}
		local tag = tinker.newButton(-0.02*display.contentWidth, (0.05 + 0.1*(iter-1))*scene.ingredient_group.height, 0.9*scene.ingredient_group.width, 0.05*scene.ingredient_group.height, tag_options)
		tag.id = name
		tag.anchorX = -0.05*tag.width

		function tag:tap(event)
			print("Ingredient removed: " .. self.id)
			new_recipe_info.newRecipeIngredientList[self.id] = nil
			updateIngredients()
		end
		tag:addEventListener("tap",tag)

		iter = iter + 1
	end
end

local function inputIngredientAmount(name)
	local group = display.newGroup()

	local glass_screen = tinker.glass_screen(false)
	glass_screen:setFillColor(0,0,0,0.4)
	group:insert(glass_screen)

	---- Create Basic GUI ----
	local background = display.newRect(group, Cx, 0.55*H, 0.85*W, 0.72*H)
	background:setFillColor(unpack(app_colors.ingredients.panel_bkgd))

	local ingredient_panel = display.newRect(group, Cx, 0.285*H, 0.8*W, 0.15*H)
	ingredient_panel:setFillColor(unpack(app_colors.ingredients.panel_fore))
	ingredient_panel:setStrokeColor(unpack(app_colors.ingredients.units))
	ingredient_panel.strokeWidth = 3

	local label_params = {label = name, radius = 10000, color = app_colors.ingredients.panel_bkgd, labelColor = app_colors.ingredients.panel_text, displayGroup = group}
	local ingredient_label = tinker.newButton(Cx, ingredient_panel.y - 0.3*ingredient_panel.height, 0.8*ingredient_panel.width, 0.3*ingredient_panel.height, label_params)

	local num_params = {label = "", radius = 10, displayGroup = group, color = app_colors.ingredients.panel_bkgd, labelColor = app_colors.ingredients.panel_text, strokeWidth = 3, strokeColor = app_colors.ingredients.panel_outline, fontSize = globalData.titleFontSize}
	local int = tinker.newButton(Cx - 0.2*ingredient_panel.width, ingredient_panel.y + 0.15*ingredient_panel.height, 0.4*ingredient_panel.height, 0.4*ingredient_panel.height, num_params)
	
	local ampersand = display.newText({text = "&", x = Cx - 0.09*ingredient_panel.width, y = int.y, fontSize = globalData.titleFontSize, align = "center"})
	group:insert(ampersand)

	num_params.strokeWidth = 0
	local num = tinker.newButton(Cx, ingredient_panel.y + 0.01*ingredient_panel.height, 0.22*ingredient_panel.height, 0.22*ingredient_panel.height, num_params)
	local den = tinker.newButton(Cx, ingredient_panel.y + 0.30*ingredient_panel.height, 0.22*ingredient_panel.height, 0.22*ingredient_panel.height, num_params)

	local div_line = display.newLine(group, Cx - 0.03*ingredient_panel.width, ampersand.y, Cx + 0.03*ingredient_panel.width, ampersand.y)
	div_line.strokeWidth = 4

	local unit_params = {label = "cup", radius = 10, displayGroup = group, color = app_colors.ingredients.panel_bkgd, labelColor = app_colors.ingredients.panel_text, strokeColor = app_colors.ingredients.panel_outline}
	local unit_rect = tinker.newButton(Cx + 0.2*ingredient_panel.width, ingredient_panel.y + 0.15*ingredient_panel.height, 0.8*ingredient_panel.height, 0.4*ingredient_panel.height, unit_params)
	----


	---- Add Keyboard And Touch Listeners ----
	local text_rects = {int, num, den}
	local text_objects = {int.label, num.label, den.label}

	local keyboard_params = {X_func = function(event) int:replaceLabel("") end, radius = 100, backgroundColor = app_colors.ingredients.panel_bkgd, keyColor = app_colors.ingredients.key_color}
	local keyboard = tinker.numericKeyboard(Cx, 0.85*display.contentHeight, nil, nil, keyboard_params)
	keyboard.index = 1
	keyboard.anchorY = keyboard.height
	keyboard:attachTextObject(int.label)

	local function limitDigits(event)
		if #int.label.text > 3 then
			int:replaceLabel(int.label.text:sub(1,3))
			print("stopped")
		end

		if #num.label.text > 1 then
			num:replaceLabel(num.label.text:sub(1,1))
			print("too big")
		end

		if #den.label.text > 1 then
			den:replaceLabel(den.label.text:sub(1,1))
		end
	end
	keyboard._glass_screen:addEventListener("tap", limitDigits)

	local function thisField(index)
		for i = 1,3,1 do
			text_rects[i]:setStrokeWidth(0)
		end
		text_rects[index]:setStrokeWidth(4)

		keyboard.index = index
		keyboard:attachTextObject(text_objects[keyboard.index])
		keyboard._glass_screen:addEventListener("tap", limitDigits)
		keyboard:setXFunc(function(event) text_rects[keyboard.index]:replaceLabel("") end)
	end

	local function nextField(event)
		if keyboard.index < 3 then
			keyboard.index = keyboard.index + 1
			thisField(keyboard.index)
		end
	end
	keyboard:setOFunc(nextField)

	int:addEventListener("tap", function(event) thisField(1) end)
	num:addEventListener("tap", function(event) thisField(2) end)
	den:addEventListener("tap", function(event) thisField(3) end)

	group:insert(keyboard)
	----


	---- Create Unit Tab Bar ----
	local unit_group = display.newGroup()
	local left_x = ingredient_panel.x - 0.5*ingredient_panel.width
	local upper_count = math.ceil(#cookbook.essential_units/2)
	local lower_count = math.floor(#cookbook.essential_units/2)
	local total_count = upper_count + lower_count

	-- Upper Bar
	for i = 1,upper_count,1 do
		local new_unit_rect = display.newRect(unit_group, left_x, ingredient_panel.y + 0.625*ingredient_panel.height, (1/upper_count)*ingredient_panel.width, 0.35*ingredient_panel.height)
		new_unit_rect:setFillColor(unpack(app_colors.ingredients.units))
		new_unit_rect:setStrokeColor(unpack(app_colors.ingredients.panel_bkgd))
		new_unit_rect.anchorX = 0
		new_unit_rect.strokeWidth = 2

		local new_unit_text = display.newText({text = cookbook.essential_units[i], x = left_x + 0.5*new_unit_rect.width, y = new_unit_rect.y, width = new_unit_rect.width, fontSize = globalData.smallFontSize, align = "center"})
		new_unit_text:setFillColor(unpack(app_colors.ingredients.panel_text))
		unit_group:insert(new_unit_text)

		function new_unit_rect:tap(event)
			unit_rect:replaceLabel(new_unit_text.text)
		end
		new_unit_rect:addEventListener("tap", new_unit_rect)

		left_x = left_x + (1/upper_count)*ingredient_panel.width
	end

	left_x = ingredient_panel.x - 0.5*ingredient_panel.width

	-- Lower Bar
	for i = upper_count+1,total_count,1 do
		local new_unit_rect = display.newRect(unit_group, left_x, ingredient_panel.y + 0.955*ingredient_panel.height, (1/lower_count)*ingredient_panel.width, 0.35*ingredient_panel.height)
		new_unit_rect:setFillColor(unpack(app_colors.ingredients.units))
		new_unit_rect:setStrokeColor(unpack(app_colors.ingredients.panel_bkgd))
		new_unit_rect.anchorX = 0
		new_unit_rect.strokeWidth = 2

		local new_unit_text = display.newText({text = cookbook.essential_units[i], x = left_x + 0.5*new_unit_rect.width, y = new_unit_rect.y, width = new_unit_rect.width, fontSize = globalData.smallFontSize, align = "center"})
		new_unit_text:setFillColor(unpack(app_colors.ingredients.panel_text))
		unit_group:insert(new_unit_text)

		function new_unit_rect:tap(event)
			unit_rect:replaceLabel(new_unit_text.text)
		end
		new_unit_rect:addEventListener("tap", new_unit_rect)

		left_x = left_x + (1/lower_count)*ingredient_panel.width
	end
	group:insert(unit_group)
	----


	---- Add Submit And Cancel Buttons ----
	local submit_button = tinker.newButton(background.x + background.width/2, background.y + background.height/2, 0.498*background.width, 0.1*background.height,
											{label = "Submit", displayGroup = group, labelColor = 1,  color = app_colors.ingredients.confirm_button})
	submit_button.anchorX = submit_button.width
	submit_button.anchorY = submit_button.height

	function submit_button:tap(event)
		local int_amount = tonumber(int.label.text) or 0
		local num_amount = tonumber(num.label.text) or 0
		local den_amount = tonumber(den.label.text) or 1
		local den_amount = math.max(den_amount,1)

		if int.label.text == "" then int.label.text = "0" end
		if num.label.text == "" then num.label.text = "0" end
		if den.label.text == "" then den.label.text = "1" end
		if den.label.text == "0" then den.label.text = "1" end

		local text_amount
		if int_amount == 0 and num_amount == 0 then
			text_amount = "0"

		elseif int_amount == 0 and den_amount == 1 then
			text_amount = num.label.text

		elseif int_amount == 0 then
			text_amount = num.label.text .. "/" .. den.label.text

		elseif num_amount == 0 then
			text_amount = int.label.text 

		else
			text_amount = int.label.text .. " " .. num.label.text .. "/" .. den.label.text
		end

		new_recipe_info.newRecipeIngredientList[name] = {amount = int_amount + num_amount/den_amount, unit = unit_rect.text, text_amount = text_amount}
		updateIngredients()
		group:removeSelf()
	end
	submit_button:addEventListener("tap", submit_button)

	local cancel_button = tinker.newButton(background.x - background.width/2, background.y + background.height/2, 0.498*background.width, 0.1*background.height,
											{label = "Cancel", displayGroup = group, labelColor = 1, color = app_colors.ingredients.confirm_button})
	cancel_button.anchorX = 0
	cancel_button.anchorY = submit_button.height

	function cancel_button:tap(event)
		updateIngredients()
		group:removeSelf()
		return true
	end
	cancel_button:addEventListener("tap", cancel_button)
	----

	return group
end


-- ############ --
-- SCENE EVENTS --
-- ############ --
function scene:create( event )
 
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor(unpack(app_colors.ingredients.search_bkgd))

	function background:tap(event) native.setKeyboardFocus(nil) end
	background:addEventListener("tap", background)

	local tab_bar = tab_bar_util.simpleTabBar("Ingredient Selection", "Back to Title", "NewRecipePage", "Input Steps", "InsertStepsPage")
	sceneGroup:insert(tab_bar)

	local sb_options = {defaultText = "Search Ingredients...", radius = 0.025*display.contentHeight, tapOutside = false}
	local search_bar = tinker.newTextField(display.contentCenterX, 2.5*tab_bar_util.tab_height, 0.8*display.contentWidth, 0.05*display.contentHeight, sb_options)
	sceneGroup:insert(search_bar)

	self.results_group = widget.newScrollView({	left = display.contentCenterX, 
												top  = 0.2*display.contentHeight,
												width  = 0.5*display.contentWidth,
												height = 0.8*display.contentHeight,
												backgroundColor = app_colors.ingredients.option_bkgd,
												friction = 1.2,
												horizontalScrollDisabled = true,
												hideScrollBar = true,
												bottomPadding = 0.1*display.contentHeight})

	sceneGroup:insert(self.results_group)

	local function searchResults(event)
		if event.phase == "editing" then
			for i = 1,self.results_group._collectorGroup.numChildren,1 do
				self.results_group:remove(1)
			end

			local options = util.sortTableKeys(cookbook.searchIngredients(search_bar.text))
			local iter = 1
			for i = 1,#options,1 do
				if new_recipe_info.newRecipeIngredientList[options[iter]] then
					table.remove(options,iter)
				else
					iter = iter + 1
				end
			end

			-- Custom ingredient label
			if search_bar.text ~= "" then
				local tag_options = {label = search_bar.text, strokeWidth = 5, color = app_colors.ingredients.option_ing, labelColor = app_colors.ingredients.option_text}
				local tag = tinker.newButton(self.results_group.width, 0.05*self.results_group.height, 0.9*self.results_group.width, 0.05*self.results_group.height, tag_options)
				tag.id = search_bar.text
				tag.anchorX = tag.width
				self.results_group:insert(tag)

				function tag:tap(event)
					print("Created from scratch")
					for i = 1,scene.results_group._collectorGroup.numChildren,1 do
						scene.results_group:remove(1)
					end

					local input_group = inputIngredientAmount(search_bar.text)
					input_group:translate(0,-100)

					search_bar:replaceText("")
					native.setKeyboardFocus(nil)
					print("Hidden")

					return true
				end
				tag:addEventListener("tap", tag)
			end

			-- Built in ingredients
			for i = 1,#options,1 do
				local tag_options = {label = options[i], strokeWidth = 5, color = app_colors.ingredients.option_ing, labelColor = app_colors.ingredients.option_text}
				local tag = tinker.newButton(self.results_group.width, (0.05 + i*0.1)*self.results_group.height, 0.9*self.results_group.width, 0.05*self.results_group.height, tag_options)
				tag.id = options[i]
				tag.anchorX = tag.width
				self.results_group:insert(tag)

				function tag:tap(event)
					-- local newIngredient = {amount = 0, unit = "cup", text_amount = "0"}
					-- new_recipe_info.newRecipeIngredientList[options[i]] = newIngredient
					search_bar:replaceText("")

					for i = 1,scene.results_group._collectorGroup.numChildren,1 do
						scene.results_group:remove(1)
					end

					local input_group = inputIngredientAmount(options[i])
					input_group:translate(0,-100)

					native.setKeyboardFocus(nil)

					return true
				end
				tag:addEventListener("tap", tag)
			end
		end

		if event.phase == "submitted" then
			native.setKeyboardFocus(nil)
		end
	end
	search_bar:addEventListener("userInput", searchResults)


	self.ingredient_group = widget.newScrollView({	x = 0.5*display.contentCenterX,
													y = self.results_group.y,
													width = 0.5*display.contentWidth,
													height = self.results_group.height,
													backgroundColor = app_colors.ingredients.known_bkgd,
													horizontalScrollDisabled = true,
													hideScrollBar = true,
													bottomPadding = 0.1*display.contentHeight})
	sceneGroup:insert(self.ingredient_group)

	-- self.timerHandle = timer.performWithDelay(250, updateIngredients, -1)

	local div_line_1 = display.newLine(sceneGroup, 0, 0.2*display.contentHeight, display.contentWidth, 0.2*display.contentHeight)
	div_line_1:setStrokeColor(unpack(app_colors.ingredients.outline))
	div_line_1.strokeWidth = 3

	local div_line_2 = display.newLine(sceneGroup, display.contentCenterX, 0.2*display.contentHeight, display.contentCenterX, display.contentHeight)
	div_line_2:setStrokeColor(unpack(app_colors.ingredients.outline))
	div_line_2.strokeWidth = 3
end
 

function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		transition.to(globalData.tab_bar, {alpha = 0, time = globalData.transition_time})
		updateIngredients()
		-- timer.resume(self.timerHandle)
		-- sceneGroup:insert(input_group)
		-- Code here runs when the scene is still off screen (but is about to come on screen)
 
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
 
	end
end

function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
 
	elseif ( phase == "did" ) then
		-- timer.pause(self.timerHandle)
		-- Code here runs immediately after the scene goes entirely off screen
 
	end
end

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