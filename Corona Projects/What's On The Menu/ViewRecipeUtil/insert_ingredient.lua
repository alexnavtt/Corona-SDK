local tinker = require("Tinker")
local params = require("ViewRecipeUtil.view_recipe_shared_params")
local cookbook = require("cookbook")
local app_colors = require("AppColours")

local W = display.contentWidth
local H = display.contentHeight
local cX = display.contentCenterX
local cY = display.contentCenterY

local showUnitCircle = require("ViewRecipeUtil.show_unit_circle")

local function insertIngredient(ingredient, amount, unit, amount_number, ingredient_level, ingredient_level_delta, color)
	local ingredient_group = display.newGroup()
	local scroll_view_width_1 = params.scroll_view_width_1
	local width = 0.9*scroll_view_width_1

	-- Make it look pretty
	for i = 1,#ingredient-2,1 do
		if string.sub(ingredient,i, i) == " " then
			ingredient = ingredient:sub(1,i) .. string.upper(ingredient:sub(i+1,i+1)) .. ingredient:sub(i+2)
		elseif string.sub(ingredient,i, i) == "/" then
			ingredient = ingredient:sub(1,i) .. " " .. ingredient:sub(i+1) 
		end
	end

	-- Still making it look pretty
	ingredient = string.upper(ingredient:sub(1,1)) .. ingredient:sub(2)
	if cookbook.volumes[unit] then 
		unit = string.upper(unit:sub(1,1)) .. unit:sub(2)
	end

	local bkgd = display.newRoundedRect(ingredient_group, 0.05*scroll_view_width_1, ingredient_level, width, 0.6*ingredient_level_delta, 0.1*ingredient_level_delta)
	bkgd:setFillColor(unpack(color))
	bkgd.anchorX = 0

	-- Ingredient Text
	ingredient_text_params = {text = ingredient,
							  x = 0.1*scroll_view_width_1,
							  y = ingredient_level,
							  width = 0.55*scroll_view_width_1,
							  height = 0,
							  font = native.systemFont,
							  fontSize = 0.022*display.contentHeight,
							  align = "left"}
	local ingredient_word = display.newText(ingredient_text_params)
	ingredient_word.anchorX = 0
	ingredient_word:setFillColor(unpack(app_colors.recipe.ing_text))

	while ingredient_word.height > 0.55*ingredient_level_delta do
		ingredient_word.size = 0.9*ingredient_word.size
	end

	-- Strikethrough line
	local strikethrough = display.newGroup()
	local x1 = ingredient_word.x - 0.03*ingredient_word.width
	local x2 = ingredient_word.x + 1.06*ingredient_word.width

	-- Determine if it is a 1 or 2 line ingredient
	if ingredient_word.height < 0.55*bkgd.height then
		local line1 = display.newLine(strikethrough, x1, ingredient_word.y, x2, ingredient_word.y)
	else
		local y1 = ingredient_word.y - 0.25*ingredient_word.height
		local y2 = ingredient_word.y + 0.25*ingredient_word.height
		local line1 = display.newLine(strikethrough, x1, y1, x2, y1)
		local line2 = display.newLine(strikethrough, x1, y2, x2, y2)
	end

	for i = 1,strikethrough.numChildren,1 do
		strikethrough[i].strokeWidth = 2
		strikethrough[i]:setStrokeColor(unpack(app_colors.recipe.ing_text))
	end
	
	ingredient_group:insert(strikethrough)
	strikethrough.alpha = 0

	function bkgd:tap(event)
		strikethrough.alpha = 0.5 - strikethrough.alpha
		ingredient_word.alpha = 1.5 - ingredient_word.alpha
	end
	bkgd:addEventListener("tap", bkgd)

	-- Ingredient Amount Text
	local space = "\n"
	if unit:lower() == "count" then
		unit = ""
		space = ""
	end

	local amount_text_params = {text = amount .. space .. unit,
								x = 0.8*scroll_view_width_1,
								y = ingredient_level,
								width = 0.3*scroll_view_width_1,
								height = 0,
								font = native.systemFont,
								fontSize = 0.02*display.contentHeight,
								align = "center"}
	local ingredient_amount = display.newText(amount_text_params)
	ingredient_amount:setFillColor(unpack(app_colors.recipe.ing_text))
	ingredient_amount.value = amount_number
	ingredient_amount.unit  = unit
	ingredient_amount.food  = ingredient

	if amount == "0" then ingredient_amount.text = "" end

	function ingredient_amount:tap(event)
		if not self.value then
			return true
		end

		showUnitCircle(self.unit, self, self.value, self.food)
		return true
	end
	ingredient_amount:addEventListener("tap", ingredient_amount)

	ingredient_group:insert(ingredient_word)
	ingredient_group:insert(ingredient_amount)

	return ingredient_group
end

return insertIngredient
