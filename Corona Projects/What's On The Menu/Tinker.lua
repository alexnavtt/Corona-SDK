tinker = {}
local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

tinker.newTextField 	= require("Tinker.tinker_text_field")
tinker.newButton 		= require("Tinker.tinker_button")
tinker.newDot 			= require("Tinker.tinker_dot")
tinker.numericKeyboard 	= require("Tinker.tinker_numeric_keyboard")

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


function tinker.printTable(T)
	print("------------------------")
	print("----------TABLE---------")
	print("------------------------")
	for key, value in pairs(T) do
		print(key)
		print(value)
		print(" ")
	end
end


function tinker.sleep(seconds)
	local milliseconds = seconds*1000
	local start_time = system.getTimer()
	local finish_time = start_time + milliseconds
	local finished = false

	while system.getTimer() < finish_time do
		-- print(system.getTimer)
	end

end
return tinker