local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

local function newButton(x, y, width, height, params)

	-- Default Parameters
	local label 		= params.label
	local image 		= params.image
	local color 		= params.color 			or {0.7}
	local labelColor 	= params.labelColor 	or {1}
	local tap_func 		= params.tap_func		or function(event) return false end
	local touch_func 	= params.touch_func		or function(event) return false end
	local radius 		= params.radius			or 0
	local font 			= params.font 			or native.systemFont
	local strokeColor 	= params.strokeColor 	or {0}
	local strokeWidth 	= params.strokeWidth 	or 0
	local align 		= params.align 			or "center"

	-- Forward Declarations
	local text_y
	local fontSize

	-- Assure that colors are in table format
	if type(labelColor) == "number" then labelColor  = {labelColor} end
	if type(color) == "number" then color = {color} end

	-- ################## --
	-- Function Main Body --
	-- ################## --
	local group = display.newGroup()
	group.x = x
	group.y = y
	group.anchorChildren = true
	group.text = label
	-- group.id = id

	if params.displayGroup then
		params.displayGroup:insert(group)
	end

	local button = display.newRoundedRect(group, 0, 0, width, height, radius)
	button:setFillColor(unpack(color))
	button:setStrokeColor(unpack(strokeColor))
	button.id = "button"
	button.strokeWidth = strokeWidth
	group._bkgdColor = color
	group._button = button
	-- button.id = id

	function button:tap(event)
		return(tap_func(event))
	end
	button:addEventListener("tap", button)

	function button:touch(event)
		return(touch_func(event))
	end
	button:addEventListener("touch", button)

	local image_rect
	if image then
		text_y = 0.35*height
		fontSize = 0.2*height
		image_rect = display.newImageRect(group, image, math.min(0.65*width, 0.65*height), 0.65*height)
		image_rect.y = -0.1*height
	else
		text_y = 0
		fontSize = 0.7*height
	end

	fontSize = params.fontSize or fontSize
	local label_text
	if label then
		label_text = display.newText({text = label, x = 0, y = text_y, width = 0.9*width, fontSize = fontSize, font = font, align = align})
		label_text:setFillColor(unpack(labelColor))

		-- Ensure label fits
		local cutoff_height = 0.9*height
		while label_text.height > cutoff_height do
			label_text.size = 0.95*label_text.size
		end
		group:insert(label_text)
	
	elseif image then
		image_rect.y = 0
	end

	-- Methods --
	function group:setBackgroundColor(color)
		button:setFillColor(unpack(color))
		group._bkgdColor = color
	end

	function group:setLabelColor(color)
		if label then
			label_text:setFillColor(unpack(color))
		end
	end

	function group:setStrokeColor(color)
		button:setStrokeColor(unpack(color))
	end

	function group:setStrokeWidth(w)
		button.strokeWidth = w
	end

	function group:replaceLabel(text)
		if label_text then
			label_text.text = text
		else
			label_text = display.newText({text = label, x = 0, y = text_y, width = 0.9*width, fontSize = fontSize, font = font, align = align})
			label_text:setFillColor(unpack(labelColor))
			group:insert(label_text)
		end

		local cutoff_height = 0.9*height
		while label_text.height > cutoff_height do
			label_text.size = 0.95*label_text.size
		end

		group.text = text
	end

	function group:addEventListener(format, func)
		button:addEventListener(format, func)
	end

	function group:removeEventListener(format, func)
		button:removeEventListener(format, func)
	end

	function group:replaceImage(filename, baseDir)
		if not image_rect then return true end

		image_rect.fill = {type = "image", filename = filename, baseDir = baseDir}
	end

	group.label = label_text
	group.image = image_rect

	return group
end

return newButton
