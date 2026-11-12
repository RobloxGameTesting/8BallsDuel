local DateHelper = {}

function DateHelper.IsWeekendUTCAligned(_): boolean
	local v = os.date("!*t", os.time())
	local wday = v.wday
	local hour = v.hour

	return wday == 6 and hour >= 18 or wday == 7 or wday == 1 and hour < 24
end

function DateHelper.GetWeekKey(_, value: number?)
	local v = os.date("!*t", os.time() + (value or 0))
	v.day -= v.wday - 1
	v.hour = 0
	v.min = 0
	v.sec = 0
	return (tostring(os.time(v)))
end

function DateHelper.GetDayKey(_, value: number?)
	local v = os.date("!*t", os.time() + (value or 0))
	v.hour = 0
	v.min = 0
	v.sec = 0
	return (tostring(os.time(v)))
end

return DateHelper