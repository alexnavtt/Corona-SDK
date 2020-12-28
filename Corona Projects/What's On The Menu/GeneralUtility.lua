-- Utilities File
local util = {}

-- Print all the elements in a table
function util.printTable(T, recursive, level)
	
	if not level then level = 0 end
	local indent = string.rep("...", level)

	for key, value in pairs(T) do
		print(" ")
		print(indent .. key)
		if type(value) == "table" and recursive then
			util.printTable(value, true, level + 1)
		elseif recursive then
			print(indent .. value)
		else
			print(value)
		end
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

function util.tableEquals(T1, T2)
	if T1 == T2 then return true end
	if not (type(T1) == "table" and type(T2) == "table") then return false end

	for key, value in pairs(T1) do
		if type(value) == "table" then
			-- Check for recrusive reference
			if value == T2 or value == T1 then return false end

			-- Recursively check equality
			if not util.tableEquals(T2[key], value) then
				return false
			end

		else
			-- Compare non-table values directly
			if not (value == T2[key]) then
				return false
			end
		end
	end
	return true
end

function util.time()
	return os.time(os.date('*t'))
end

function util.timeElapsed(time)
	return util.time() - time
end


return util
