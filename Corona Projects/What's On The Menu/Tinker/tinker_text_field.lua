local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

local function newTextField(x, y, width, height, params)
	params = params or {}

	-- Set default values
	local radius 			= params.radius 			or 0
	local backgroundColor 	= params.backgroundColor 	or {1}
	local strokeColor 		= params.strokeColor 		or {0}
	local strokeWidth 		= params.strokeWidth 		or {0}
	local cursorColor 		= params.cursorColor 		or {0}
	local textColor 		= params.textColor 			or {0}
	local selectColor 		= params.selectColor 		or {0}
	local font 				= params.font 				or native.systemFont
	local defaultText 		= params.defaultText 		or "TEXT HERE"
	local id 				= params.id 				or "Tinker_Text_Field"
	local fontSize 			= params.fontSize 			or 0.5*height
	local isNumeric 		= params.isNumeric
	local tapOutside 		= params.tapOutside
	local noUnderline		= params.noUnderline
	local centered 			= params.centered
	local displayGroup 		= params.displayGroup

	local NTF = native.newTextField(-display.contentWidth, -display.contentHeight, 500, 100)  -- Native Text Field: Out of sight, out of mind
	local TTF = display.newGroup()  -- Tinker Text Field
	TTF.x = x
	TTF.y = y
	TTF.id = id
	TTF.text = ""
	TTF._nativeTextField = NTF

	if params.displayGroup then params.displayGroup:insert(TTF) end

	if isNumeric then
		NTF.inputType = "number"
	end

	-- Create Background RoundedRect
	local bkgd = display.newRoundedRect(TTF, 0, 0, width, height, radius)
	bkgd:setStrokeColor(unpack(strokeColor))
	bkgd:setFillColor(unpack(backgroundColor))
	bkgd.strokeWidth = strokeWidth
	TTF._background = bkgd

	-- Create underline for text
	local line_y = 0.25*height + 0.1*height
	local line_x = -0.5*width + 0.3*height

	if not noUnderline then
		line_y = line_y - 0.1*height
		line_x = line_x + 0.4*height
		local underline = display.newLine(TTF, line_x, line_y, -line_x, line_y)
		underline:setStrokeColor(unpack(textColor), 0.5)
		underline.strokeWidth = 2
	end

	-- Create Cursor
	local cursor = display.newRect(TTF, line_x + 5, line_y - 0.05*height, 1/1000*width, 0.6*height)
	cursor.anchorY = cursor.height
	cursor:setFillColor(unpack(cursorColor))
	cursor:setStrokeColor(unpack(cursorColor))
	cursor.strokeWidth = 1
	cursor.alpha = 0

	-- Make cursor blink
	local function timerFunc(event)
		if cursor.alpha then
			cursor.alpha = 1 - cursor.alpha
		end
	end
	NTF.timerHandle = timer.performWithDelay(500, timerFunc, -1)
	timer.pause(NTF.timerHandle)

	-- Set default text
	local align = centered or "left"

	local text = display.newText({text = defaultText, 
								  x = line_x,
								  y = line_y + 0.05*height,
								  width = 0,
								  height = 0.7*height,
								  font = font,
								  fontSize = fontSize,
								  align = align})
	if centered then 
		text.x = 0
	else
		text.anchorX = 0
	end
	text.anchorY = text.height
	text.id = "text"
	text:setFillColor(unpack(textColor))
	TTF:insert(text)
	text.alpha = 0.5

	-- Ghost text is for measuring width
	local ghostText = display.newText({text = "", 
									  x = line_x,
									  y = 2*display.contentHeight,
									  width = 0,
									  height = 0.7*height,
									  font = font,
									  fontSize = fontSize,
									  align = "left"})
	ghostText.anchorX = 0

	-- ################################## --
	-- Text Field Functions and Listeners --
	-- ################################## --

	-- Find where to put the cursor, both on the native text 
	-- field and the Tinker Text Field
	local function findCursorLocation(selection_width)

		local letter_index = #ghostText.text
		local original_text = ghostText.text
		local tried_width = 0
		local offset = 0

		if selection_width < 0 then
			return 1,0
		end

		for i = 1,#original_text,1 do	
			ghostText.text = original_text

			ghostText.text = ghostText.text:sub(1,i)		
			tried_width = 0.95*ghostText.width

			if tried_width >= selection_width then
				letter_index = math.max(i-1,0)
				ghostText.text = original_text
				return letter_index, offset
			end

			offset = ghostText.width
		end

		-- This section calls if a proper location isn't found
		ghostText.text = original_text
		if #ghostText.text == 0 then
			offset = 0
		else
			offset = ghostText.width
		end

		return letter_index, offset
	end


	-- Update TTF Text and Cursor Position
	local function userInputListener(event)
		if event.phase == "began" then
			timer.resume(NTF.timerHandle)

			if NTF.text == "" then
				NTF.fresh = true
			end

			if tapOutside == true then
				local glass_screen = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
				glass_screen.alpha = 0.01

				function glass_screen:tap(event)
					native.setKeyboardFocus(nil)
					self:removeSelf()
					return true
				end

				glass_screen:addEventListener("tap", glass_screen)
				glass_screen:addEventListener("touch", glass_screen)
			end
		end

		if event.phase == "editing" then
			if NTF.text == "" then
				text.text = defaultText
				ghostText.text = ""
				TTF.text = ""
				text.alpha = 0.5
				cursor.x = line_x
				NTF.fresh = true

				if centered then cursor.x = 0 end
			else
				local old_width = text.width
				text.alpha = 1
				text.text = NTF.text
				ghostText.text = text.text
				TTF.text = text.text

				if NTF.fresh then
					cursor.x = line_x + text.width
					NTF.fresh = false
					if centered then cursor.x = 0.5*(cursor.x - line_x) end
				else
					local offset_factor = 1
					if centered then offset_factor = 0.5 end
					cursor.x = cursor.x + offset_factor*(text.width - old_width)
				end
			end

			print(bkgd.display_box)
			if bkgd.display_box then
				cursor.x = line_x + math.min(bkgd._offset_end, bkgd._offset_start)
				bkgd.display_box:removeSelf()
				bkgd.display_box = nil
			end
		end

		if event.phase == "ended" or event.phase == "submitted" then
			timer.pause(NTF.timerHandle)
			cursor.alpha = 0
			native.setKeyboardFocus(nil)

			if bkgd.display_box then
				bkgd.display_box:removeSelf()
				bkgd.display_box = nil
			end
		end
	end
	NTF:addEventListener("userInput", userInputListener)
	NTF.inputFunc = userInputListener

	-- Decide where to put the cursor, and 
	function bkgd:tap(event)
		native.setKeyboardFocus(nil)
		native.setKeyboardFocus(NTF)
		local start_x
		if centered then
			local start_x = self:localToContent(-ghostText.width/2,0)
			local letter_index, offset = findCursorLocation(event.x - start_x)
			print(-start_x + event.x)
			cursor.x = -ghostText.width/2 + offset
			NTF:setSelection(letter_index,letter_index)
		else
			start_x = self:localToContent(line_x, 0)
			local letter_index, offset = findCursorLocation(event.x - start_x)
			cursor.x = line_x + offset
			NTF:setSelection(letter_index,letter_index)
		end

		-- if centered then cursor.x = 0.5*cursor.x end
		return true
	end
	bkgd:addEventListener("tap", bkgd)

	-- Add text selection 
	function bkgd:touch(event)
		if event.phase == "began" then
			self._start_letter_index, self._offset_start = findCursorLocation(event.x - self:localToContent(line_x, 0))
			display.getCurrentStage():setFocus(self)

			local function timerFunc(event)
				if self.display_box then
					self.display_box:removeSelf()
				end

				self._is_selecting = true
				self.display_box = display.newRect(TTF, line_x + self._offset_start, text.y - 0.5*text.height, 1/1000*width, text.height)
				self.display_box:setFillColor(unpack(selectColor), 0.3)
				self.display_box.anchorX = 0
				print("Selection started")
			end
			self._timerHandle = timer.performWithDelay(500, timerFunc, 1)

		elseif event.phase == "moved" then
			timer.cancel(self._timerHandle)
			if self._is_selecting then
				print("Creating display_box")
				self._end_letter_index, self._offset_end = findCursorLocation(event.x - self:localToContent(line_x,0 ))
				self.display_box.path.x3 = self._offset_end - self._offset_start
				self.display_box.path.x4 = self.display_box.path.x3
				NTF:setSelection(math.min(self._start_letter_index, self._end_letter_index), math.max(self._start_letter_index, self._end_letter_index))
			end

		elseif event.phase == "ended" or event.phase == "cancelled" then
			timer.cancel(self._timerHandle)
			display.getCurrentStage():setFocus(nil)
			self._is_selecting = false
			print("Stopped holding")

		end

	end
	-- bkgd:addEventListener("touch", bkgd)


	-- ############# --
	-- Class Methods --
	-- ############# --

	function TTF:addEventListener(format, listener)
		NTF:addEventListener(format, listener)
		bkgd:addEventListener(format, listener)
	end

	function TTF:replaceText(new_text)
		NTF.text = new_text
		text.text = new_text
		TTF.text = new_text
		ghostText.text = new_text
		text.alpha = 1

		if new_text == "" then
			cursor.x = line_x
			text.text = defaultText
			text.alpha = 0.5
		else
			cursor.x = line_x + text.width
		end
	end

	function TTF:setFocus(isFocus)
		if isFocus then
			native.setKeyboardFocus(NTF)
		else
			native.setKeyboardFocus(nil)
		end
	end

	function TTF:removeSelf()
		timer.cancel(NTF.timerHandle)
		NTF:removeSelf()
		for i = 1,TTF.numChildren,1 do
			TTF:remove(1)
		end
		TTF = nil
	end

	return TTF
end

return newTextField
