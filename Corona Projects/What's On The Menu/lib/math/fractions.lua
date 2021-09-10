local fractions = {}

--- Takes in a numeric value and outputs the string representation of that number in mixed fraction form
---
---     > The output fraction will be a multiple of either 1/4 or 1/3, with the exception of 1/8 for small values
---     > If the number is too small to be represented as a fraction, a decimal representation will return instead
---@param number  number
---@return string
function fractions.getFraction(number)
    -- If the number is negative, store negative sign and make number positive
    local sign = ""
    if number < 0 then
        sign = "-"
        number = number * -1
    end

    -- If the number is too small, just return it as a decimal value
    if number <= 1/16 then
        return sign .. string.format("%.2f", number)
    end

    -- Get the integer portion of the number
    local fraction_part = number % 1
    local integer_part  = number - fraction_part

    -- Test increasing values in 24ths
    local last_error = 1
    local numerators   = {0, 1, 1, 1, 1, 2, 3, 99}
    local denominators = {1, 8, 4, 3, 2, 3, 4, 100}
    local idx = 1
    for i = 1,#numerators,1 do
        local val = numerators[i]/denominators[i]
        local error = math.abs(val - fraction_part) 
        if error < last_error then
            last_error = error
            idx = i
        else
            break
        end
    end

    -- Determine if we need to round up
    if numerators[idx] == 99 then
        integer_part    = integer_part + 1
        numerators[idx] = 0
    end

    local integer_string  = ""
    local fraction_string = ""
    local part_count = 0

    -- Remove the integer part if it does not exist
    if integer_part > 0 then
        integer_string = tostring(integer_part)
        part_count = part_count + 1
    end

    -- Remove the fraction part if it does not exist
    if numerators[idx] ~= 0 then
        fraction_string = tostring(numerators[idx]) .. "/" .. tostring(denominators[idx])
        part_count = part_count + 1
    end

    local space = ""
    if part_count == 2 then space = " " end

    return sign .. integer_string .. space .. fraction_string
end



--- Convert a string fraction into a numeric value
---
---     > The input string can have at most one space (" ") character
---     > The input character can have at most one divide ("/") character
---@param fraction_string  string
---@return number
function fractions.breakdownFraction(fraction_string)
    if #fraction_string == 1 and tonumber(fraction_string) then
		return fraction_string, "0", "1"
	end


	local has_integer = false
	local space_index = 0

	local has_fraction = false
	local divide_index = 0

	for i = 1,#fraction_string,1 do
		if fraction_string:sub(i,i) == " " then
			has_integer = true
			space_index = i
		
		elseif fraction_string:sub(i,i) == "/" then
			has_fraction = true
			divide_index = i
		end
	end

	local integer; local numerator; local denominator;

	if has_fraction and has_integer then
		integer = fraction_string:sub(1,space_index-1)
		numerator = fraction_string:sub(space_index+1,divide_index-1)
		denominator = fraction_string:sub(divide_index+1)

	elseif has_integer then
		integer = fraction_string:sub(1,space_index-1)
		numerator = "0"
		denominator = "1"

	elseif has_fraction then
		integer = "0"
		numerator = fraction_string:sub(1,divide_index-1)
		denominator = fraction_string:sub(divide_index+1)
	end

	return integer, numerator, denominator
end

return fractions
