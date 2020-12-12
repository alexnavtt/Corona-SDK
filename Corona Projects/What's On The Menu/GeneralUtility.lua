-- Utilities File
local util = {}

function util.printTable(T)
	print("------------------------")
	print("----------TABLE---------")
	print("------------------------")
	for key, value in pairs(T) do
		print(key)
		print(value)
		print(" ")
	end
end

function util.sleep(seconds)
	local milliseconds = seconds*1000
	local start_time = system.getTimer()
	local finish_time = start_time + milliseconds
	local finished = false

	while system.getTimer() < finish_time do
		-- print(system.getTimer)
	end

end

function util.sortTableKeys(table_input)
	local sorted_keys = {}

	local function stringLessThan(a,b)
		for i = 1,#a,1 do
			if i > #b then
				return(false)
			end

			letter1 = a:sub(i,i):lower()
			letter2 = b:sub(i,i):lower()

			if letter1 < letter2 then
				return true

			elseif letter1 > letter2 then
				return false

			elseif i == #a then
				return true
			end
		end
	end

	for foodname, value in pairs(table_input) do
		table.insert(sorted_keys, foodname)
	end

	for i = 1,#sorted_keys,1 do
		local switch_count = 0

		for j = 2,#sorted_keys,1 do
			if stringLessThan(sorted_keys[j], sorted_keys[j-1]) then
				local temp_var = sorted_keys[j]
				sorted_keys[j] = sorted_keys[j-1]
				sorted_keys[j-1] = temp_var

				switch_count = switch_count + 1
			end
		end

		if switch_count == 0 then
			break
		end
	end

	return sorted_keys
end


return util
