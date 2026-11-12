local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Modules.Profiles)

local v = {
	{
		{ writeLib = "Currency1", value = 1111 }
	},
	{
		{ writeLib = "Currency1", value = 2222 }
	},
	{
		{ writeLib = "Currency1", value = 3333 }
	}
}

local v2 = {
	{ writeLib = "Currency1", value = 1 },
	{ writeLib = "Currency1", value = 2 },
	{ writeLib = "Currency1", value = 3 },
	{ writeLib = "Currency1", value = 4 },
	{ writeLib = "Currency1", value = 400 }
}
local SharedConstants = {}
SharedConstants.FRIEND_BOOST = 10
SharedConstants.CRATE_INFO = {
	{
		name = "NORMAL",
		timeToOpen = 7200,
		colour = Color3.fromRGB(117, 255, 96),
		icon = "rbxassetid://116773307482743",
		percentage = 40,
		rewardCount = 3,
		rewards = {
			{ writeLib = "Currency1", value = 500, percentage = 60 },
			{
				writeLib = "Packs",
				packName = "Balls",
				value = 3,
				openOnClaim = false,
				percentage = 10
			},
			{
				writeLib = "Packs",
				packName = "ScoreVFX",
				value = 3,
				openOnClaim = false,
				percentage = 10
			},
			{
				writeLib = "Packs",
				packName = "Limited",
				value = 1,
				openOnClaim = false,
				percentage = 10
			},
			{ writeLib = "Currency1", value = 2500, percentage = 7 },
			{
				writeLib = "Packs",
				packName = "Professional",
				value = 2,
				openOnClaim = false,
				percentage = 3
			}
		}
	},
	{
		name = "PROFESSIONAL",
		timeToOpen = 14400,
		colour = Color3.fromRGB(6, 118, 255),
		icon = "rbxassetid://114637002499136",
		percentage = 30,
		rewardCount = 4,
		rewards = {
			{ writeLib = "Currency1", value = 800, percentage = 60 },
			{
				writeLib = "Packs",
				packName = "ScoreVFX",
				value = 4,
				openOnClaim = false,
				percentage = 9
			},
			{
				writeLib = "Packs",
				packName = "Balls",
				value = 4,
				openOnClaim = false,
				percentage = 9
			},
			{
				writeLib = "Packs",
				packName = "Limited",
				value = 2,
				openOnClaim = false,
				percentage = 9
			},
			{ writeLib = "Professional", value = 2, percentage = 9 },
			{
				writeLib = "Packs",
				packName = "Professional",
				value = 2,
				openOnClaim = false,
				percentage = 4
			}
		}
	},
	{
		name = "PRIME",
		timeToOpen = 21600,
		colour = Color3.fromRGB(255, 142, 3),
		icon = "rbxassetid://122324794269334",
		percentage = 20,
		rewardCount = 5,
		rewards = {
			{ writeLib = "Currency1", value = 1200, percentage = 50 },
			{
				writeLib = "Packs",
				packName = "ScoreVFX",
				value = 5,
				openOnClaim = false,
				percentage = 9
			},
			{
				writeLib = "Packs",
				packName = "Limited",
				value = 1,
				openOnClaim = false,
				percentage = 9
			},
			{
				writeLib = "Packs",
				packName = "Professional",
				value = 1,
				openOnClaim = false,
				percentage = 9
			},
			{ writeLib = "Currency1", value = 3000, percentage = 13 },
			{
				writeLib = "Packs",
				packName = "Professional",
				value = 2,
				openOnClaim = false,
				percentage = 10
			}
		}
	},
	{
		name = "LEGENDARY",
		timeToOpen = 43200,
		colour = Color3.fromRGB(255, 0, 0),
		icon = "rbxassetid://138477190459365",
		percentage = 10,
		rewardCount = 6,
		rewards = {
			{ writeLib = "Currency1", value = 1800, percentage = 45 },
			{
				writeLib = "Packs",
				packName = "Limited",
				value = 2,
				openOnClaim = false,
				percentage = 7
			},
			{
				writeLib = "Packs",
				packName = "Limited",
				value = 3,
				openOnClaim = false,
				percentage = 7
			},
			{
				writeLib = "Packs",
				packName = "Professional",
				value = 2,
				openOnClaim = false,
				percentage = 7
			},
			{
				writeLib = "Packs",
				packName = "Professional",
				value = 3,
				openOnClaim = false,
				percentage = 14
			},
			{
				writeLib = "Packs",
				packName = "Legendary",
				value = 1,
				openOnClaim = false,
				percentage = 20
			}
		}
	}
}

SharedConstants.SERVER_IDS = { ["94450914651792"] = "Main" }
SharedConstants.FRIEND_COOLDOWN = 43200
SharedConstants.MERGE_TIER_COST = 255
SharedConstants.AFK_TIMER = 10
SharedConstants.AFK_REWARDS = {
	{ writeLib = "Currency1", value = 2, percentage = 35 },
	{ writeLib = "Currency1", value = 3, percentage = 30 },
	{ writeLib = "Currency1", value = 4, percentage = 15 },
	{ writeLib = "Currency1", value = 10, percentage = 10 },
	{ writeLib = "BoostCurrency1", value = 120, percentage = 2 },
	{ writeLib = "BoostExp", value = 120, percentage = 2 },
	{ writeLib = "BoostLuck", value = 120, percentage = 2 },
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 1,
		openOnClaim = false,
		percentage = 1
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 1,
		openOnClaim = false,
		percentage = 1
	},
	{
		writeLib = "Packs",
		packName = "Emotes",
		value = 1,
		openOnClaim = false,
		percentage = 1
	},
	{
		writeLib = "Packs",
		packName = "Currency1",
		value = 100,
		openOnClaim = false,
		percentage = 0.6
	},
	{
		writeLib = "Packs",
		packName = "Limited",
		value = 1,
		openOnClaim = false,
		percentage = 0.345
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		percentage = 0.05
	},
	{
		writeLib = "Packs",
		packName = "Legendary",
		value = 1,
		openOnClaim = false,
		percentage = 0.005
	}
}

SharedConstants.FRIEND_REWARDS = {
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 10
	},
	{
		writeLib = "Packs",
		packName = "Limited",
		value = 1,
		openOnClaim = false,
		requirement = 20
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 50
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 1,
		openOnClaim = false,
		requirement = 100
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 150
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 200
	},
	{
		writeLib = "Packs",
		packName = "Emotes",
		value = 1,
		openOnClaim = false,
		requirement = 250
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 300
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 1,
		openOnClaim = false,
		requirement = 350
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 400
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 450
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 1,
		openOnClaim = false,
		requirement = 500
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 550
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 1,
		openOnClaim = false,
		requirement = 600
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 650
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 1,
		openOnClaim = false,
		requirement = 700
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 750
	},
	{
		writeLib = "Packs",
		packName = "Limited",
		value = 1,
		openOnClaim = false,
		requirement = 800
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 850
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 1,
		openOnClaim = false,
		requirement = 900
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 950
	},
	{
		writeLib = "Packs",
		packName = "Emotes",
		value = 1,
		openOnClaim = false,
		requirement = 1000
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1050
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1100
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1150
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 1,
		openOnClaim = false,
		requirement = 1200
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1250
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1300
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 2,
		openOnClaim = false,
		requirement = 1350
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1400
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1450
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 1,
		openOnClaim = false,
		requirement = 1500
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1550
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 1,
		openOnClaim = false,
		requirement = 1600
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1650
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 2,
		openOnClaim = false,
		requirement = 1700
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 2,
		openOnClaim = false,
		requirement = 1750
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 2,
		openOnClaim = false,
		requirement = 1800
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 1,
		openOnClaim = false,
		requirement = 1850
	},
	{
		writeLib = "Packs",
		packName = "Balls",
		value = 4,
		openOnClaim = false,
		requirement = 1900
	},
	{
		writeLib = "Packs",
		packName = "ScoreVFX",
		value = 4,
		openOnClaim = false,
		requirement = 1950
	},
	{
		writeLib = "Packs",
		packName = "Professional",
		value = 2,
		openOnClaim = false,
		requirement = 2000
	}
}

SharedConstants.LEVEL_REWARDS = {
	{ writeLib = "Currency1", value = 100 },
	{ writeLib = "Currency1", value = 100 },
	{ writeLib = "Packs", packName = "Limited", value = 1, openOnClaim = false },
	{ writeLib = "Currency1", value = 150 },
	{ writeLib = "Packs", packName = "Professional", value = 1, openOnClaim = false },
	{ writeLib = "BoostLuck", value = 600 },
	{ writeLib = "Currency1", value = 100 },
	{ writeLib = "Currency1", value = 150 },
	{ writeLib = "Packs", packName = "Balls", value = 1, openOnClaim = false },
	{ writeLib = "Currency1", value = 100 },
	{ writeLib = "Currency1", value = 150 },
	{ writeLib = "SpinWheel", value = 1 },
	{ writeLib = "Packs", packName = "ScoreVFX", value = 1, openOnClaim = false },
	{ writeLib = "Currency1", value = 150 },
	{ writeLib = "Currency1", value = 100 }
}
SharedConstants.DAILY_TIME = 2
SharedConstants.DAILY_CONSECUTIVE_INCREMENT = 3

function SharedConstants.DAILY_REWARD_CALCULATOR(p: number)
	if p % 7 == 0 then
		return v2[p / 7] or v2[#v2]
	end

	return {
		writeLib = "Currency1",
		value = math.clamp((p % 2 == 0 and 10 or 5) * p, 10, 250)
	}
end

SharedConstants.DAILY_REWARDS = v2

function SharedConstants.DAILY_REWARDS_CONSECUTIVE_CALCULATOR(p: number)
	if v[p] then
		return v[p]
	end

	return v[#v]
end

SharedConstants.DAILY_REWARDS_CONSECUTIVE = v
SharedConstants.SPIN_WHEEL_INFO = {
	angle = {
		{ -247.5, -292.5 },
		{ -202.5, -247.5 },
		{ -157.5, -202.5 },
		{ -112.5, -157.5 },
		{ -67.5, -112.5 },
		{ -22.5, -67.5 },
		{ 22.5, -22.5 },
		{ -292.5, -337.5 }
	},
	drops = {
		{ writeLib = "Currency1", value = 500, percentage = 30 },
		{ writeLib = "BoostCurrency1", value = 600, percentage = 20 },
		{ writeLib = "BoostCurrency2", value = 600, percentage = 15 },
		{ writeLib = "BoostExp", value = 600, percentage = 13 },
		{ writeLib = "BoostLuck", value = 600, percentage = 10 },
		{ writeLib = "Currency1", value = 500, percentage = 10 },
		{ writeLib = "Currency1", value = 500, percentage = 5 },
		{ writeLib = "Currency1", value = 500, percentage = 2 }
	}
}

SharedConstants.ID_COLOUR = {
	["Professional"] = Color3.fromRGB(255, 204, 0),
	Limited = Color3.fromRGB(218, 252, 0),
	Legendary = Color3.fromRGB(255, 0, 0),
	Balls = Color3.fromRGB(0, 252, 126),
	ScoreVFX = Color3.fromRGB(0, 252, 126),
	Emotes = Color3.fromRGB(0, 252, 126)
}

SharedConstants.FLAGS = {
	Norway = { icon = "rbxassetid://6131546945", ratio = 1.5 },
	France = { icon = "rbxassetid://13627311079", ratio = 1.5 },
	Croatia = { icon = "rbxassetid://3973692199", ratio = 1.5 },
	Sweden = { icon = "rbxassetid://17758137014", ratio = 1.5 },
	Belgium = { icon = "rbxassetid://6131436884", ratio = 1.5 },
	["United Kingdom"] = { icon = "rbxassetid://6924364912", ratio = 1.5 },
	Argentina = { icon = "rbxassetid://16266993296", ratio = 1.5 },
	Spain = { icon = "rbxassetid://2575712538", ratio = 1.5 },
	Portugal = { icon = "rbxassetid://4652070552", ratio = 1.5 },
	Japan = { icon = "rbxassetid://82331599408797", ratio = 1.5 },
	Brazil = { icon = "rbxassetid://11764667113", ratio = 1.5 },
	Turkey = { icon = "rbxassetid://12221366426", ratio = 1.5 },
	Denmark = { icon = "rbxassetid://11002317530", ratio = 1.5 },
	Armenia = { icon = "rbxassetid://5347642860", ratio = 1.5 },
	Germany = { icon = "rbxassetid://6399522594", ratio = 1.5 },
	Italy = { icon = "rbxassetid://6035305911", ratio = 1.5 },
	Netherlands = { icon = "rbxassetid://4416943607", ratio = 1.5 },
	Egypt = { icon = "rbxassetid://13655467672", ratio = 1.5 },
	Poland = { icon = "rbxassetid://9124778742", ratio = 1.5 },
	Uruguay = { icon = "rbxassetid://6131612060", ratio = 1.5 },
	Slovenia = { icon = "rbxassetid://12221301096", ratio = 1.5 },
	Switzerland = { icon = "rbxassetid://12221326197", ratio = 1 },
	["South Korea"] = { icon = "rbxassetid://7199539762", ratio = 1.5 },
	Nigeria = { icon = "rbxassetid://17260833338", ratio = 1.5 }
}

SharedConstants.SUFFIX = {
	weight = {
		Imperial = "lbs",
		Metric = "kg",
		metricToImperial = function(p: number)
			return NumberHelper:Round(NumberHelper:KilogramToPounds(p), 0, false)
		end
	},
	height = {
		Imperial = "",
		Metric = "cm",
		metricToImperial = function(p: number)
			local centimetersToFeet, v3 = NumberHelper:CentimetersToFeet(p)

			return centimetersToFeet .. "'" .. v3
		end
	},
	spikePower = {
		Imperial = " mph",
		Metric = "km/hr",
		metricToImperial = function(p: number)
			return NumberHelper:Round(NumberHelper:KilometerToMiles(p), 0, false)
		end
	},
	jumpHeight = { Imperial = "", Metric = "" },
	sprintSpeed = { Imperial = "", Metric = "" }
}
return SharedConstants