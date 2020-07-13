local composer 	= require( "composer" )
local scene 	= composer.newScene()
local widget 	= require( "widget" )
local globalData = require("globalData")

local frontGroup

-- Function to Remove Scroll View
local function glassTouchListener( self, event )
	if event.phase == "ended" then
		while frontGroup.numChildren > 0 do
			frontGroup:remove(1)
		end
	end
end

-- Function to load allergy list
local function buttonListener( event, button_id )

	print(button_id)

	-- Options for a scrollable text box
	local scrollOptions = { id 		= "scroll_options",
							x 		= display.contentCenterX,
							y  		= display.contentCenterY,
							width 	= display.contentWidth,
							height 	= display.contentHeight - 100,
							horizontalScrollDisabled = false,
							hideScrollBar = false}

	local scrollObject = widget.newScrollView( scrollOptions )

	-- Create "back" button to close result display
	local backBar = display.newRect(display.contentCenterX, display.contentHeight - 25, display.contentWidth, 50)
	backBar:setFillColor( 0.8 )
	backBar.touch = glassTouchListener
	backBar:addEventListener("touch", backBar)

	back_text_params = {text = "Done",
						x = display.contentCenterX,
						y = display.contentHeight - 25,
						fontSize = 18}
	back_text = display.newText(back_text_params)
	back_text:setFillColor(unpack(globalData.BackTextColor))

	-- Set up result text
	result_text = {"","","","",""}
	severity_descriptions = {"Discomfort","Pain","Pain and Asthma","Possible Anaphylaxis","Anaphylactic Shock"}

	for fields, severity in pairs(globalData.Allergies[button_id]) do
		index = tonumber(severity)
		result_text[index] = result_text[index] .. fields .. '\n'
	end

	local current_text_pos = 10

	local function setAllergyText(index)
		label_params = {text = severity_descriptions[index], 
						x = display.contentCenterX, 
						y = current_text_pos, 
						font = native.systemFontBold, 
						fontSize = 20, 
						align = "center"}
		label = display.newText(label_params)
		label:setFillColor(0)
		label.anchorY = 0

		current_text_pos = current_text_pos + label.height + 5

		allergy_params = {text = result_text[index],
						  x = display.contentCenterX,
						  y = current_text_pos,
						  fontSize = label.size - 2,
						  align = "center"}
		allergy_list = display.newText(allergy_params)
		allergy_list:setFillColor(0)
		allergy_list.anchorY = 0

		current_text_pos = current_text_pos + allergy_list.height + 10

		scrollObject:insert(label)
		scrollObject:insert(allergy_list)
	end

	print(unpack(result_text))

	frontGroup:insert(scrollObject)
	frontGroup:insert(backBar)
	frontGroup:insert(back_text)

	for index = 5,1,-1 do
		if result_text[index] ~= "" then
			setAllergyText(index)
		end
	end
end

function scene:create( event )
	local sceneGroup = self.view
	frontGroup = display.newGroup()
	
	local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentHeight - 50, display.contentWidth)
	background.x = display.contentCenterX
	background.y = display.contentCenterY + 25
	background.rotation = 90
	-- background:setFillColor(0.2,1.0,0.4)
	background:setFillColor( 0.75 )

	-- Create Title Text
	local title = display.newText( "List of Allergies", display.contentCenterX, 50 + 40, native.systemFont, 32 )
	title:setFillColor( 0 )	-- black

	-- Create Vegetable Allergies Button
	local veggie_options = {id = "veggie",
							x = 0.25*display.contentWidth,
							y = 50 + 0.35*(display.contentHeight - 50),
							labelYOffset = 0.25*(display.contentWidth - 50),
							onPress = function(e) buttonListener(e,"FruitAndVeg")end,
							label = "Fruit and Veggies",
							defaultFile = "Transparent Veggies Medium.png"}
	local veggie_button = widget.newButton(veggie_options)

	-- Create Diary and Nuts Allergies Button
	local dairy_options = {id = "dairy",
						   x  = 0.75*display.contentWidth,
						   y  = 50 + 0.35*(display.contentHeight - 50),
						   labelYOffset = 0.25*(display.contentWidth - 50),
						   onPress = function(e) buttonListener(e,"DairyAndNuts") end,
						   label = "Dairy and Nuts",
						   defaultFile = "Transparent Veggies Medium.png"}
	local dairy_button = widget.newButton(dairy_options)

	-- Create Seasoning Allergies Button
	local seasoning_options = {id = "seasoning",
						   x  = 0.25*display.contentWidth,
						   y  = 50 + 0.75*(display.contentHeight - 50),
						   labelYOffset = 0.25*(display.contentWidth - 50),
						   onPress = function(e) buttonListener(e,"Seasonings") end,
						   label = "Seasonings",
						   defaultFile = "Transparent Veggies Medium.png"}
	local seasoning_button = widget.newButton(seasoning_options)

	-- Create Diary and Nuts Allergies Button
	local caution_options = {id = "caution",
						   x  = 0.75*display.contentWidth,
						   y  = 50 + 0.75*(display.contentHeight - 50),
						   labelYOffset = 0.25*(display.contentWidth - 50),
						   onPress = function(e) buttonListener(e,"Caution") end,
						   label = "Caution Foods",
						   defaultFile = "Transparent Veggies Medium.png"}
	local caution_button = widget.newButton(caution_options)

	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert(background)
	sceneGroup:insert(title)
	sceneGroup:insert(veggie_button)
	sceneGroup:insert(dairy_button)
	sceneGroup:insert(seasoning_button)
	sceneGroup:insert(caution_button)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
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
		while frontGroup.numChildren > 0 do
			frontGroup:remove(1)
		end
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	
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
