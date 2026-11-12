local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)

local PoolAchievements = {}

local isServer = RunService:IsServer()

local function count(p) -- 5 equivalent calls inferred from this helper
	local v = tonumber(p)

	if v and v == v and v ~= 1e999 then
		return (math.max(math.floor(v), 0))
	end

	return 0
end

local function field(p, p2: string, p3: string) -- 5 equivalent calls inferred from this helper
	local v

	if typeof(p) == "table" then
		v = p[p2]
	end

	if typeof(v) ~= "table" then
		return 0
	end

	return count(v[p3]) -- inferred equivalent call
end

local function wins(p)
	return field(p, "poolStats", "wins") -- inferred equivalent call
end

local function games(p)
	return field(p, "poolStats", "wins") + field(p, "poolStats", "losses") -- inferred equivalent call
end

local function balls(p)
	return field(p, "poolLifetime", "ballsPotted") -- inferred equivalent call
end

local function botLevels() -- 1 equivalent call inferred from this helper
	local ids = {}

	for _, level in PoolConstants.Bots.Levels do
		table.insert(ids, level.Id)
	end

	return ids
end

local function botsBeaten(p)
	local poolBotWins

	if typeof(p) == "table" then
		poolBotWins = p.poolBotWins
	end

	local v = 0

	if typeof(poolBotWins) ~= "table" then
		return 0
	end

	local ids = botLevels() -- inferred equivalent call

	for k, v2 in ids do
		if count(poolBotWins[v2]) > 0 then -- inferred equivalent call
			v = k
		end
	end

	return v
end

local function trickshotLevel(p)
	local poolLevels

	if typeof(p) == "table" then
		poolLevels = p.poolLevels
	end

	local v = 0

	if typeof(poolLevels) ~= "table" then
		return 0
	end

	for k, poolLevel in poolLevels do
		local v2 = tonumber(k)

		if v2 and count(poolLevel) > 0 and v < v2 then -- inferred equivalent call
			v = math.floor(v2)
		end
	end

	return v
end

local function published(p): number
	if field(p, "poolLifetime", "trickshotsPublished") > 0 then -- inferred equivalent call
		return 1
	end

	return 0
end

local function robuxGifted(p, p2: number?)
	local purchases

	if typeof(p) == "table" then
		purchases = p.purchases
	end

	local total = 0

	if typeof(purchases) ~= "table" then
		return 0
	end

	for _, purchas in purchases do
		if typeof(purchas) ~= "table" or purchas.bought ~= true or purchas.giftRefused then
			continue
		end

		local data = purchas.data
		local data2

		if typeof(data) == "table" then
			data2 = data.data
		end

		local v

		if typeof(data2) == "table" then
			v = data2[1]
		end

		if not ((typeof(v) == "string" or typeof(v) == "number") and tostring(v) ~= tostring(p2)) then
			continue
		end

		total += count(purchas.cost) -- inferred equivalent call
	end

	return total
end

local function botTiers()
	local v = { 5, 10, 20, 35, 50, 100 }
	local result = {}

	for k, level in PoolConstants.Bots.Levels do
		table.insert(result, {
			Goal = k,
			Gems = v[k] or v[#v],
			Label = string.upper((tostring(level.Name or level.Id)))
		})
	end

	return result
end

PoolAchievements.List = {
	{
		Id = "Wins",
		Name = "Winner",
		Icon = "🏆",
		Text = "Win %s online matches",
		TextOne = "Win your first online match",
		Tiers = {
			{ Goal = 1, Gems = 5 },
			{ Goal = 10, Gems = 10 },
			{ Goal = 50, Gems = 20 },
			{ Goal = 100, Gems = 35 },
			{ Goal = 250, Gems = 50 },
			{ Goal = 500, Gems = 75 },
			{ Goal = 1000, Gems = 100 },
			{ Goal = 2500, Gems = 150 }
		},
		Read = wins
	},
	{
		Id = "Games",
		Name = "Regular",
		Icon = "🎱",
		Text = "Play %s online matches",
		Tiers = {
			{ Goal = 5, Gems = 5 },
			{ Goal = 25, Gems = 10 },
			{ Goal = 100, Gems = 20 },
			{ Goal = 250, Gems = 35 },
			{ Goal = 500, Gems = 50 },
			{ Goal = 1000, Gems = 75 },
			{ Goal = 2500, Gems = 100 },
			{ Goal = 5000, Gems = 150 }
		},
		Read = games
	},
	{
		Id = "Balls",
		Name = "Sharpshooter",
		Icon = "🎯",
		Text = "Pocket %s balls in online matches",
		Tiers = {
			{ Goal = 25, Gems = 5 },
			{ Goal = 100, Gems = 10 },
			{ Goal = 500, Gems = 20 },
			{ Goal = 1000, Gems = 35 },
			{ Goal = 2500, Gems = 50 },
			{ Goal = 5000, Gems = 75 },
			{ Goal = 10000, Gems = 100 },
			{ Goal = 25000, Gems = 150 }
		},
		Read = balls
	},
	{
		Id = "Bots",
		Name = "Bot Slayer",
		Icon = "🤖",
		Text = "Beat the %s bot",
		Tiers = botTiers(),
		Read = botsBeaten
	},
	{
		Id = "TrickshotLevel",
		Name = "Trickshot Climber",
		Icon = "⭐",
		Text = "Clear trickshot level %s",
		Tiers = {
			{ Goal = 5, Gems = 5 },
			{ Goal = 10, Gems = 10 },
			{ Goal = 25, Gems = 20 },
			{ Goal = 50, Gems = 35 },
			{ Goal = 100, Gems = 50 },
			{ Goal = 200, Gems = 75 },
			{ Goal = 300, Gems = 100 },
			{ Goal = 500, Gems = 150 }
		},
		Read = trickshotLevel
	},
	{
		Id = "CreateTrickshot",
		Name = "Creator",
		Icon = "🛠",
		Text = "Create a trickshot and publish it to Community",
		Tiers = {
			{ Goal = 1, Gems = 25 }
		},
		Read = published
	},
	{
		Id = "GiftRobux",
		Name = "Generous",
		Icon = "🎁",
		Text = "Gift %s Robux to other players",
		Tiers = {
			{ Goal = 25, Gems = 10 },
			{ Goal = 100, Gems = 25 },
			{ Goal = 500, Gems = 50 },
			{ Goal = 1000, Gems = 100 },
			{ Goal = 2500, Gems = 150 },
			{ Goal = 5000, Gems = 250 }
		},
		Read = robuxGifted
	}
}

local v = {}

for _, item in PoolAchievements.List do
	v[item.Id] = item
end

PoolAchievements.TierColours = {
	Color3.fromRGB(196, 122, 66),
	Color3.fromRGB(176, 188, 204),
	Color3.fromRGB(255, 200, 56),
	Color3.fromRGB(96, 222, 206),
	Color3.fromRGB(110, 170, 255),
	Color3.fromRGB(236, 72, 96),
	Color3.fromRGB(70, 214, 110),
	Color3.fromRGB(188, 98, 255)
}

function PoolAchievements.Get(p: string)
	return v[p]
end

function PoolAchievements.TierColour(value: number)
	local tierColours = PoolAchievements.TierColours

	return tierColours[math.clamp(value, 1, #tierColours)]
end

function PoolAchievements.Numeral(p: number)
	return ({
		"I",
		"II",
		"III",
		"IV",
		"V",
		"VI",
		"VII",
		"VIII",
		"IX",
		"X"
	})[p] or tostring(p)
end

function PoolAchievements.Describe(p, p2)
	if p2.Goal == 1 and not p2.Label and p.TextOne then
		return p.TextOne
	end

	if not string.find(p.Text, "%%s") then
		return p.Text
	end

	local label = p2.Label or string.format("%d", p2.Goal):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")

	return string.format(p.Text, label)
end

function PoolAchievements.Claimed(p, p2: string)
	local poolAchievements

	if typeof(p) == "table" then
		poolAchievements = p.poolAchievements
	end

	if typeof(poolAchievements) ~= "table" then
		return 0
	end

	return count(poolAchievements[p2]) -- inferred equivalent call
end

function PoolAchievements.Status(p, p2: string, p3: number?)
	local v2 = v[p2]

	if not v2 then
		return {
			Value = 0,
			Claimed = 0,
			Reached = 0,
			Claimable = false,
			Next = nil,
			Done = true
		}
	end

	local v3 = v2.Read(p, p3)
	local claimed = math.min(PoolAchievements.Claimed(p, p2), #v2.Tiers)
	local reached = 0

	for k, tier in v2.Tiers do
		if tier.Goal <= v3 then
			reached = k
		end
	end

	local tier = v2.Tiers[claimed + 1]

	return {
		Value = v3,
		Claimed = claimed,
		Reached = reached,
		Claimable = tier ~= nil and tier.Goal <= v3,
		Next = tier,
		Done = tier == nil
	}
end

function PoolAchievements.CountClaimable(p, p2: number?)
	local total = 0

	for _, item in PoolAchievements.List do
		local status = PoolAchievements.Status(p, item.Id, p2)

		if status.Claimable then
			total += math.max(status.Reached - status.Claimed, 1)
		end
	end

	return total
end

function PoolAchievements.Claim(p: number, value)
	if not isServer then
		return nil, "Server only"
	end

	local v2

	if typeof(value) == "string" then
		v2 = v[value]
	end

	if not v2 then
		return nil, "That achievement doesn't exist"
	end

	local PoolPlayerData = require(Pool.PoolPlayerData)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica or typeof(replica.Data) ~= "table" then
		return nil, "Your data hasn't loaded yet, try again!"
	end

	local status = PoolAchievements.Status(replica.Data, v2.Id, p)
	local nextNode = status.Next

	if status.Claimable and nextNode then
		local tier = status.Claimed + 1

		replica:Write("PoolAchievementClaim", v2.Id, tier)
		PoolPlayerData.AddGems(p, nextNode.Gems)

		return { Id = v2.Id, Name = v2.Name, Tier = tier, Gems = nextNode.Gems }, nil
	else
		local v3 = nil

		if status.Done then
			return v3, "Already claimed!"
		end

		return v3, "Not reached yet, keep going!"
	end
end

return PoolAchievements