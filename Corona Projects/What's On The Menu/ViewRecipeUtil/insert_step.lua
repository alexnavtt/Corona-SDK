local globalData = require("globalData")
local app_colors = require("AppColours")

local function insertStep(step_text, step_level_delta, step_count, params)
	local step_group = display.newGroup()

	if step_text == "" or step_text == nil then
		return
	end

	local step_title_params = {text = "Step " .. step_count,
						 x = 0,
						 y = 0,
						 width = 0,
						 height = 0,
						 font = native.systemFontBold,
						 fontSize = globalData.titleFontSize,
						 align = "center"}
	local step_title = display.newText(step_title_params)
	step_title.id = "step_title " .. step_count

	local step_text_params = {text = step_text,
						x = 0.07*(display.contentWidth - params.div_x2),
						y = step_level_delta + step_title.height/2.0,
						width = 0.8*params.scroll_view_width_2,
						height = 0,
						font = native.systemFont,
						fontSize = 0.025*display.contentHeight}

	local step_text_paragraph = display.newText(step_text_params)
	step_text_paragraph.id = "step_text " .. step_count

	step_title:setFillColor(unpack(app_colors.recipe.step_text))
	step_title.anchorX = 0
	step_text_paragraph:setFillColor(unpack(app_colors.recipe.step_text))
	step_text_paragraph.anchorX = 0
	step_text_paragraph.anchorY = 0

	-- Strikethrough line
	local strikethrough = display.newRect(step_title.x - 0.05*step_title.width, step_title.y, 1.05*step_title.width, 2)
	strikethrough.alpha = 0
	strikethrough.anchorX = 0
	strikethrough:setFillColor(unpack(app_colors.recipe.step_text))

	function step_title:tap(event)
		strikethrough.alpha = 0.5 - strikethrough.alpha
		step_title.alpha = 1.5 - step_title.alpha
		step_text_paragraph.alpha = 1.5 - step_text_paragraph.alpha
	end
	step_title:addEventListener("tap", step_title)

	step_group:insert(step_title)
	step_group:insert(step_text_paragraph)
	step_group:insert(strikethrough)

	strikethrough:toFront()

	return step_group
end

return insertStep
