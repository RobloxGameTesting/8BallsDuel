local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.Types)

return {
	backgroundImage = "rbxassetid://128242291793809",
	backgroundColour = Color3.fromRGB(153, 255, 153),
	eventButtonImage = {
		select = "rbxassetid://124890108983704",
		deselect = "rbxassetid://124890108983704"
	},
	textGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(123, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 255, 0))
	}),
	buttonGradientId = "green",
	missionRefreshRate = 43200,
	weeklyRefreshRate = 604800,
	ultraPassTable = "PoolTable11",
	eventStart = 0,
	eventEnd = 1793502000,
	eventName = "8 BALL SEASON 1",
	datastoreKey = script.Name,
	datastoreValue = {
		progress = 0,
		lastMissionRefresh = 0,
		battlepassClaims = {},
		missions = {},
		weeklyQuests = {},
		lastWeeklyRefresh = 0,
		abilitySpins = 0,
		ladderScale = 2.5
	},
	rewards = {
		["125"] = {
			free = { writeLib = "Currency1", value = 500 },
			season = { writeLib = "Currency2", value = 5 }
		},
		["250"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable10" },
			season = { writeLib = "Currency1", value = 1500 }
		},
		["375"] = {
			free = { writeLib = "Currency1", value = 750 },
			season = { writeLib = "PoolEffect", itemName = "Golden" }
		},
		["500"] = {
			free = { writeLib = "Currency1", value = 1000 },
			season = { writeLib = "Currency2", value = 10 }
		},
		["625"] = {
			free = { writeLib = "Currency2", value = 5 },
			season = { writeLib = "Currency1", value = 2500 }
		},
		["750"] = {
			free = { writeLib = "Currency2", value = 5 },
			season = { writeLib = "CueStick", itemName = "Neon" }
		},
		["1000"] = {
			free = { writeLib = "Currency1", value = 1250 },
			season = { writeLib = "Currency2", value = 15 }
		},
		["1250"] = {
			free = { writeLib = "Currency2", value = 10 },
			season = { writeLib = "Currency1", value = 4000 }
		},
		["1500"] = {
			free = { writeLib = "Currency1", value = 1500 },
			season = { writeLib = "PoolEffect", itemName = "Electrocute" }
		},
		["1750"] = {
			free = { writeLib = "Currency2", value = 10 },
			season = { writeLib = "Currency1", value = 5000 }
		},
		["2000"] = {
			free = { writeLib = "PoolEffect", itemName = "Flame" },
			season = { writeLib = "CueStick", itemName = "Jungle" }
		},
		["2250"] = {
			free = { writeLib = "Currency1", value = 2000 },
			season = { writeLib = "Currency2", value = 20 }
		},
		["2500"] = {
			free = { writeLib = "Currency2", value = 15 },
			season = { writeLib = "Currency1", value = 6500 }
		},
		["2750"] = {
			free = { writeLib = "Currency1", value = 2500 },
			season = { writeLib = "PoolEffect", itemName = "Lightning Blast" }
		},
		["3000"] = {
			free = { writeLib = "Currency2", value = 15 },
			season = { writeLib = "Currency1", value = 8000 }
		},
		["3250"] = {
			free = { writeLib = "Currency1", value = 3000 },
			season = { writeLib = "Currency2", value = 25 }
		},
		["3500"] = {
			free = { writeLib = "PoolEffect", itemName = "Starburst" },
			season = { writeLib = "PoolTable", itemName = "PoolTable9" }
		},
		["3750"] = {
			free = { writeLib = "Currency1", value = 3500 },
			season = { writeLib = "Currency1", value = 10000 }
		},
		["4000"] = {
			free = { writeLib = "Currency2", value = 20 },
			season = { writeLib = "Currency2", value = 30 }
		},
		["4250"] = {
			free = { writeLib = "Currency1", value = 4000 },
			season = { writeLib = "PoolEffect", itemName = "Inferno" }
		},
		["4500"] = {
			free = { writeLib = "Currency2", value = 20 },
			season = { writeLib = "Currency1", value = 12500 }
		},
		["4750"] = {
			free = { writeLib = "Currency1", value = 5000 },
			season = { writeLib = "Currency2", value = 35 }
		},
		["5000"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable12" },
			season = { writeLib = "PoolEffect", itemName = "Black Hole" }
		},
		["5250"] = {
			free = { writeLib = "Currency1", value = 6000 },
			season = { writeLib = "Currency2", value = 40 }
		},
		["5500"] = {
			free = { writeLib = "Currency2", value = 25 },
			season = { writeLib = "Currency1", value = 15000 }
		},
		["5750"] = {
			free = { writeLib = "Currency1", value = 7000 },
			season = { writeLib = "CueStick", itemName = "Starry" }
		},
		["6000"] = {
			free = { writeLib = "Currency2", value = 30 },
			season = { writeLib = "Currency1", value = 17500 }
		},
		["6250"] = {
			free = { writeLib = "Currency1", value = 8000 },
			season = { writeLib = "Currency2", value = 50 }
		},
		["6500"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable15" },
			season = { writeLib = "CueStick", itemName = "Emerald" }
		},
		["6750"] = {
			free = { writeLib = "Currency1", value = 10000 },
			season = { writeLib = "Currency2", value = 55 }
		},
		["7000"] = {
			free = { writeLib = "Currency2", value = 35 },
			season = { writeLib = "Currency1", value = 22500 }
		},
		["7250"] = {
			free = { writeLib = "Currency1", value = 12000 },
			season = { writeLib = "PoolEffect", itemName = "Aurora Burst" }
		},
		["7500"] = {
			free = { writeLib = "Currency2", value = 40 },
			season = { writeLib = "Currency1", value = 27500 }
		},
		["7750"] = {
			free = { writeLib = "Currency1", value = 15000 },
			season = { writeLib = "Currency2", value = 65 }
		},
		["8000"] = {
			free = { writeLib = "PoolEffect", itemName = "RGB" },
			season = { writeLib = "PoolTable", itemName = "PoolTable14" }
		},
		["8250"] = {
			free = { writeLib = "Currency1", value = 18000 },
			season = { writeLib = "Currency2", value = 75 }
		},
		["8500"] = {
			free = { writeLib = "Currency2", value = 50 },
			season = { writeLib = "Currency1", value = 35000 }
		},
		["8750"] = {
			free = { writeLib = "Currency1", value = 22000 },
			season = { writeLib = "PoolEffect", itemName = "Possessed" }
		},
		["9000"] = {
			free = { writeLib = "Currency2", value = 60 },
			season = { writeLib = "CueStick", itemName = "LavaCore" }
		},
		["9250"] = {
			free = { writeLib = "Currency1", value = 30000 },
			season = { writeLib = "Currency2", value = 100 }
		},
		["9500"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable8" },
			season = { writeLib = "Currency1", value = 50000 }
		}
	},
	bundles = {
		[3378288399] = {
			[true] = {
				originalPrice = 2688,
				colour = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 187)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
				}),
				header = {
					gradient = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.336, Color3.fromRGB(255, 136, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					}),
					text = "ULTIMATE PROFESSIONAL BUNDLE"
				},
				rewards = {
					{ writeLib = "TierSkip", skipCount = 10 },
					{ writeLib = "Currency1", value = 26000 },
					{ writeLib = "Currency2", value = 150 },
					{ writeLib = "BoostCurrency1", value = 3600 },
					{ writeLib = "BoostExp", value = 3600 }
				}
			},
			[false] = {
				originalPrice = 3277,
				colour = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 238, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
				}),
				header = {
					gradient = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 162, 0)),
						ColorSequenceKeypoint.new(0.336, Color3.fromRGB(255, 136, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					}),
					text = "ULTIMATE PROFESSIONAL BUNDLE"
				},
				rewards = {
					{ writeLib = "Currency1", value = 500 },
					{ writeLib = "SpinWheel", value = 10 },
					{ writeLib = "SpinWheel", value = 10 },
					{ writeLib = "Currency2", value = 150 },
					{ writeLib = "Currency1", value = 14000 }
				}
			}
		}
	},
	possibleMissions = {
		{
			key = "PoolMatches",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play " .. p .. " online matches"
			end,
			requirement = function()
				return Random.new():NextInteger(3, 6)
			end,
			reward = function(p: number)
				return p * 15
			end
		},
		{
			key = "Playtime",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play for " .. math.floor((tonumber(p) or 0) / 60) .. " minutes"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 4) * 5 * 60
			end,
			reward = function(p: number)
				return math.floor(p / 60) * 4
			end
		},
		{
			key = "PoolWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " online matches"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 5)
			end,
			reward = function(p: number)
				return p * 25
			end
		},
		{
			key = "PotBalls",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls"
			end,
			requirement = function()
				return Random.new():NextInteger(15, 30)
			end,
			reward = function(p: number)
				return p * 3
			end
		},
		{
			key = "BreakPots",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls on the break"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 4)
			end,
			reward = function(p: number)
				return p * 25
			end
		},
		{
			key = "VenueWin",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " matches at any venue"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 5)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "Trickshot",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Create and play " .. p .. " trickshot" .. (p == "1" and "" or "s")
			end,
			requirement = function(): number
				return 1
			end,
			reward = function(p: number)
				return p * 30
			end
		},
		{
			key = "BotWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Beat any bot " .. p .. " times"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 4)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "Friends",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(_: string): string
				return "Invite a friend to 8 Ball Duels"
			end,
			requirement = function(): number
				return 1
			end,
			reward = function(_: number): number
				return 60
			end
		},
		{
			key = "SpendRobux",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(_: string): string
				return "Buy anything for yourself using Robux"
			end,
			requirement = function(): number
				return 1
			end,
			reward = function(_: number): number
				return 80
			end
		},
		{
			key = "JoinGroup",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(_: string): string
				return "Join the 8 Ball Duels group!"
			end,
			requirement = function(): number
				return 1
			end,
			reward = function(_: number): number
				return 50
			end
		}
	},
	weeklyMissions = {
		{
			key = "PoolMatches",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play " .. p .. " online matches"
			end,
			requirement = function()
				return Random.new():NextInteger(25, 35)
			end,
			reward = function(p: number)
				return p * 15
			end
		},
		{
			key = "Playtime",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play for " .. math.floor((tonumber(p) or 0) / 60) .. " minutes"
			end,
			requirement = function()
				return Random.new():NextInteger(6, 12) * 10 * 60
			end,
			reward = function(p: number)
				return math.floor(p / 60) * 4
			end
		},
		{
			key = "Cards",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Flip " .. p .. " reward cards"
			end,
			requirement = function()
				return Random.new():NextInteger(5, 10)
			end,
			reward = function(p: number)
				return p * 40
			end
		},
		{
			key = "PoolWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " online matches"
			end,
			requirement = function()
				return Random.new():NextInteger(35, 45)
			end,
			reward = function(p: number)
				return p * 25
			end
		},
		{
			key = "PotBalls",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls"
			end,
			requirement = function()
				return Random.new():NextInteger(300, 400)
			end,
			reward = function(p: number)
				return p * 3
			end
		},
		{
			key = "BotWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Beat any bot " .. p .. " times"
			end,
			requirement = function()
				return Random.new():NextInteger(30, 40)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "PoolWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " online matches"
			end,
			requirement = function()
				return Random.new():NextInteger(15, 25)
			end,
			reward = function(p: number)
				return p * 25
			end
		},
		{
			key = "PotBalls",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls"
			end,
			requirement = function()
				return Random.new():NextInteger(100, 175)
			end,
			reward = function(p: number)
				return p * 3
			end
		},
		{
			key = "BreakPots",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls on the break"
			end,
			requirement = function()
				return Random.new():NextInteger(12, 20)
			end,
			reward = function(p: number)
				return p * 25
			end
		},
		{
			key = "VenueWin",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " matches at any venue"
			end,
			requirement = function()
				return Random.new():NextInteger(12, 20)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "Trickshot",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Create and play " .. p .. " trickshots"
			end,
			requirement = function()
				return Random.new():NextInteger(4, 8)
			end,
			reward = function(p: number)
				return p * 30
			end
		},
		{
			key = "BotWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Beat any bot " .. p .. " times"
			end,
			requirement = function()
				return Random.new():NextInteger(12, 20)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "FriendMatch",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play " .. p .. " friend challenge matches"
			end,
			requirement = function()
				return Random.new():NextInteger(4, 8)
			end,
			reward = function(p: number)
				return p * 40
			end
		},
		{
			key = "Friends",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Invite friends to 8 Ball Duels " .. p .. " times"
			end,
			requirement = function()
				return Random.new():NextInteger(3, 6)
			end,
			reward = function(p: number)
				return p * 50
			end
		},
		{
			key = "SpendRobux",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Spend " .. p .. " Robux on yourself (purchases add up)"
			end,
			requirement = function(): number
				return 500
			end,
			reward = function(_: number): number
				return 400
			end
		}
	}
}