-- Solar2D includes
local composer = require("composer")
local widget   = require("widget")
local transition = require("transition")

-- App includes
local globalData = require("globalData")
local app_colors = require("AppColours")
local cookbook   = require("cookbook")
local util       = require("GeneralUtility")
local app_transitions = require("AppTransitions")

-- Page includes
local view_recipe_params = require("ViewRecipeUtil.view_recipe_shared_params")
local insertIngredient   = require("ViewRecipeUtil.insert_ingredient")
local insertStep 	 	 = require("ViewRecipeUtil.insert_step")
local page_params = view_recipe_params.landscape

local scene = composer.newScene()

-- Extract params variables
local info_bar_height     = page_params.info_bar_height
local title_banner_height = page_params.title_banner_height
local vertical_spacing    = page_params.v_spacing
local horizontal_spacing  = page_params.h_spacing
local ingredient_spacing  = page_params.ingredient_level_delta
local step_spacing        = page_params.step_level_delta
local ingredient_view_width = page_params.scroll_view_width_1
local step_view_width       = page_params.scroll_view_width_2

-- Extract Color Info
local page_background_color       = app_colors.recipe.background
local title_banner_color          = app_colors.recipe.title_bkgd
local ingredient_background_color = app_colors.recipe.ing_background
local step_background_color       = app_colors.recipe.step_bkgd

-- Device display variables
local Cx = display.contentCenterX
local Cy = display.contentCenterY
local W  = display.contentWidth
local H  = display.contentHeight 
local page_height = W - title_banner_height -- page height (the height of the meat of the page)


 
-- create()
function scene:create( event )
 
	local sceneGroup = self.view
	local ingredient_count = #globalData.menu[event.params.name].ingredients
	local excess_ingredients = math.max(ingredient_count - 8, 0)

	local background = display.newRect(sceneGroup, Cx, Cy, W, H)
	background:setFillColor(unpack(page_background_color))

	local title_background = display.newRect(sceneGroup, W, 0, display.contentHeight, title_banner_height)
	title_background.anchorX = 0
	title_background.anchorY = 0
	title_background:setFillColor(unpack(title_banner_color))
	title_background:rotate(90)

	self.ingredient_panel = widget.newScrollView({x = page_height/2, y = horizontal_spacing,
											 	  width = page_height - 4*vertical_spacing,
											 	  height = ingredient_view_width - horizontal_spacing,
											 	  verticalScrollDisabled = true,
											 	  isBounceEnabled = false,
											  	  backgroundColor = ingredient_background_color,
											 	  hideBackground = true,
											 	  leftPadding = excess_ingredients*0.07*page_height})
	self.ingredient_panel.anchorY = 0
	sceneGroup:insert(self.ingredient_panel)

	local ingredient_bkgd = display.newRoundedRect(sceneGroup, self.ingredient_panel.x, self.ingredient_panel.y, self.ingredient_panel.width + 2*vertical_spacing, self.ingredient_panel.height, 0.05*W)
	ingredient_bkgd.anchorY = 0
	ingredient_bkgd:setFillColor(unpack(app_colors.recipe.ing_background))
	ingredient_bkgd:toBack()

	local step_count = #globalData.menu[event.params.name].steps

	self.instruction_panel = widget.newScrollView({ x = self.ingredient_panel.x,
													y = self.ingredient_panel.y + self.ingredient_panel.height + 0.01*H,
												    width = self.ingredient_panel.width,
												    height = step_view_width - horizontal_spacing,
												    verticalScrollDisabled = true,
												    isBounceEnabled = false,
												    backgroundColor = step_background_color,
												    hideBackground = true})
	self.instruction_panel.anchorY = 0
	sceneGroup:insert(self.instruction_panel)

	local instruction_bkgd = display.newRoundedRect(sceneGroup, self.instruction_panel.x, self.instruction_panel.y, self.instruction_panel.width + 2*vertical_spacing, self.instruction_panel.height, 0.05*W)
	instruction_bkgd.anchorY = 0
	instruction_bkgd:setFillColor(unpack(app_colors.recipe.step_bkgd))
	instruction_bkgd:toBack()

	local back_button = display.newRect(sceneGroup, W - 0.5*title_banner_height, 0.025*H, 0.25*W, 0.9*title_banner_height)
	back_button.anchorX = 0
	back_button.alpha = 0.01
	back_button:rotate(90)

	local back_arrow = display.newImageRect(sceneGroup, "Image Assets/Small-White-Up-Arrow-Graphic.png", 0.6*title_banner_height, 0.6*title_banner_height)
	back_arrow.x = back_button.x
	back_arrow.y = back_button.y + 0.6*back_arrow.width

	local back_text = display.newText({	text = "Return",
										x = back_arrow.x,
										y = back_arrow.y + back_arrow.width,
										fontSize = globalData.titleFontSize,
										align = "left"})
	back_text.anchorX = 0
	back_text:setFillColor(1)
	back_text:rotate(90)
	sceneGroup:insert(back_text)

	local function goBack(event)
		app_transitions.moveTo(globalData.activeScene)
	end
	back_button:addEventListener("tap", goBack)

	-- Options Popout
	local options_icon = display.newGroup()
	sceneGroup:insert(options_icon)

	options_background = display.newRect(options_icon, W - 0.5*title_banner_height, 0.95*H, 0.06*W, title_banner_height)
	options_background.alpha = 0.01

	for i = 1,3,1 do
		local L = display.newLine(options_icon, W - i*0.25*title_banner_height, 0.94*H, W - i*0.25*title_banner_height, 0.98*H)
		L.strokeWidth = 5
	end

 	background:toBack()
end
 
 
-- show()
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
	local name = event.params.name
	local scaling_factor = math.max(0.25,math.min(event.params.scaling_factor or 1, 4))

	local ingredient_level_delta = ingredient_spacing
	local ingredient_level = ingredient_level_delta
	local step_level_delta = step_spacing
	local step_level = 2*step_level_delta
 
	if ( phase == "will" ) then
		transition.to(globalData.tab_bar, {alpha = 0, time = 0.8*globalData.transition_time})
		self.recipe_group = display.newGroup()
		sceneGroup:insert(self.recipe_group)

		-- Section Title Generation --
		title_text_params = {text = event.params.name,
							 x = W - title_banner_height/2,
							 y = 0.5*page_height,
							 height = 0,
							 width = 0.7*display.contentWidth,
							 font = native.systemFontBold,
							 fontSize = 0.05*display.contentHeight,
							 align = "left"}
		local title = display.newText(title_text_params)
		title:setFillColor(unpack(app_colors.recipe.title_text))
		title.anchorX = 0
		title:rotate(90)
		self.recipe_group:insert(title)

		-- Resize title if it's too big
		while title.height > 0.9*title_banner_height do
			title.size = 0.99*title.size
		end

		-- Show the recipe multiplication factor
		local scale_text = display.newText({text = "x" .. cookbook.getFraction(scaling_factor),
											x = title.x, y = title.y + 1.05*title.width,
											fontSize = globalData.smallFontSize,
											align = "center"})
		scale_text:setFillColor(unpack(app_colors.recipe.title_text))
		scale_text:rotate(90)
		self.recipe_group:insert(scale_text)

		-- Retrieve the ingredients for this recipe
		local ing_colors = {app_colors.recipe.ingredient_1, app_colors.recipe.ingredient_2}
		local i = 0

		local ingredients = globalData.menu[name].ingredients

		-- Sort Ingredients Alphabetically
		local ingredient_names = {}
		for j = 1,#ingredients,1 do
			ingredient_names[ingredients[j].name] = j
		end
		local sorted_ingredients = util.sortTableKeys(ingredient_names)
		local ingredient_count   = #sorted_ingredients

		-- Insert Each Ingredient 1 by 1
		local testGroup = display.newGroup()
		local side = "left"
		for j = 1,ingredient_count,1 do
			local table_val = ingredients[ingredient_names[sorted_ingredients[j]]]

			local text_amount = table_val.text_amount
			local amount = table_val.amount

			if scaling_factor ~= 1 then
				if amount then
					amount = amount*scaling_factor
					text_amount = cookbook.getFraction(amount)
				end
			end

			local new_ingredient = insertIngredient(table_val.name, text_amount, table_val.unit, amount, ingredient_level_delta, ing_colors[i+1], page_params)
			new_ingredient.x = 0.03*ingredient_view_width
			new_ingredient.y = ingredient_level
			testGroup:insert(new_ingredient)

			-- Manage placement in two rows
			if side == "right" then
				side = "left"

				new_ingredient.x = 0.51*ingredient_view_width
				ingredient_level = ingredient_level + ingredient_level_delta
				i = 1 - i
			else
				side = "right"
			end
		end

		-- Situate the ingredients properly in the scroll view
		testGroup:rotate(90)
		if testGroup.height < self.ingredient_panel.width then 
			testGroup:translate(self.ingredient_panel.width + 0.5*ingredient_level_delta, 0)
			self.ingredient_panel:setIsLocked(true)
			self.ingredient_panel:insert(testGroup)
		else
			self.ingredient_panel:insert(testGroup)
			testGroup:translate(testGroup.height + 0.5*ingredient_level_delta, 0)
			self.ingredient_panel:setScrollWidth(testGroup.height)
			self.ingredient_panel:scrollToPosition({time = 0, x = -(testGroup.height - self.ingredient_panel.width)})
		end



		-- Insert each step 1 by 1
		local step_1 = {x = 0}
		for index = 1,#globalData.menu[name].steps,1 do
			local table_val = globalData.menu[name].steps[index]
			local new_step = insertStep(table_val, step_level_delta, index, page_params)
			for i = 1,self.instruction_panel._collectorGroup.numChildren,1 do 
				local thing = self.instruction_panel._collectorGroup[i]
				thing.x = thing.x + 2*step_level_delta + new_step.height
			end
			new_step.x = new_step.height
			new_step.y = 0.05*step_view_width
			new_step:rotate(90)
			self.instruction_panel:insert(new_step)

			if index == 1 then step_1 = new_step end

			step_level = step_level + 2*step_level_delta + new_step.height
		end 
		-- self.instruction_panel:setScrollWidth(step_level + 4*step_level_delta)
		self.instruction_panel:setScrollWidth(step_1.x + 1.5*step_spacing)
		self.instruction_panel:scrollToPosition({time = 0, x = -step_1.x + page_height - 6.5*step_spacing})

	elseif ( phase == "did" ) then
 
	end
end
 
 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "did" ) then
		composer.removeScene('ViewLandscapeRecipe')

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