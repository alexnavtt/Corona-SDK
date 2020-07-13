
local composer = require( "composer" )
local widget   = require( "widget" )
local scene = composer.newScene()
local globalData = require('globalData')

local frontGroup -- Overlay display group to display results

local function parseRequest(request)
	request = string.lower(request)
	resulting_keyword = "none"
	match_set = {}

	for i = 1,string.len(request),1 do
		for keyword, key_table in pairs(globalData.Keywords) do
			-- If there is an exact match, then return it
			if keyword == key_table then
				resulting_keyword = keyword
				return resulting_keyword
			end

			-- If not an exact match, find the closest word
			if string.sub(keyword,1,i) == string.sub(request,1,i) then
				match_set[keyword] = true
			else
				match_set[keyword] = nil
			end
		end

		local length_of_table = 0
		for keyword, matched in pairs(match_set) do
			length_of_table = length_of_table + 1
			if matched then
				resulting_keyword = keyword
			end
		end

		if length_of_table <= 1 then
			print("Returning keyword " .. resulting_keyword)
			return resulting_keyword
		end
	end

	return resulting_keyword
end


local function serachFieldListener( event )
	if event.phase == "submitted" then

		searchRequest = event.target.text
		parsedText 	  = parseRequest(event.target.text)
		search_result = globalData.Keywords[parsedText]

		-- Results Header
		result_text = "Showing Results for '" .. parsedText .. "'\n"

		-- Options for a scrollable text box
		local scrollOptions = { x 		= display.contentCenterX,
								y  		= display.contentCenterY,
								width 	= display.contentWidth,
								height 	= display.contentHeight  - 100,
								horizontalScrollDisabled = false,
								hideScrollBar = false,
								isBounceEnabled = false}

		-- Create Scroll window and add text
		local scrollObject = widget.newScrollView( scrollOptions )

		current_text_pos = 75

		-- List out all the matching foods by keyword
		if search_result then

			for index1, food in pairs(search_result) do
				food_result_params = {text = food,
									  x = 0.1*display.contentWidth,
									  y = current_text_pos,
									  width = display.contentWidth*0.9,
									  font = native.systemFontBold,
									  fontSize = 16,
									  align = "left"}

				food_result_object = display.newText(food_result_params)
				food_result_object.anchorY = 0
				food_result_object.anchorX = 0
				food_result_object:setFillColor( 0 )
				scrollObject:insert(food_result_object)

				current_text_pos = current_text_pos + food_result_object.height + 5

				brand_and_type_text = ""
				for brand_title, flavour_table in pairs(globalData.Foods[food]) do
					for flavour_title, allowed in pairs(flavour_table) do
						brand_and_type_text = brand_and_type_text .. '• ' .. brand_title .. " " .. flavour_title .. '\n'
					end
				end

				brand_and_type_params = {text = brand_and_type_text,
										 x = 0.15*display.contentWidth,
										 y = current_text_pos,
										 width = 0.85*display.contentWidth,
										 fontSize = 14,
										 align = "left"}

				brand_and_type_object = display.newText(brand_and_type_params)
				brand_and_type_object.anchorY = 0
				brand_and_type_object.anchorX = 0
				brand_and_type_object:setFillColor(0)
				scrollObject:insert(brand_and_type_object)

				current_text_pos = current_text_pos + brand_and_type_object.height + 20
			end

		else
			result_text = "No matching foods found"
		end

		-- Options for the results text shown on the scroll bar
		local searchResultsParams = {text   = result_text,
						 			 x 	    = 0.1*display.contentWidth,
						 			 y      = 25,
						 			 width  = 0.9*display.contentWidth,
						 			 font   = native.systemFont, fontSize = 16,
						 			 align  = "left"}

		-- Create text list of all allowable foods
		result_text_object = display.newText(searchResultsParams)
		result_text_object:setFillColor( 0 )
		result_text_object.anchorY = 0
		result_text_object.anchorX = 0

		scrollObject:insert(result_text_object)
		scrollObject:setScrollHeight(current_text_pos * 1.1)
		frontGroup:insert(scrollObject)

		-- Remove text field since it will always be in front
		myTextField:removeSelf()
		myTextField = nil

		-- Add touch listener to remove scroll view
		local function touchListener(self, event )
			if event.phase == "ended" then
				myTextField = native.newTextField(display.contentCenterX, 140, 150, 40)
				myTextField:addEventListener("userInput", serachFieldListener)
				while frontGroup.numChildren > 0 do
					frontGroup:remove(1)
				end
			end
		end

		backBar = display.newRect(display.contentCenterX, display.contentHeight - 25, display.contentWidth, 50)
		backBar.touch = touchListener
		backBar:setFillColor( 0.8 )
		backBar:addEventListener("touch", backBar)
		frontGroup:insert(backBar)

		back_text_params = {text 	= "Done",
					 		x 		= display.contentCenterX,
					 		y 		= display.contentHeight - 25,
					 		width  = display.contentWidth,
					 		height = 0,
					 		fontSize = 18,
					 		align = "center"}

		back_text = display.newText(back_text_params)
		back_text:setFillColor(unpack(globalData.BackTextColor))
		frontGroup:insert(back_text)

	end

end

function scene:create( event )
	local sceneGroup = self.view

	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	-- background:setFillColor( 0.2,1.0,0.4 )
	background:setFillColor(0.75)

	-- Input Text Field Title
	local titleTextParams = {text  = "Search Foods",
							 x 	   = display.contentCenterX,
							 y     = 100,
							 width = 250, height = 0,
							 font  = native.systemFont, fontSize = 18,
							 align = "center"}
	local title = display.newText( titleTextParams )
	title:setFillColor( 0 )	-- black

	-- Instructions for Searching Foods
	local search_instruction_text = "• Always check food labels against the allergies tab, even if listed as safe\n\n"
	search_instruction_text = search_instruction_text .. "• Safe foods are always subject to change, check even if you've used a food before\n\n"
	search_instruction_text = search_instruction_text .. "• If it's not listed, or just when in doubt, ask Emma"

	-- Input Text Field Title
	local instructionTextParams = {text  = search_instruction_text,
							 	   x     = display.contentCenterX,
							 	   y     = titleTextParams.y + 100,
							 	   width = 0.9*display.contentWidth, height = 0,
							 	   font  = native.systemFont, fontSize = 18,
							 	   align = "left"}

	local instructions = display.newText( instructionTextParams )
	instructions.anchorY = 0
	instructions:setFillColor( 0 )
	
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( background )
	sceneGroup:insert( title )
	sceneGroup:insert( instructions )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	frontGroup  = display.newGroup()
	
	if phase == "will" then
		myTextField = native.newTextField(display.contentCenterX, 140, 150, 40)
		myTextField:addEventListener("userInput", serachFieldListener)
		sceneGroup:insert(myTextField)
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		if myTextField then
			myTextField:removeSelf()
			myTextField = nil
		end

		frontGroup:removeSelf()
		frontGroup = nil
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	frontGroup:removeSelf()
	frontGroup = nil
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene