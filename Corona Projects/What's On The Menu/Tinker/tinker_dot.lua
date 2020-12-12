local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

local function newDot(x,y,radius,params)
	params = params or {}

	-- Default Parameters
	local label 		= params.label
	local image 		= params.image
	local color 		= params.color 			or {0.7}
	local labelColor 	= params.labelColor 	or {1}
	local tap_func 		= params.tap_func		or function(event) return false end
	local touch_func 	= params.touch_func		or function(event) return false end
	local font 			= params.font 			or native.systemFont
	local strokeColor 	= params.strokeColor 	or {0}
	local strokeWidth 	= params.strokeWidth 	or 0
	local displayGroup  = params.displayGroup

	local group = display.newGroup()
	group.anchorChildren = true
	group.x = x
	group.y = y
	group._radius = radius
	group.label = params.label
	if displayGroup then displayGroup:insert(group) end

	local dot = display.newCircle(group, 0, 0, radius)
	dot:setFillColor(unpack(color))
	dot:setStrokeColor(unpack(strokeColor))
	dot.stokeWidth = strokeWidth

	local function fitText()
		if image then 
			if label.width > radius then
				while label.width > radius do
					label.size = 0.95*label.size
				end

			else
				while label.width < radius do
					label.size = 1.05*label.size
				end
			end
		else
			if label.width > radius*math.sqrt(2) or label.height > radius*math.sqrt(2) then
				while label.width > radius*math.sqrt(2) or label.height > radius*math.sqrt(2) do
					label.size = 0.95*label.size
				end

			else
				while label.width < radius*math.sqrt(2) do
					label.size = 1.05*label.size
				end
			end
		end
	end

	if label then 
		label = display.newText({text = label, x = 0, y = 0, width = 0, height = 0, font = font, fontSize = radius, align = "center"})
		label:setFillColor(unpack(labelColor))
		group:insert(label)

		-- Resize text to fit
		fitText()
	end

	if image then
		image = display.newImageRect(group, image, radius, radius)

		if label then label.y = radius/1.5 end
	end

	if params.hasShadow then 
		local shadow = display.newCircle(group, -0.005*W, 0.005*H, radius)
		shadow:setFillColor(0,0,0,0.5)
		shadow:toBack()
	end

	dot:addEventListener("tap", tap_func)
	dot:addEventListener("touch", touch_func)

	function group:setBackgroundColor(color)
		dot:setFillColor(unpack(color))
	end

	function group:setText(text)
		label.text = text
		group.label = text
		fitText()
	end

	function group:setStrokeColor(color)
		dot:setStrokeColor(unpack(color))
	end

	function group:setStrokeWidth(w)
		dot.stokeWidth = w
	end

	return group
end

return newDot
