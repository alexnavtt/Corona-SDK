local function newCheckBox(x, y, size)
	local group = display.newGroup()
	group.x = x
	group.y = y
	group.anchorChildren = true

	local big_box = display.newRect(group, 0, 0, 3*size, 3*size)
	big_box.alpha = 0.01

	local box = display.newRect(group, 0, 0, size, size)
	box:setFillColor(0,0,0,0.5)
	box:setStrokeColor(1)
	box.strokeWidth = 3
	box.tapped = false

	local check

	function big_box:tap(event)
		self.tapped = not self.tapped

		if self.tapped then
			if not check then
				check = display.newImageRect(group, "Image Assets/Check-Graphic.png", 1.6*size, 1.4*size)
				check:translate(0.2*size, -0.4*size)
			end
			check.alpha = 1
		else
			check.alpha = 0
		end

		return true
	end
	big_box:addEventListener("tap", big_box)

	group.listener = big_box
	return group
end

return newCheckBox
