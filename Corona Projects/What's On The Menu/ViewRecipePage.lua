local composer = require("composer")
local cookbook = require("cookbook")
local globalData = require("globalData")
local widget = require("widget")
local colors = require("Palette")
local tinker = require("Tinker")
local app_colors = require("AppColours")
local transition = require("transition")
local util = require("GeneralUtility")

local scene = composer.newScene()

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

local options_background
local options
local tapOptions

-----------------------
-- Display Variables --
-----------------------
local page_params = require("ViewRecipeUtil.view_recipe_shared_params")

---------------------
-- Local Functions --
---------------------

local insertIngredient 	= require("ViewRecipeUtil.insert_ingredient")
local insertStep 		= require("ViewRecipeUtil.insert_step")
local createOptions 	= require("ViewRecipeUtil.create_options")


-- /////////////////////////////// --
-- 			SCENE BEGIN			   --
-- /////////////////////////////// --
function scene:create( event )
 
	local sceneGroup = self.view
	local name = event.params.name

	local background = display.newRect(sceneGroup, cX, cY, W, H)
	background:setFillColor(unpack(app_colors.recipe.background))

	self.glass_screen = display.newRect(sceneGroup, cX, cY, W, H)
	self.glass_screen:setFillColor(0)
	self.glass_screen.alpha = 0
	self.glass_screen:toBack()
	self.glass_screen:addEventListener("tap", function(event) self.glass_screen.alpha = 0; options:toggle(); return true end)

	local top_bar = display.newRect(sceneGroup, 0, 0, display.contentWidth, page_params.info_bar_height)
	top_bar.anchorX = 0
	top_bar.anchorY = 0
	top_bar:setFillColor(0)

	local title_background = display.newRect(sceneGroup, 0, page_params.info_bar_height, display.contentWidth, page_params.title_banner_height)
	title_background.anchorX = 0
	title_background.anchorY = 0
	title_background:setFillColor(unpack(app_colors.recipe.title_bkgd))

	self.ingredient_panel = widget.newScrollView({top = page_params.scroll_view_top + page_params.v_spacing, left = page_params.scroll_view_left_1,
											  width = page_params.scroll_view_width_1,
											  height = page_params.scroll_view_height - 2*page_params.v_spacing,
											  horizontalScrollDisabled = true,
											  isBounceEnabled = false,
											  backgroundColor = app_colors.recipe.ing_background,
											  hideBackground = true,
											  bottomPadding = 0.1*display.contentWidth})
	sceneGroup:insert(self.ingredient_panel)

	local ingredient_bkgd = display.newRoundedRect(sceneGroup, self.ingredient_panel.x, self.ingredient_panel.y, self.ingredient_panel.width, self.ingredient_panel.height + 2*page_params.v_spacing, 0.05*W)
	ingredient_bkgd:setFillColor(unpack(app_colors.recipe.ing_background))
	ingredient_bkgd:toBack()

	self.instruction_panel = widget.newScrollView({top = page_params.scroll_view_top + page_params.v_spacing, left = page_params.scroll_view_left_2,
												    width = page_params.scroll_view_width_2,
												    height = page_params.scroll_view_height - 2*page_params.v_spacing,
												    horizontalScrollDisabled = true,
												    isBounceEnabled = false,
												    backgroundColor = app_colors.recipe.step_bkgd,
												    hideBackground = true,
												    bottomPadding = 0.3*display.contentWidth})
	sceneGroup:insert(self.instruction_panel)

	local instruction_bkgd = display.newRoundedRect(sceneGroup, self.instruction_panel.x, self.instruction_panel.y, self.instruction_panel.width, self.instruction_panel.height + 2*page_params.v_spacing, 0.05*W)
	instruction_bkgd:setFillColor(unpack(app_colors.recipe.step_bkgd))
	instruction_bkgd:toBack()

	local back_button = display.newRect(sceneGroup, 0.025*W, 0.5*page_params.info_bar_height, 0.25*W, 0.9*page_params.info_bar_height)
	back_button.anchorX = 0
	back_button.alpha = 0.01

	local back_arrow = display.newImageRect(sceneGroup, "Image Assets/Small-White-Up-Arrow-Graphic.png", 0.6*page_params.info_bar_height, 0.6*page_params.info_bar_height)
	back_arrow.x = back_button.x + 0.6*back_arrow.width
	back_arrow.y = back_button.y
	back_arrow:rotate(270)

	local back_text = display.newText({	text = "Return",
										x = back_arrow.x + back_arrow.width,
										y = back_arrow.y,
										fontSize = globalData.titleFontSize,
										align = "left"})
	back_text.anchorX = 0
	back_text:setFillColor(1)
	sceneGroup:insert(back_text)

	local function goBack(event)
		composer.gotoScene(globalData.activeScene, {effect = "slideLeft", time = globalData.transition_time})
	end
	back_button:addEventListener("tap", goBack)

	-- Options Popout
	local options_icon = display.newGroup()
	sceneGroup:insert(options_icon)

	options_background = display.newRect(options_icon, 0.95*W, 0.5*page_params.info_bar_height, 0.06*W, page_params.info_bar_height)
	options_background.alpha = 0.01

	for i = 1,3,1 do
		local L = display.newLine(options_icon, 0.92*W, i*0.25*page_params.info_bar_height, 0.98*W, i*0.25*page_params.info_bar_height)
		L.strokeWidth = 5
	end

 	background:toBack()
end
 
 
function scene:show( event )
 
	local sceneGroup = self.view
	local phase = event.phase
	local name = event.params.name
	local scaling_factor = math.max(0.25,math.min(event.params.scaling_factor or 1, 4))

	local ingredient_level_delta = page_params.ingredient_level_delta
	local ingredient_level = 0.5*ingredient_level_delta
	local step_level_delta = page_params.step_level_delta
	local step_level = 2*step_level_delta
 
	if ( phase == "will" ) then
		transition.to(globalData.tab_bar, {alpha = 0, time = 0.8*globalData.transition_time})
		local ingredient_group = display.newGroup()
		local step_group = display.newGroup()
		self.recipe_group = display.newGroup()
		self.recipe_group:insert(ingredient_group)
		self.recipe_group:insert(step_group)
		sceneGroup:insert(self.recipe_group)

		-- Section Title Generation --
		title_text_params = {text = event.params.name,
							 x = 0.05*W,
							 y = page_params.info_bar_height + page_params.title_banner_height/2,
							 height = 0,
							 width = 0.7*display.contentWidth,
							 font = native.systemFontBold,
							 fontSize = 0.05*display.contentHeight,
							 align = "left"}
		local title = display.newText(title_text_params)
		title:setFillColor(unpack(app_colors.recipe.title_text))
		title.anchorX = 0
		self.recipe_group:insert(title)

		while title.height > 0.9*page_params.title_banner_height do
			title.size = 0.99*title.size
		end

		local scale_text = display.newText({text = "x" .. cookbook.getFraction(scaling_factor),
											x = title.x + title.width + 0.02*W, y = title.y,
											fontSize = globalData.smallFontSize,
											align = "center"})
		scale_text:setFillColor(unpack(app_colors.recipe.title_text))
		self.recipe_group:insert(scale_text)

		print("view page:")
		print(globalData.active_recipe)

		local ing_colors = {app_colors.recipe.ingredient_1, app_colors.recipe.ingredient_2}
		local i = 0

		local ingredients = globalData.menu[name].ingredients

		-- Sort Ingredients Alphabetically
		local ingredient_names = {}
		for j = 1,#ingredients,1 do
			ingredient_names[ingredients[j].name] = j
		end
		local sorted_ingredients = util.sortTableKeys(ingredient_names)

		-- Insert Each Ingredient 1 by 1
		for j = 1,#sorted_ingredients,1 do
			local table_val = ingredients[ingredient_names[sorted_ingredients[j]]]

			local text_amount = table_val.text_amount
			print("THIS" .. text_amount)
			local amount = table_val.amount

			if scaling_factor ~= 1 then
				if amount then
					amount = amount*scaling_factor
					text_amount = cookbook.getFraction(amount)
				end
			end

			local new_ingredient = insertIngredient(table_val.name, text_amount, table_val.unit, amount, ingredient_level, ingredient_level_delta, ing_colors[i+1])
			self.ingredient_panel:insert(new_ingredient)

			ingredient_level = ingredient_level + ingredient_level_delta
			i = 1 - i
		end


		for index, table_val in pairs(globalData.menu[name].steps) do
			local new_step = insertStep(table_val, step_level, step_level_delta, index)
			self.instruction_panel:insert(new_step)

			step_level = step_level + step_level_delta + new_step.height
		end 


		local bkgd = display.newImageRect("Image Assets/Papyrus-Texture.jpg", display.contentWidth, self.instruction_panel.height)
		bkgd.x = display.contentCenterX
		bkgd.y = self.instruction_panel.y
		sceneGroup:insert(bkgd)
		bkgd:toBack()

	elseif ( phase == "did" ) then
		self.glass_screen:toFront()
		options = createOptions(name, scaling_factor, self)

		function tapOptions(event)
			scene.glass_screen.alpha = 0.5
			return(options:toggle())
		end
		options_background:addEventListener("tap", tapOptions)
 
	end
end
 
 
function scene:hide( event )
 
	local sceneGroup = self.view
	local phase = event.phase
 
	if ( phase == "will" ) then
 
	elseif ( phase == "did" ) then
		for i = 1,self.ingredient_panel._collectorGroup.numChildren,1 do
			self.ingredient_panel:remove(1)
		end

		for i = 1,self.instruction_panel._collectorGroup.numChildren,1 do
			self.instruction_panel:remove(1)
		end

		self.recipe_group:removeSelf()

		options:removeSelf()
		options_background:removeEventListener("tap", tapOptions)
	end
end
 
 
function scene:destroy( event )
 
	local sceneGroup = self.view 
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