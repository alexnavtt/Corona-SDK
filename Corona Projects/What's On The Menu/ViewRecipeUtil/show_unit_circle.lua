local cookbook = require("cookbook")
local globalData = require("globalData")
local app_colors = require("AppColours")
local transition = require("transition")

local function showUnitCircle(unit, amount_text, amount, foodname)
	if unit == "" or unit:lower() == "count" then return false end

	local labels = {}
	if cookbook.volumes[unit:lower()] then
		labels = {'Cup', 'Tsp', 'Tbsp', 'Fl oz', 'mL'}

		if cookbook.densities[foodname:lower()] then
			table.insert(labels, "g")
			table.insert(labels, "oz")
			table.insert(labels, 'lb')
		end

	elseif cookbook.masses[unit:lower()] then
		labels = {}

		if cookbook.densities[foodname:lower()] then
			table.insert(labels, "Cup")
			table.insert(labels, "Tsp")
			table.insert(labels, "Tbsp")
			table.insert(labels, "Fl oz")
			table.insert(labels, "mL")
		end

		table.insert(labels, "g")
		table.insert(labels, "oz")
		table.insert(labels, 'lb')
	end

	local group = display.newGroup()
	group.x = 0
	group.y = 0

	local iter = 1
	local function spawnDot(event)
		local label
		local new_unit = labels[iter]
		local new_amount = cookbook.convertUnit(amount, unit, new_unit, foodname)

		if new_unit == "Fl oz" or new_unit == "oz" or new_unit == "g" or new_unit == "mL" then
			label = (new_amount - new_amount % 1) .. "\n" .. new_unit

			if label:sub(1,1) == "0" then
				label = string.format("%.2f", new_amount) .. "\n" .. new_unit
			end
		elseif new_unit == "lb" or new_unit == "kg" then
			label = string.format("%.2f", new_amount) .. "\n" .. new_unit
		else
			label = cookbook.getFraction(new_amount) .. "\n" .. new_unit
		end

		local function replaceText(event)
			amount_text.text = label
			group:removeSelf()
			return true
		end

		local params = {displayGroup = group, color = app_colors.recipe.title_bkgd, label = label, hasShadow = true, tap_func = replaceText, labelColor = app_colors.recipe.ing_text}
		local offset = 0.35*display.contentWidth
		local x =  offset*math.sin((iter-1)*2*math.pi/#labels)
		local y = -offset*math.cos((iter-1)*2*math.pi/#labels)
		local dot = tinker.newDot(0,0,0.07*display.contentWidth, params)

		transition.to(dot, {time = 200, x = x, y = y})
		iter = iter + 1
	end

	local function spawnLabel(event)
		local foodname = foodname

		for i =1,foodname:len(),1 do
			if foodname:sub(i,i) == " " or foodname:sub(i,i) == "/" then
				foodname = foodname:sub(1,i) .. "\n" .. foodname:sub(i+1)
			end
		end

		local params = {displayGroup = group, color = app_colors.recipe.title_bkgd, label = foodname, hasShadow = true, labelColor = app_colors.recipe.ing_text, tap_func = function(event) return true end}
		local offset = 0.35*display.contentWidth
		local dot = tinker.newDot(0,0,0.1*display.contentWidth, params)
	end

	spawnLabel()
	spawnDot()
	timer_handle = timer.performWithDelay(50, spawnDot, #labels-1)

	local glass_screen = display.newRect(group, 0,0,2*display.contentWidth, 2*display.contentHeight)
	glass_screen:setFillColor(0,0,0,0.3)
	glass_screen:toBack()
	glass_screen:addEventListener("tap", function(event) group:removeSelf(); timer.cancel(timer_handle); return true end)

	return group
end

return showUnitCircle
