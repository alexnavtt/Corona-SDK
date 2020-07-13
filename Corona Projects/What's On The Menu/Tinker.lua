tinker = {}

function tinker.newTextField(x, y, width, height, params)
	-- params: rounded, backgroundColor, strokeColor, strokeWidth, cursorColor, textColor, defaultText, font, selectColor
	params = params or {}

	-- Set default values
	local rounded 			= params.rounded
	local backgroundColor 	= params.backgroundColor 	or {1}
	local strokeColor 		= params.strokeColor 		or {0}
	local strokeWidth 		= params.strokeWidth 		or {0}
	local cursorColor 		= params.cursorColor 		or {1}
	local textColor 		= params.textColor 			or {1}
	local selectColor 		= params.selectColor 		or {0}
	local font 				= params.font 				or native.systemFont
	local defaultText 		= params.defaultText 		or "TEXT HERE"
	local id 				= params.id 				or "Tinker_Text_Field"

	local NTF = native.newTextField(-display.contentWidth, -display.contentHeight, 500, 100)  -- Native Text Field: Out of sight, out of mind
	local TTF = display.newGroup()  -- Tinker Text Field
	TTF.x = x
	TTF.y = y
	TTF.id = id
	TTF.text = defaultText
	TTF._nativeTextField = NTF

	-- Determine if the Text Field should have corners or rounded edges
	local radius = 0
	if rounded == true then
		radius = height/2
	end

	-- Create Background Rect or RoundedRect
	local bkgd = display.newRoundedRect(TTF, 0, 0, width, height, radius)
	bkgd:setStrokeColor(unpack(strokeColor))
	bkgd:setFillColor(unpack(backgroundColor))
	bkgd.strokeWidth = strokeWidth

	-- Create underline for text
	local line_y = 0.25*height
	local line_x = -0.5*width + height/2
	local underline = display.newLine(TTF, line_x, line_y, -line_x, line_y)
	underline:setStrokeColor(unpack(textColor), 0.5)
	underline.strokeWidth = 2

	-- Create Cursor
	local cursor = display.newRect(TTF, line_x + 5, line_y - 0.05*height, 1/1000*width, 0.6*height)
	cursor.anchorY = cursor.height
	cursor:setFillColor(unpack(cursorColor))
	cursor:setStrokeColor(unpack(cursorColor))
	cursor.strokeWidth = 1
	cursor.alpha = 0

	-- Make cursor blink
	local function timerFunc(event)
		cursor.alpha = 1 - cursor.alpha
	end
	NTF.timerHandle = timer.performWithDelay(500, timerFunc, -1)
	timer.pause(NTF.timerHandle)

	local text = display.newText({text = defaultText, 
								  x = line_x,
								  y = line_y + 0.05*height,
								  width = 0,
								  height = 0.7*height,
								  font = font,
								  fontSize = 0.5*height,
								  align = "left"})
	text.anchorX = 0
	text.anchorY = text.height
	text.id = "text"
	text:setFillColor(unpack(textColor))
	TTF:insert(text)
	text.alpha = 0.5

	local ghostText = display.newText({text = "", 
									  x = 0,
									  y = 2*display.contentHeight,
									  width = 0,
									  height = 0.7*height,
									  font = font,
									  fontSize = 0.5*height,
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

		ghostText.text = original_text
		if #ghostText.text == 0 then
			offset = 0
		else
			offset = ghostText.width
		end
		return letter_index, offset
	end


	-- Update TTF Text and Cursor Position
	local function textFieldUpdateListener(event)
		if event.phase == "began" then
			timer.resume(NTF.timerHandle)

			if NTF.text == "" then
				NTF.fresh = true
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
			else
				local old_width = text.width
				text.alpha = 1
				text.text = NTF.text
				ghostText.text = text.text
				TTF.text = text.text

				if NTF.fresh then
					cursor.x = line_x + text.width
					NTF.fresh = false
				else
					cursor.x = cursor.x + text.width - old_width
				end
			end

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
	NTF:addEventListener("userInput", textFieldUpdateListener)

	-- Decide where to put the cursor, and 
	function bkgd:tap(event)
		native.setKeyboardFocus(nil)
		native.setKeyboardFocus(NTF)
		local start_x = self:localToContent(line_x, 0)
		local letter_index, offset = findCursorLocation(event.x - start_x)
		cursor.x = line_x + offset
		NTF:setSelection(letter_index,letter_index)
		return true
	end
	bkgd:addEventListener("tap", bkgd)

	-- Add text selection 
	function bkgd:touch(event)
		if event.phase == "began" then
			self._start_letter_index, self._offset_start = findCursorLocation(event.x - self:localToContent(line_x, 0))
			display.getCurrentStage():setFocus(self)

			local function timerFunc(event)
				self._is_selecting = true
				self.display_box = display.newRect(TTF, line_x + self._offset_start, text.y - 0.5*text.height, 1/1000*width, text.height)
				self.display_box:setFillColor(unpack(selectColor), 0.3)
				self.display_box.anchorX = 0
				print("Selection started")
			end
			self._timerHandle = timer.performWithDelay(700, timerFunc, 1)

		elseif event.phase == "moved" then
			timer.cancel(self._timerHandle)
			if self._is_selecting then
				self._end_letter_index, self._offset_end = findCursorLocation(event.x - self:localToContent(line_x,0 ))
				self.display_box.path.x3 = self._offset_end - self._offset_start
				self.display_box.path.x4 = self.display_box.path.x3
				NTF:setSelection(math.min(self._start_letter_index, self._end_letter_index), math.max(self._start_letter_index, self._end_letter_index))
			end

		elseif event.phase == "ended" or event.phase == "cancelled" then
			timer.cancel(self._timerHandle)
			display.getCurrentStage():setFocus(nil)
			self._is_selecting = false

		end

	end
	bkgd:addEventListener("touch", bkgd)


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
		ghostText.text = new_text
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

return tinker