local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

local function numericKeyboard(x,y,width,height,params)

	-- Default Params
	local x 				= x 						or Cx
	local y 				= y 						or 0.75*H
	local width 			= width 					or 0.70*W
	local height 			= height 					or 0.45*H
	local params 			= params 					or {}
	local backgroundColor 	= params.backgroundColor 	or {1}
	local touchedColor 		= params.touchedColor 		
	local keyColor 			= params.keyColor 			or {0.5}
	local keyTextColor 		= params.keyTextColor 		or {1}
	local touchedKeyColor 	= params.touchedKeyColor
	local radius 			= params.radius 			or 0
	local X_func 			= params.X_func				or function(event) return true end
	local O_func 			= params.O_func 			or function(event) return true end

	if not touchedColor then
		touchedColor = {}
		for i = 1,#keyColor,1 do
			touchedColor[i] = 0.8*keyColor[i]
			if i == 4 then break end
		end
	end

	if not touchedKeyColor then
		touchedKeyColor = {}
		for i = 1,#keyTextColor,1 do
			touchedKeyColor[i] = 0.8*keyTextColor[i]
			if i == 4 then break end
		end
	end

	local group = display.newGroup()
	group.x = x
	group.y = y
	group.anchorChildren = true

	local left_x = -width/2
	local top_y  = -height/2

	local bkgd = display.newRoundedRect(group, 0, 0, 0.8*width, 0.9*height, radius)
	bkgd:setFillColor(unpack(backgroundColor))
	bkgd:addEventListener("tap", function(event) return true end)
	bkgd:addEventListener("touch", function(event) return true end)

	local key_params = {radius = 0.05*height, color = keyColor}

	local function keyTouch(key, event)
		if event.phase == "began" then
			display.getCurrentStage():setFocus(key._button, event.id)
			key:setBackgroundColor(touchedColor)
			key:setLabelColor(touchedKeyColor)

		elseif event.phase == "ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus(nil)
			key:setBackgroundColor(keyColor)
			key:setLabelColor(keyTextColor)
		end
	end

	for i = 1,10,1 do
		local x_loc = left_x + 0.25*width*((i-1)%3 + 1)
		local y_loc = top_y + 0.20*height*math.ceil((i)/3)

		if i == 10 then x_loc = 0 end

		key_params.label = (i%10)
		local key = tinker.newButton(x_loc, y_loc, 0.2*width, 0.16*height, key_params)
		group:insert(key)

		function key:tap(event)
			group._active_key = (i%10)
		end

		function key:touch(event)
			keyTouch(self,event)
		end

		key:addEventListener("tap", key)
		key:addEventListener("touch", key)
	end

	local x_loc = left_x + 0.25*width
	local y_loc = top_y + 0.80*height

	key_params.label = "X\nClear"
	key_params.labelColor = {0.8,0,0}
	local back_button = tinker.newButton(x_loc, y_loc, 0.2*width, 0.16*height, key_params)
	group:insert(back_button)

	key_params.label = "→\nEnter"
	key_params.labelColor = {0,0.8,0}
	local return_button = tinker.newButton(x_loc + width/2, y_loc, 0.2*width, 0.16*height, key_params)
	group:insert(return_button)

	function back_button:touch(event)
		keyTouch(self,event)
		self:setLabelColor({0.8,0,0})
		return(true)
	end

	function return_button:touch(event)
		keyTouch(self,event)
		self:setLabelColor({0,0.8,0})
		return(true)
	end

	back_button:addEventListener("tap", X_func)
	back_button:addEventListener("touch", back_button)

	return_button:addEventListener("tap", O_func)
	return_button:addEventListener("touch", return_button)

	-- METHODS --

	function group:attachTextObject(text_field)
		if group._glass_screen then
			group._glass_screen:removeSelf()
			group._glass_screen = nil
		end

		group._glass_screen = display.newRoundedRect(group, 0, 0, 0.8*width, 0.9*height, radius)
		group._glass_screen.alpha = 0.01

		local function sendText(event)
			if self._active_key then
				text_field.text = text_field.text .. self._active_key
				self._active_key = nil
			end
		end

		group._glass_screen:addEventListener("tap", sendText)
		group._glass_screen:addEventListener("touch", sendText)

		group._glass_screen:toBack()
		bkgd:toBack()
	end

	function group:setOFunc(func)
		return_button:removeEventListener("tap", O_func)
		return_button:addEventListener("tap", func)
		O_func = func
	end

	function group:setXFunc(func)
		back_button:removeEventListener("tap", X_func)
		back_button:addEventListener("tap", func)
		X_func = func
	end

	return group
end

return numericKeyboard
