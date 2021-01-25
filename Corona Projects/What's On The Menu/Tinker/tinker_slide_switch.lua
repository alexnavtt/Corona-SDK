local transition = require("transition")

local H = display.contentHeight
local W = display.contentWidth
local Cx = display.contentCenterX
local Cy = display.contentCenterY

local function newSlidingSwitch(x, y, params)
	params = params or {}

	-- Read input parameters
	local width        = params.width          or (0.05*W)
	local height       = params.height         or (0.65*width)
	local radius       = params.radius         or (0.5*height)
	local onColor      = params.onColor        or {0.3, 0.8, 0.3}
	local offColor     = params.offColor       or {0.5}
	local defaultState = params.defaultState   or "off"
	local touchScale   = params.touchScale     or 1
	local tap_func     = params.tap_func       or function(event) return true end
	local displayGroup = params.displayGroup

	-- Create a display group to be the switch
	local group = display.newGroup()
	if displayGroup then displayGroup:insert(group) end
	group.anchorChildren = true
	group.x = x
	group.y = y
	group.id = "Tinker_Sliding_Switch"

	-- The "ON" background to the switch
	local on_bkgd = display.newRoundedRect(group, 0, 0, width, height, 0.5*height)
	on_bkgd:setFillColor(unpack(onColor))

	-- The "OFF" background to the switch
	local off_bkgd = display.newRoundedRect(group, 0, 0, width, height, 0.5*height)
	off_bkgd:setFillColor(unpack(offColor))

	-- Set the parameters of the switch
	if defaultState == "off" then
		group._state = 0
		on_bkgd.alpha = 0
	else 
		group._state = 1
		off_bkgd.alpha = 0
	end

	local tappable_area = display.newRect(group, 0, 0, touchScale*width, touchScale*height)
	tappable_area.isVisible = false
	tappable_area.isHitTestable = true

	-- The sliding portion of the switch
	local switch = display.newCircle(group, -0.25*width + group._state*0.5*width, 0, radius)

	function group:tap(event)
		-- Update group's state
		group._state = 1 - group._state

		-- Animate switching motion
		local dt = 150
		if group._state == 1 then
			transition.to(switch, {x = 0.25*width, time = dt})
			transition.to(on_bkgd,  {alpha = 1, time = dt})
			transition.to(off_bkgd, {alpha = 0, time = dt})
		else
			transition.to(switch, {x = -0.25*width, time = dt})
			transition.to(on_bkgd,  {alpha = 0, time = dt})
			transition.to(off_bkgd, {alpha = 1, time = dt})
		end
		return true
	end

	group:addEventListener("tap", group)
	group:addEventListener("tap", tap_func)

	function group:getState()
		return group._state
	end

	return group

end

return newSlidingSwitch
