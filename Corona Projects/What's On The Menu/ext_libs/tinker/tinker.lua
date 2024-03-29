local tinker = {}
local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY


function tinker.initialize(path)
	tinker.newTextField 	= require(path .. ".tinker.tinker_text_field")
	tinker.newButton 		= require(path .. ".tinker.tinker_button")
	tinker.newDot 			= require(path .. ".tinker.tinker_dot")
	tinker.numericKeyboard 	= require(path .. ".tinker.tinker_numeric_keyboard")
	tinker.newCheckBox 		= require(path .. ".tinker.tinker_check_box")
	tinker.newDotSwitch     = require(path .. ".tinker.tinker_dot_switch")
	tinker.newSlidingSwitch = require(path .. ".tinker.tinker_slide_switch")

	function tinker.glass_screen(auto_destroy, group)
		local glass_screen = display.newRect(Cx, Cy,2* W, 2*H)
		glass_screen:setFillColor(1,1,1,0.01)

		function glass_screen:tap(event) 
			if auto_destroy then
				glass_screen:removeSelf()

				if group then 
					for i = 1,group.numChildren,1 do
						group:remove(1)
					end
				end
			end
			return true 
		end
		function glass_screen:touch(event) return true end

		glass_screen:addEventListener("tap", glass_screen)
		glass_screen:addEventListener("touch", glass_screen)

		return glass_screen
	end
end


return tinker