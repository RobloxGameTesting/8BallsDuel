local _ = { DefaultRateLimiterRate = 120 }

local RateLimiter = { Default = nil }

local Players = game:GetService("Players")

local v = {}
local v2 = {}

local class = {}

class.__index = class

function class:CheckRate(player): boolean
	local sources = self._sources
	local now = os.clock()

	local source = sources[player]

	if source == nil then
		if typeof(player) == "Instance" and player:IsA("Player") and v[player] == nil then
			return false
		end

		sources[player] = now + self._rate_period
		return true
	else
		local v3 = math.max(now, source + self._rate_period)

		if v3 - now < 1 then
			sources[player] = v3
			return true
		end

		return false
	end
end

function class:CleanSource(p)
	self._sources[p] = nil
end

function class:Cleanup()
	self._sources = {}
end

function class.Destroy(p)
	v2[p] = nil
end

function RateLimiter.NewRateLimiter(p)
	if p <= 0 then
		error("[RateLimiter]: Invalid rate")
	end

	local rateLimiter = {
		_sources = {},
		_rate_period = 1 / p
	}

	setmetatable(rateLimiter, class)

	v2[rateLimiter] = true

	return rateLimiter
end

for _, v3 in ipairs(Players:GetPlayers()) do
	v[v3] = true
end

RateLimiter.Default = RateLimiter.NewRateLimiter(120)

Players.PlayerAdded:Connect(function(player)
	v[player] = true
end)

Players.PlayerRemoving:Connect(function(player)
	v[player] = nil

	for k in pairs(v2) do
		k._sources[player] = nil
	end
end)

return RateLimiter