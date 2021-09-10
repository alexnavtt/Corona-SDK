local util = {}

function util.time()
	return os.time(os.date('*t'))
end

function util.timeElapsed(time)
	return util.time() - time
end

-- Busy Sleep - Never use
function util.sleep(seconds)
	local milliseconds = seconds*1000
	local start_time = system.getTimer()
	local finish_time = start_time + milliseconds
	local finished = false

	while system.getTimer() < finish_time do
		-- print(system.getTimer)
	end

end

return util
