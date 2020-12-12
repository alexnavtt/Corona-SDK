local p = require("Palette")
local colors = {}

colors.scheme = "light" -- determines if to use white or black icons

function colors.setColors()
	colors.browse = 
	{
		panel_1			= colors.dark_color,
		panel_2 		= colors.medium_color,
		recipe_title 	= p.white,
		recipe_info 	= p.white,
		background 		= colors.contrast_color
	}

	colors.new_recipe = 
	{
		background 		= colors.dark_color,
		info_bar 		= colors.light_color,
		info_text		= p.black,
		start_button 	= colors.medium_color,
		start_text 		= p.black,
		title 			= p.white,
		outline 		= p.black
	}

	colors.tab_bar = 
	{
		background 		= p.black,
		selected 		= colors.medium_color,
		outline 		= p.black,
		button 			= colors.dark_color,
		button_text 	= p.white,
		title 			= p.black,
		search_text		= p.black,
		search_bkgd 	= colors.contrast_color
	}

	colors.settings = 
	{
		background 		= colors.dark_color,
		text 			= p.white,
		color_border 	= colors.contrast_color
	}

	colors.ingredients = 
	{
		search_bkgd 	= colors.medium_color,
		known_bkgd 		= colors.light_color,
		option_bkgd 	= colors.dark_color,
		known_ing 		= colors.contrast_color,
		option_ing 		= colors.contrast_color,
		known_text 		= p.white,
		option_text 	= p.white,
		outline 		= p.black,
		panel_bkgd 		= colors.dark_color,
		panel_fore 		= colors.medium_color,
		panel_text 		= p.white,
		key_color 		= colors.medium_color,
		units 			= p.black,
		panel_outline	= p.white,
		confirm_button 	= colors.contrast_color
	}

	colors.steps = 
	{
		title_bkgd		= colors.medium_color,
		title_text 		= p.white,
		step_text 		= p.white,
		background 		= colors.dark_color
	}

	colors.recipe = 
	{
		title_bkgd 		= colors.contrast_color,
		title_text 		= p.darken(p.dark.grey),
		back_text 		= p.white,
		star_button 	= colors.dark_color,
		ingredient_1 	= colors.medium_color,
		ingredient_2 	= colors.dark_color,
		step_bkgd 		= colors.light_color,
		ing_background 	= colors.light_color,
		ing_text 		= p.white,
		step_text 		= p.black,
		outline 		= p.black,
		measure_buttons	= colors.medium_color,
		background 		= colors.dark_color
	}
end

function colors.changeTo(color)

	-- Set the colours
	if color == "blue" then
		colors.light_color 	  = p.sky_blue
		colors.dark_color     = p.mix(p.dark.blue, p.blue, 0.7)
		colors.medium_color   = p.darken(p.deep_sky_blue,3)
		colors.contrast_color = p.dark.orange

		colors.setColors()

		colors.scheme = "dark"

	elseif color == "red" then
		colors.light_color 	  = p.grey_pink
		colors.medium_color   = p.burgundy
		colors.dark_color 	  = p.darken(p.dark.red,4)
		colors.contrast_color = p.dark.blue

		colors.setColors()

		colors.scheme = "dark"

	elseif color == "light" then
		colors.light_color 	  = p.darken(p.off_white)
		colors.dark_color     = p.darken(p.steel_blue)
		colors.medium_color   = p.darken(p.light.purple,3)
		colors.contrast_color = p.mellow_yellow

		colors.setColors()

		colors.scheme = "light"

	elseif color == "dark" then
		colors.light_color 	  = p.darken(p.dark.violet)
		colors.dark_color     = p.darken(p.dark.grey,3)
		colors.medium_color   = p.darken(p.midnight_blue,2)
		colors.contrast_color = p.darken(p.magenta,4)

		colors.setColors()

		colors.recipe.title_text = p.white

		colors.scheme = "dark"

	elseif color == "bright" then
		colors.light_color 	= p.cyber_yellow
		colors.medium_color = p.orange_red
		colors.dark_color 	= p.crimson
		colors.contrast_color = p.light_sea_green

		colors.setColors()

		colors.scheme = "dark"
	end

	-- Set text colors to be visible
	if colors.scheme == "light" then
		colors.recipe.step_text = p.black
		colors.recipe.ing_text 	= p.black
		colors.recipe.back_text = p.black

		colors.browse.recipe_title = {0.2}
		colors.browse.recipe_info = p.black

		colors.new_recipe.title = {0.2}
		colors.new_recipe.info_bar = p.light.grey

		colors.settings.text = {0.2}

		-- colors.tab_bar.button_text = p.black

		colors.steps.step_text = p.black

	elseif colors.scheme == "dark" then
		colors.recipe.step_text = p.white
		colors.recipe.ing_text 	= p.white
		colors.recipe.back_text = p.white

		colors.browse.recipe_title 	= p.white
		colors.browse.recipe_info 	= p.white

		colors.new_recipe.title 	= p.white
		colors.new_recipe.info_bar  = p.white

		colors.settings.text = p.white

		colors.tab_bar.button_text = p.white

		colors.steps.step_text = p.white

	end


	-- Special Colour Considerations
	if color == "blue" then 
		colors.recipe.step_text = p.black

	elseif color == "red" then
		colors.recipe.step_text = P.lighten(p.black,4)
		colors.recipe.title_text = p.white

	elseif color == "dark" then
		colors.new_recipe.outline = p.white
		colors.new_recipe.start_text = p.white

	elseif color == "bright" then
		colors.recipe.step_text = p.lighten(p.black,4)
		colors.recipe.title_text = p.lighten(p.black,4)
	end

end


return colors