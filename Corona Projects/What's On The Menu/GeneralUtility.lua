-- Utilities File
local util = {}

-- Print all the elements in a table
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

-- Busy Sleep
function util.sleep(seconds)
	local milliseconds = seconds*1000
	local start_time = system.getTimer()
	local finish_time = start_time + milliseconds
	local finished = false

	while system.getTimer() < finish_time do
		-- print(system.getTimer)
	end

end

-- Return a table containing the sorted keys from an input table
function util.sortTableKeys(table_input, reverse)
	local sorted_keys = {}
	local reverse = reverse or false

	local function stringLessThan(a,b)
		for i = 1,#a,1 do
			if i > #b then
				return(false)
			end

			letter1 = a:sub(i,i):lower()
			letter2 = b:sub(i,i):lower()

			local answer
			if letter1 < letter2 then
				answer =  true

			elseif letter1 > letter2 then
				answer =  false

			elseif i == #a then
				answer = true
			end

			if reverse then
				return not answer
			else
				return answer
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

function util.findID(table_obj, id)

	if table_obj.numChildren then
		table_length = table_obj.numChildren
	else
		table_length = #table_obj
	end

	for i = 1,table_length,1 do
		if table_obj[i].id == id then
			return(table_obj[i])
		end
	end
end


return util
