local util = require("GeneralUtility")

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

	for i = index,0,-1 do
		if text:sub(i,i) == " " or i == 0 then
			start_index = i
			break
		end
	end

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
	local fontSize 			= params.fontSize 			or 0.5*height
	local isNumeric 		= params.isNumeric
	local tapOutside 		= params.tapOutside
	local noUnderline		= params.noUnderline
	local centered 			= params.centered
	local displayGroup 		= params.displayGroup

	local NTF = native.newTextField(-display.contentWidth, -display.contentHeight, 500, 100)  -- Native Text Field: Out of sight, out of mind
	-- local NTF = native.newTextField(display.contentCenterX, display.contentCenterY, 500, 100)  -- Uncomment this for debugging
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

	-- Set a variable for the average length of a character
	local avg_length = text.width / #text.text

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
		local avg_length = avg_length
		local tried_width = 0
		local offset = 0

		-- If the tap is before the beginning of the text, place the cursor at the start
		if selection_width < 0 or letter_index == 0 then
			return 1,0
		end

		-- Estimate where the cursor should be
		local estimate_position = math.round(selection_width/avg_length)
		if estimate_position > letter_index then estimate_position = letter_index end

		-- Determine if the estimate is too far or not far enough
		ghostText.text = original_text:sub(1,estimate_position)

		-- If the estimate was too far, iterate backwards
		if ghostText.width >= selection_width then
			for i = estimate_position, 0, -1 do
				-- Try out this index and see if it fits
				ghostText.text = original_text:sub(1,i)
				tried_width = ghostText.width - 0.5*avg_length

				if tried_width < selection_width then
					letter_index = math.min(i+1, letter_index)
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

		return letter_index, offset
	end


	-- Update TTF Text and Cursor Position
	local glass_screen
	local function userInputListener(event)

		if event.phase == "began" then
			-- Make the cursor blink
			timer.resume(NTF.timerHandle)

			-- Flag to indicate that there is no text in the text field
			if NTF.text == "" then
				NTF.fresh = true
			end

			-- Set up a tap field which removes focus from the text field when tapping away from it
			if tapOutside == true and not (glass_screen and glass_screen.parent) then
				glass_screen = display.newRect(TTF, 0, 0, 2*display.contentWidth, 2*display.contentHeight)
				glass_screen.alpha = 0.01

				function glass_screen:tap(event)
					native.setKeyboardFocus(nil)
					self:removeSelf()
					self = nil
					return true
				end

				glass_screen:addEventListener("tap", glass_screen)
				glass_screen:toBack()
			end
		end

		if event.phase == "editing" then
			-- If the field is empty, place the default text and indiciate the field is empty
			if NTF.text == "" then
				text.text = defaultText
				ghostText.text = ""
				TTF.text = ""
				text.alpha = 0.5
				cursor.x = line_x
				NTF.fresh = true

				if centered then cursor.x = 0 end

			-- Field is not empty
			else
				-- Store the previous width of the text for help determining where the cursor should end up
				local old_width = text.width

				-- Remove the default text if it exists and make the text show what the user has typed
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

				if cursor.x < line_x then cursor.x = line_x end
			end

			-- There were mulitple characters selected
			if bkgd.display_box then
				-- Determine if the input was a delete or input edit
				if #ghostText.text == bkgd.text_letter_count - bkgd.selection_letter_count then
					-- Delete action: place the cursor where the start of the selection box is
					cursor.x = bkgd.display_box.x
				else
					-- Edit action: place the cursor 1 character to the right of where the selection box is
					ghostText.text = ghostText.text:sub(0, bkgd.start_index + 1)
					cursor.x = line_x + ghostText.width
					ghostText.text = text.text
				end

				-- Remove the selection box
				bkgd.display_box:removeSelf()
				bkgd.display_box = nil

				-- Start the cursor blinking again
				timer.resume(NTF.timerHandle)
				cursor.alpha = 1
			end
		end

		if event.phase == "ended" or event.phase == "submitted" then
			-- Hide the cursor and remove the keyboard
			timer.pause(NTF.timerHandle)
			cursor.alpha = 0
			native.setKeyboardFocus(nil)

			-- Delete the selection box if it existed
			if bkgd.display_box then
				bkgd.display_box:removeSelf()
				bkgd.display_box = nil
			end

			if glass_screen and glass_screen.parent then 
				glass_screen.parent:remove(glass_screen)
				glass_screen = nil
			end

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
			print(-start_x + event.x)
			cursor.x = -ghostText.width/2 + offset
			NTF:setSelection(letter_index,letter_index)
		else
			start_x = self:localToContent(line_x, 0)
			letter_index, offset = findCursorLocation(event.x - start_x)
			cursor.x = line_x + offset
			NTF:setSelection(letter_index,letter_index)
		end
		native.setKeyboardFocus(NTF)

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
		local original_text = ghostText.text
		if #ghostText.text == 0 then return end

		ghostText.text = original_text:sub(0,start_index)
		local small_x  = line_x + ghostText.width
		if #ghostText.text == 0 then small_x = line_x end

		ghostText.text = original_text:sub(0,end_index)
		local large_x  = line_x + ghostText.width

		ghostText.text = original_text

		if bkgd.display_box then TTF:remove(bkgd.display_box) end
		bkgd.display_box = display.newRect(TTF, small_x, text.y - 0.5*text.height, large_x - small_x, text.height)
		bkgd.display_box:setFillColor(unpack(selectColor), 0.3)
		bkgd.display_box.anchorX = 0
		print("Display box created, starts at " .. bkgd.display_box.x .. " and ends at " .. bkgd.display_box.x + bkgd.display_box.width)

		-- Set some variables to help figure out where to put the cursor after
		bkgd.start_index = start_index
		bkgd.end_index = end_index
		bkgd.selection_letter_count = end_index - start_index
		bkgd.text_letter_count = #original_text

		NTF:setSelection(start_index, end_index)
		timer.pause(NTF.timerHandle)
		cursor.alpha = 0

		native.setKeyboardFocus(NTF)
	end

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
