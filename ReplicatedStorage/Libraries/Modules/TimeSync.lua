local HttpService = game:GetService("HttpService")
game:GetService("RunService")

local v = {
	Jan = 1,
	Feb = 2,
	Mar = 3,
	Apr = 4,
	May = 5,
	Jun = 6,
	Jul = 7,
	Aug = 8,
	Sep = 9,
	Oct = 10,
	Nov = 11,
	Dec = 12
}

local flag = false
local v2 = nil
local now = nil
local v3 = nil

local function _RFC2616DateStringToUnixTimestamp(date)
	local match, v4, year, hour, min, sec = date:match(".*, (.*) (.*) (.*) (.*):(.*):(.*) .*")
	local v5 = {
		day = match,
		month = v[v4],
		year = year,
		hour = hour,
		min = min,
		sec = sec
	}

	return os.time(v5)
end

local function _inited()
	return flag
end

local function _init()
	if flag then
		return
	end

	local success, result = pcall(function()
		local now2 = tick()
		v2 = _RFC2616DateStringToUnixTimestamp(HttpService:RequestAsync({
			Url = "http://google.com"
		}).Headers.date)
		now = tick()
		v3 = (now - now2) / 2
	end)

	if not success then
		warn(result)
		v2 = os.time()
		now = tick()
		v3 = 0
	end

	flag = true
end

local function _time()
	_init()

	return v2 + tick() - now - v3
end

return { inited = _inited, init = _init, time = _time }