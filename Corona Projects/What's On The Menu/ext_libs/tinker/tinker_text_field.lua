local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

-- Find the the start and end indices of the word which is surrounding a particular index
local function findWordBoundaries(text, index)
	if #text == 0 then return 0,0 end
	local start_index
	local end_index
	local letter_count = #text

	-- Find the letter index just before the word start
	for i = index,0,-1 do
		if text:sub(i,i) == " " or i == 0 then
			start_index = i
			break
		end
	end

	-- Find the letter index of the last letter of the word
	for i = index,letter_count,1 do
		if text:sub(i,i) == " "  then
			end_index = math.max(i - 1, 0)
			break
		end

		if i == letter_count then
			end_index = i
			break
		end
	end

	return start_index, end_index
end

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
	local fontSize 			= params.fontSize 			or (0.5*height)
	local isNumeric 		= params.isNumeric
	local tapOutside 		= params.tapOutside
	local noUnderline		= params.noUnderline
	local centered 			= params.centered
	local displayGroup 		= params.displayGroup

	-- local NTF = native.newTextField(display.contentCenterX, display.contentCenterY, 500, 100)  -- Uncomment this for debugging
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
	local line_x = -0.5*width + 0.3*height 	-- This is the start point for the text

	if not noUnderline then
		line_y = line_y - 0.1*height
		line_x = line_x + 0.4*height
		local underline = display.newLine(TTF, line_x, line_y, -line_x, line_y)
		underline:setStrokeColor(unpack(textColor), 0.5)
		underline.strokeWidth = 2
		TTF._underline = underline
	end

	-- Create Cursor
	local cursor = display.newRect(TTF, line_x + 5, line_y - 0.05*height, 1/1000*width, 0.6*height)
	cursor.anchorY = cursor.height
	cursor:setFillColor(unpack(cursorColor))
	cursor:setStrokeColor(unpack(cursorColor))
	cursor.strokeWidth = 1
	cursor.alpha = 0
	TTF._cursor = cursor

	-- Make cursor blink
	local function timerFunc(event)
		if cursor.alpha then
			cursor.alpha = 1 - cursor.alpha
		end
	end
	TTF._cursorTimerHandle = timer.performWithDelay(500, timerFunc, -1)
	timer.pause(TTF._cursorTimerHandle)

	-- Set default text
	local align = centered or "left"
	local displayText = display.newText({text = defaultText, 
								  x = line_x,
								  y = line_y + 0.05*height,
								  width = 0,
								  height = 0.7*height,
								  font = font,
								  fontSize = fontSize,
								  align = align})
	if centered then displayText.x = 0 else displayText.anchorX = 0 end
	displayText.anchorY = displayText.height
	displayText.id = "display_text"
	displayText:setFillColor(unpack(textColor))
	TTF:insert(displayText)
	displayText.alpha = 0.5
	TTF._displayTextObject = displayText

	-- Set a variable for the average length of a character
	local avg_length = displayText.width / #displayText.text

	-- Create a semi-transparent rect for text selection
	TTF._selectionBox = display.newRect(TTF, 0, displayText.y - 0.5*displayText.height, 10, displayText.height)
	TTF._selectionBox:setFillColor(unpack(selectColor))
	TTF._selectionBox.alpha = 0
	TTF._selectionBox.anchorX = 0
	function TTF._selectionBox:show(x1,x2)
		self.x = x1
		self.width = x2-x1
		self.alpha = 0.3
	end

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

	-- Create a touch panel to allow touching outside of the text field to remove keyboard focus
	TTF._glassScreen = display.newRect(TTF, 0, 0, 2*display.contentWidth, 2*display.contentHeight)
	TTF._glassScreen.alpha = 0

	function TTF._glassScreen:tap(event)
		native.setKeyboardFocus(nil)
		self.alpha = 0
		return true
	end
	TTF._glassScreen:addEventListener("tap", TTF._glassScreen)
	TTF._glassScreen:toBack()




	-- ################################## --
	-- Text Field Functions and Listeners --
	-- ################################## --

	-- Find where to put the cursor, both on the native text 
	-- field and the Tinker Text Field
	local function findCursorLocation(selection_width)
		-- Initialize outputs
		local offset = 0						-- The distance from the left of the text to place the cursor
		local letter_index = 0				 	-- Which letter index the cursor will be after

		local char_count = #ghostText.text 		-- The number of characters in the current text
		local original_text = ghostText.text 	-- The original text, which will be used to reset it after changing
		local avg_length = avg_length 			-- Update the average length of a single character
		local tried_width = 0 					-- A test width to see if this is the correct value for the offset

		-- If the tap is before the beginning of the text or there is no text, place the cursor at the start
		if selection_width < 0 or char_count == 0 then
			return 1,0
		end

		-- Estimate where the cursor should be
		local estimate_position = math.round(selection_width/avg_length)
		if estimate_position > char_count then estimate_position = char_count end

		-- Determine if the estimate is too far or not far enough
		ghostText.text = original_text:sub(1,estimate_position)

		-- If the estimate was too far, iterate backwards
		if ghostText.width >= selection_width then
			for i = estimate_position, 0, -1 do
				-- Try out this index and see if it fits
				ghostText.text = original_text:sub(1,i)
				tried_width = ghostText.width - 0.5*avg_length

				-- A successful match was found
				if tried_width < selection_width then
					letter_index = math.min(i+1, char_count)
					offset = ghostText.width
					ghostText.text = original_text
					return letter_index, offset
				end
			end

		-- If the estimate was not far enough iterate forwards
		else
			for i = estimate_position,#original_text,1 do	
				-- Try out this index and see if it fits
				ghostText.text = original_text:sub(1,i)		
				tried_width = ghostText.width - 0.5*avg_length

				-- A successful match was found
				if tried_width >= selection_width then
					letter_index = math.max(i-1,0)
					ghostText.text = original_text
					return letter_index, offset
				end

				offset = ghostText.width
			end
		end

		-- This section calls if a proper location isn't found
		ghostText.text = original_text
		offset = ghostText.width
		letter_index = char_count

		return letter_index, offset
	end


	-- Update TTF Text and Cursor Position
	-- local TTF._glassScreen
	local function userInputListener(event)

		if event.phase == "began" then
			-- Make the cursor blink
			timer.resume(TTF._cursorTimerHandle)

			-- Flag to indicate that there is no text in the text field
			if NTF.text == "" then TTF._noText = true end

			-- Set up a tap field which removes focus from the text field when tapping away from it
			if tapOutside then
				TTF:toFront()
				TTF._glassScreen.alpha = 0.01
			end

		elseif event.phase == "editing" then
			-- If the field is empty, place the default text and indiciate the field is empty
			if NTF.text == "" then
				TTF:replaceText("")

			-- Field is not empty
			else
				-- Store the previous width of the text for help determining where the cursor should end up
				local old_width = displayText.width

				-- Remove the default text if it exists and make the text show what the user has typed
				displayText.alpha = 1
				displayText.text  = NTF.text
				ghostText.text    = NTF.text
				TTF.text 		  = NTF.text

				if TTF._noText then
					cursor.x = line_x + displayText.width
					TTF._noText = false
					if centered then cursor.x = 0.5*(cursor.x - line_x) end
				else
					local offset_factor = 1
					if centered then offset_factor = 0.5 end
					cursor.x = cursor.x + offset_factor*(displayText.width - old_width)
				end

				if cursor.x < line_x then cursor.x = line_x end
			end

			-- If there were mulitple characters selected
			if TTF._selectionBox.alpha ~= 0 then
				print(TTF._selectionBox.alpha)
				-- Determine if the input was a delete or input edit
				if #ghostText.text == TTF._totalLetterCount - TTF._selectionLetterCount then
					-- Delete action: place the cursor where the start of the selection box is
					cursor.x = TTF._selectionBox.x
				else
					-- Edit action: place the cursor 1 character to the right of where the selection box is
					ghostText.text = ghostText.text:sub(0, TTF._selectionStartIndex + 1)
					cursor.x = line_x + ghostText.width
					ghostText.text = displayText.text
				end

				-- Remove the selection box
				TTF._selectionBox.alpha = 0

				-- Start the cursor blinking again
				timer.resume(TTF._cursorTimerHandle)
				cursor.alpha = 1
			end
		

		elseif event.phase == "ended" or event.phase == "submitted" then
			-- Hide the cursor and remove the keyboard
			timer.pause(TTF._cursorTimerHandle)
			cursor.alpha = 0
			native.setKeyboardFocus(nil)

			-- Hide the selection box
			TTF._selectionBox.alpha = 0

			-- Remove the outside tap field
			TTF._glassScreen.alpha = 0

		end
	end -- userInputListener
	NTF:addEventListener("userInput", userInputListener)
	NTF.inputFunc = userInputListener

	-- Tap function for cursor placement and text selection 
	function bkgd:tap(event)
		ghostText.text = NTF.text
		native.setKeyboardFocus(NTF)

		local letter_index, offset
		if centered then
			local start_x = self:localToContent(-ghostText.width/2,0)
			letter_index, offset = findCursorLocation(event.x - start_x)
			cursor.x = -ghostText.width/2 + offset
			NTF:setSelection(letter_index,letter_index)
		else
			start_x = self:localToContent(line_x, 0)
			letter_index, offset = findCursorLocation(event.x - start_x)
			cursor.x = line_x + offset
			NTF:setSelection(letter_index,letter_index)
		end
		native.setKeyboardFocus(NTF)

		-- Remove text selections for single taps
		if event.numTaps == 1 then
			TTF:unselectText()
		end

		-- On double tap select the entire word
		if event.numTaps == 2 then
			local start_index, end_index = findWordBoundaries(NTF.text, letter_index)
			TTF:selectText(start_index, end_index)
		end

		-- On triple tap select all text
		if event.numTaps == 3 then
			TTF:selectText(0,#NTF.text)
		end

		return true
	end
	bkgd:addEventListener("tap", bkgd)


	-- ############# --
	-- Class Methods --
	-- ############# --

	function TTF:selectText(start_index, end_index)
		if #ghostText.text == 0 then return end

		ghostText.text = NTF.text:sub(0,start_index)
		local small_x  = line_x + ghostText.width
		if #ghostText.text == 0 then small_x = line_x end

		ghostText.text = NTF.text:sub(0,end_index)
		local large_x  = line_x + ghostText.width

		ghostText.text = NTF.text

		-- Show the selection area
		TTF._selectionBox:show(small_x, large_x)

		-- Set some variables to help figure out where to put the cursor after
		TTF._selectionStartIndex  = start_index
		TTF._selectionEndIndex    = end_index
		TTF._selectionLetterCount = end_index - start_index
		TTF._totalLetterCount = #NTF.text

		NTF:setSelection(start_index, end_index)
		timer.pause(TTF._cursorTimerHandle)
		cursor.alpha = 0

		native.setKeyboardFocus(NTF)
	end

	function TTF:unselectText()
		timer.resume(TTF._cursorTimerHandle)
		cursor.alpha = 1
		TTF._selectionBox.alpha = 0
	end

	function TTF:addEventListener(format, listener)
		NTF:addEventListener(format, listener)
		bkgd:addEventListener(format, listener)
	end

	function TTF:replaceText(new_text)
		NTF.text = new_text
		TTF.text = new_text
		ghostText.text = new_text
		displayText.text = new_text
		displayText.alpha = 1

		if new_text == "" then
			cursor.x = line_x
			displayText.text = defaultText
			displayText.alpha = 0.5
			TTF._noText = true
			NTF:setSelection(0,0)
		else
			cursor.x = line_x + displayText.width
			NTF:setSelection(#NTF.text, #NTF.text)
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
		timer.cancel(TTF._cursorTimerHandle)
		NTF:removeSelf()
		for i = 1,TTF.numChildren,1 do
			TTF:remove(1)
		end
		TTF = nil
	end

	function TTF:getWidth()
		return width
	end

	function TTF:getHeight()
		return height
	end

	return TTF
end

return newTextField
