tinker = {}

function tinker.newTextField(x, y, width, height, params)
	-- params: rounded, backgroundColor, strokeColor, strokeWidth, cursorColor, textColor, defaultText, font
	params = params or {}

	-- Set default values
	local rounded = params.rounded
	local backgroundColor = params.backgroundColor or {0.5}
	local strokeColor = params.strokeColor or {0}
	local strokeWidth = params.strokeWidth or {0}
	local cursorColor = params.cursorColor or {1}
	local textColor = params.textColor or {0}
	local font = params.font or native.systemFont
	local defaultText = params.defaultText or "TEXT HERE"
	local id = params.id or "Tinker_Text_Field"

	local NTF = native.newTextField(500, 500, 500, 100)  -- Native Text Field: Out of sight, out of mind
	local TTF = display.newGroup()  -- Tinker Text Field
	TTF.x = x
	TTF.y = y
	TTF.id = id

	-- Determine if the Text Field should have corners or rounded edges
	local radius = 0
	if rounded then
		radius = height/2
	end

	-- Create Background Rect or RoundedRect
	local bkgd = display.newRoundedRect(TTF, 0, 0, width, height, radius)
	bkgd:setFillColor(unpack(backgroundColor))

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
	local timerHandle = timer.performWithDelay(500, timerFunc, -1)
	timer.pause(timerHandle)

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
				print("Succeeded at tried_width = " .. tried_width)
				letter_index = math.max(i-1,1)
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
			timer.resume(timerHandle)
		end

		if event.phase == "editing" then
			if NTF.text == "" then
				text.text = defaultText
				ghostText.text = ""
				TTF.text = ""
				text.alpha = 0.5
				cursor.x = line_x
			else
				local old_width = text.width
				text.alpha = 1
				text.text = NTF.text
				ghostText.text = text.text
				TTF.text = text.text

				if #text.text == 1 then
					cursor.x = line_x + text.width
				else
					cursor.x = cursor.x + text.width - old_width
				end
			end
		end

		if event.phase == "ended" or event.phase == "submitted" then
			timer.pause(timerHandle)
			cursor.alpha = 0
			native.setKeyboardFocus(nil)
		end
	end
	NTF:addEventListener("userInput", textFieldUpdateListener)

	-- Decide where to put the cursor, and 
	function bkgd:tap(event)
		native.setKeyboardFocus(NTF)
		local start_x = bkgd:localToContent(line_x, 0)
		local letter_index, offset = findCursorLocation(event.x - start_x)
		cursor.x = line_x + offset
		NTF:setSelection(letter_index,letter_index)
	end
	bkgd:addEventListener("tap", bkgd)

	return TTF


end

return tinker