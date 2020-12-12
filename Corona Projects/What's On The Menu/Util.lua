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