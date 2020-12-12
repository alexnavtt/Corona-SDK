local math_util = {}

function math_util.getFraction(number)

	if number <= 0 then
		return "0"
	end

	local integer_value = number - (number % 1)
	local decimal_value = number - integer_value

	-- Try to use large denominators at first, allow smaller if it doesn't work
	local allowable_denom_table = {{4,3,2},{16,8,4,3,2}}


	for allowable_denominators = 1,2,1 do
		local denominator = 1
		local denom_table = allowable_denom_table[allowable_denominators]
		local min_error = 1e6

		local error_value
		for i = 1,#denom_table,1 do
			local fraction_value = math.round(decimal_value/(1/denom_table[i]))
			error_value = math.abs((integer_value + fraction_value/denom_table[i]) - number)
			if error_value <= min_error then
				denominator = denom_table[i]
				min_error = error_value
			end
		end

		local final_fraction_value = math.round(decimal_value/(1/denominator))
		if final_fraction_value == denominator then
			final_fraction_value = 0
			integer_value = integer_value + 1
		end

		local string_number = ""

		if integer_value > 0 then
			string_number = string_number .. integer_value
		end

		if final_fraction_value > 0 then
			if string_number == "" then
				string_number = string_number .. final_fraction_value .. "/" .. denominator
			else
				string_number = string_number .. " " .. final_fraction_value .. "/" .. denominator
			end
		end

		if string_number == "" then string_number = "0" end

		if error_value < 1e-2 or allowable_denominators == 2 then
			return string_number
		end

	end

	return string.format("%.2f",number)
end

function math_util.breakdownFraction(string_number)

	if #string_number == 1 and tonumber(string_number) then
		return string_number, "0", "1"
	end


	local has_integer = false
	local space_index = 0

	local has_fraction = false
	local divide_index = 0

	for i = 1,#string_number,1 do
		if string_number:sub(i,i) == " " then
			has_integer = true
			space_index = i
		
		elseif string_number:sub(i,i) == "/" then
			has_fraction = true
			divide_index = i
		end
	end

	local integer; local numerator; local denominator;

	if has_fraction and has_integer then
		integer = string_number:sub(1,space_index-1)
		numerator = string_number:sub(space_index+1,divide_index-1)
		denominator = string_number:sub(divide_index+1)

	elseif has_integer then
		integer = string_number:sub(1,space_index-1)
		numerator = "0"
		denominator = "1"

	elseif has_fraction then
		integer = "0"
		numerator = string_number:sub(1,divide_index-1)
		denominator = string_number:sub(divide_index+1)
	end

	return integer, numerator, denominator

end

return math_util
