local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.Types)

return {
	backgroundImage = "rbxassetid://128242291793809",
	backgroundColour = Color3.fromRGB(200, 160, 255),
	eventButtonImage = {
		select = "rbxassetid://124890108983704",
		deselect = "rbxassetid://124890108983704"
	},
	textGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 40)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 95, 120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 85, 255))
	}),
	buttonGradientId = "green",
	missionRefreshRate = 43200,
	weeklyRefreshRate = 604800,
	dailyPointScale = 0.55,
	weeklyPointScale = 0.44,
	ultraPassTable = "PoolTable31",
	eventStart = 1793502000,
	eventEnd = 1795921200,
	eventName = "SPOOKY SEASON",
	currency = {
		name = "Spooky Gems",
		icon = "rbxassetid://96519262526929",
		tint = ColorSequence.new(Color3.fromRGB(255, 175, 255), Color3.fromRGB(185, 125, 255))
	},
	eventDaily = {
		30,
		30,
		50,
		30,
		30,
		50,
		100,
		30,
		30,
		50,
		30,
		30,
		50,
		150,
		30,
		30,
		50,
		30,
		30,
		50,
		200,
		30,
		30,
		50,
		30,
		30,
		50,
		500
	},
	eventShop = {
		{
			id = "Coins25k",
			name = "25,000 Coins",
			price = 150,
			limit = 10,
			reward = { writeLib = "Currency1", value = 25000 }
		},
		{
			id = "Gems5",
			name = "5 Gems",
			price = 250,
			limit = 10,
			reward = { writeLib = "Currency2", value = 5 }
		},
		{
			id = "TierSkip",
			name = "+1 Tier Skip",
			price = 200,
			limit = 10,
			reward = { writeLib = "TierSkip", value = 1 }
		},
		{
			id = "SpectreTable",
			name = "Spectre Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable23" }
		},
		{
			id = "VampireTable",
			name = "Vampire Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable22" }
		},
		{
			id = "GreatSpookTable",
			name = "Great Spook Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable16" }
		},
		{
			id = "GraveyardTable",
			name = "Graveyard Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable17" }
		},
		{
			id = "EngravedTable",
			name = "Engraved Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable18" }
		},
		{
			id = "MurderTable",
			name = "Murder Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable19" }
		},
		{
			id = "HalloweenTable",
			name = "Halloween Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable20" }
		},
		{
			id = "SpookyTable",
			name = "Spooky Table",
			price = 600,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable21" }
		},
		{
			id = "GhostlyAuraTable",
			name = "Ghostly Aura Table",
			price = 900,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable24" }
		},
		{
			id = "BlackCatTable",
			name = "Black Cat Table",
			price = 1200,
			limit = 1,
			reward = { writeLib = "PoolTable", itemName = "PoolTable32" }
		}
	},
	eventRaffle = {
		enabled = false,
		cost = 200,
		freePerDay = 1,
		prizes = {
			{
				id = "GreatSpook",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable16" }
			},
			{
				id = "Graveyard",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable17" }
			},
			{
				id = "Engraved",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable18" }
			},
			{
				id = "Murder",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable19" }
			},
			{
				id = "Halloween",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable20" }
			},
			{
				id = "Spooky",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable21" }
			},
			{
				id = "Vampire",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable22" }
			},
			{
				id = "Spectre",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable23" }
			},
			{
				id = "GhostlyAura",
				tier = "rare",
				weight = 1,
				duplicateRefund = 300,
				reward = { writeLib = "PoolTable", itemName = "PoolTable24" }
			},
			{
				id = "Gems10",
				tier = "common",
				weight = 5,
				reward = { writeLib = "Currency2", value = 10 }
			},
			{
				id = "Gems5",
				tier = "common",
				weight = 10,
				reward = { writeLib = "Currency2", value = 5 }
			},
			{
				id = "Gems2",
				tier = "common",
				weight = 15,
				reward = { writeLib = "Currency2", value = 2 }
			},
			{
				id = "Coins25k",
				tier = "common",
				weight = 5,
				reward = { writeLib = "Currency1", value = 25000 }
			},
			{
				id = "Coins10k",
				tier = "common",
				weight = 10,
				reward = { writeLib = "Currency1", value = 10000 }
			},
			{
				id = "Coins5k",
				tier = "common",
				weight = 20,
				reward = { writeLib = "Currency1", value = 5000 }
			},
			{
				id = "Coins2500",
				tier = "common",
				weight = 25,
				reward = { writeLib = "Currency1", value = 2500 }
			}
		}
	},
	hype = {
		tagline = "SEASON 2 IS HERE!",
		image = "",
		showcase = {
			{
				label = "TOP SEASON PASS CUE",
				reward = { writeLib = "CueStick", itemName = "DreadhornHalloweenCue" }
			},
			{
				label = "100 TIERS OF REWARDS",
				reward = { writeLib = "PoolTable", itemName = "PoolTable30" }
			},
			{
				label = "EVENT SHOP TABLE",
				reward = { writeLib = "PoolTable", itemName = "PoolTable32" }
			},
			{
				label = "GOLD PASS GEMS",
				reward = { writeLib = "Currency2", value = 100 }
			}
		},
		points = {
			"Collect Spooky Gems every day of the event",
			"Spend them on 10 Halloween tables in the event shop",
			"Tier skips, Gems and coins in the shop too",
			"New 9 ball, trickshot and 5K+ match quests"
		}
	},
	datastoreKey = script.Name,
	datastoreValue = {
		progress = 375,
		currency = 0,
		lastMissionRefresh = 0,
		battlepassClaims = {},
		missions = {},
		weeklyQuests = {},
		lastWeeklyRefresh = 0,
		abilitySpins = 0,
		ladderScale = 7.5
	},
	rewards = {
		["375"] = {
			free = { writeLib = "CueStick", itemName = "Spooky_T1" },
			season = { writeLib = "Currency2", value = 5 }
		},
		["565"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["750"] = {
			free = { writeLib = "Currency1", value = 500 },
			season = { writeLib = "CueStick", itemName = "CamoCue" }
		},
		["1125"] = {
			free = { writeLib = "Currency2", value = 5 },
			season = { writeLib = "PoolEffect", itemName = "Golden" }
		},
		["1315"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["1500"] = {
			free = { writeLib = "Currency1", value = 1000 },
			season = { writeLib = "PoolTable", itemName = "PoolTable25" }
		},
		["1875"] = {
			free = { writeLib = "Currency2", value = 5 },
			season = { writeLib = "Currency1", value = 2500 }
		},
		["2065"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["2250"] = {
			free = { writeLib = "CueStick", itemName = "SilverWebCue" },
			season = { writeLib = "Currency2", value = 10 }
		},
		["3000"] = {
			free = { writeLib = "Currency1", value = 1250 },
			season = { writeLib = "PoolEffect", itemName = "Electrocute" }
		},
		["3375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["3750"] = {
			free = { writeLib = "CueStick", itemName = "WitchCauldronCue" },
			season = { writeLib = "Currency1", value = 4000 }
		},
		["4500"] = {
			free = { writeLib = "Currency2", value = 10 },
			season = { writeLib = "CueStick", itemName = "AmberfallAutumn" }
		},
		["4875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["5250"] = {
			free = { writeLib = "PoolEffect", itemName = "Flame" },
			season = { writeLib = "Currency2", value = 15 }
		},
		["6000"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable26" },
			season = { writeLib = "Currency1", value = 5000 }
		},
		["6375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["6750"] = {
			free = { writeLib = "Currency1", value = 2000 },
			season = { writeLib = "Currency2", value = 20 }
		},
		["7500"] = {
			free = { writeLib = "CueStick", itemName = "BloomcrownSpring" },
			season = { writeLib = "Currency1", value = 6500 }
		},
		["7875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["8250"] = {
			free = { writeLib = "Currency2", value = 10 },
			season = { writeLib = "CueStick", itemName = "RazorsteelCue" }
		},
		["9000"] = {
			free = { writeLib = "Currency1", value = 2500 },
			season = { writeLib = "PoolEffect", itemName = "Lightning Blast" }
		},
		["9375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["9750"] = {
			free = { writeLib = "CueStick", itemName = "AlchemyCue" },
			season = { writeLib = "Currency2", value = 25 }
		},
		["10500"] = {
			free = { writeLib = "Currency2", value = 15 },
			season = { writeLib = "Currency1", value = 8000 }
		},
		["10875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["11250"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable27" },
			season = { writeLib = "Currency2", value = 30 }
		},
		["12000"] = {
			free = { writeLib = "Currency1", value = 3500 },
			season = { writeLib = "CueStick", itemName = "FrostCrownWinter" }
		},
		["12375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["12750"] = {
			free = { writeLib = "PoolEffect", itemName = "Starburst" },
			season = { writeLib = "Currency1", value = 12500 }
		},
		["13500"] = {
			free = { writeLib = "Currency2", value = 20 },
			season = { writeLib = "CueStick", itemName = "GoldenCoreCue" }
		},
		["13875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["14250"] = {
			free = { writeLib = "Currency1", value = 5000 },
			season = { writeLib = "PoolEffect", itemName = "Inferno" }
		},
		["15000"] = {
			free = { writeLib = "CueStick", itemName = "SolsticeSummer" },
			season = { writeLib = "Currency2", value = 35 }
		},
		["15375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["15750"] = {
			free = { writeLib = "Currency2", value = 20 },
			season = { writeLib = "PoolTable", itemName = "PoolTable28" }
		},
		["16500"] = {
			free = { writeLib = "Currency1", value = 6000 },
			season = { writeLib = "Currency1", value = 15000 }
		},
		["16875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["17250"] = {
			free = { writeLib = "Currency2", value = 25 },
			season = { writeLib = "CueStick", itemName = "RequiemSkullCue" }
		},
		["18000"] = {
			free = { writeLib = "Currency1", value = 7000 },
			season = { writeLib = "PoolEffect", itemName = "Black Hole" }
		},
		["18375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["18750"] = {
			free = { writeLib = "CueStick", itemName = "VioletEdgeSwordCue" },
			season = { writeLib = "Currency2", value = 50 }
		},
		["19500"] = {
			free = { writeLib = "Currency2", value = 30 },
			season = { writeLib = "CueStick", itemName = "DragonSummonerCue" }
		},
		["19875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["20250"] = {
			free = { writeLib = "Currency1", value = 10000 },
			season = { writeLib = "Currency1", value = 22500 }
		},
		["21000"] = {
			free = { writeLib = "Currency2", value = 35 },
			season = { writeLib = "PoolTable", itemName = "PoolTable29" }
		},
		["21375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["21750"] = {
			free = { writeLib = "Currency1", value = 12000 },
			season = { writeLib = "PoolEffect", itemName = "Aurora Burst" }
		},
		["22500"] = {
			free = { writeLib = "CueStick", itemName = "DreadlightPumpkin" },
			season = { writeLib = "Currency2", value = 65 }
		},
		["22875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["23250"] = {
			free = { writeLib = "PoolEffect", itemName = "RGB" },
			season = { writeLib = "Currency1", value = 27500 }
		},
		["24000"] = {
			free = { writeLib = "CueStick", itemName = "WidowWebCue" },
			season = { writeLib = "Currency2", value = 75 }
		},
		["24375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["24750"] = {
			free = { writeLib = "Currency2", value = 45 },
			season = { writeLib = "CueStick", itemName = "IroncladCue" }
		},
		["25500"] = {
			free = { writeLib = "Currency1", value = 20000 },
			season = { writeLib = "Currency1", value = 35000 }
		},
		["25875"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["26250"] = {
			free = { writeLib = "PoolTable", itemName = "PoolTable30" },
			season = { writeLib = "Currency2", value = 100 }
		},
		["27000"] = {
			free = { writeLib = "Currency2", value = 50 },
			season = { writeLib = "PoolEffect", itemName = "Possessed" }
		},
		["27375"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["27750"] = {
			free = { writeLib = "Currency1", value = 30000 },
			season = { writeLib = "CueStick", itemName = "SoulreaperScythe" }
		},
		["28500"] = {
			free = { writeLib = "Currency2", value = 60 },
			season = { writeLib = "CueStick", itemName = "DreadhornHalloweenCue" }
		},
		["29250"] = {
			free = { writeLib = "Currency1", value = 29000 },
			season = { writeLib = "Currency2", value = 95 }
		},
		["30000"] = {
			free = { writeLib = "Currency2", value = 55 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["30750"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "Currency1", value = 35000 }
		},
		["31500"] = {
			free = { writeLib = "Currency1", value = 31500 },
			season = { writeLib = "Currency2", value = 105 }
		},
		["32250"] = {
			free = { writeLib = "Currency2", value = 65 },
			season = { writeLib = "EventCurrency", value = 25 }
		},
		["33000"] = {
			free = { writeLib = "EventCurrency", value = 12 },
			season = { writeLib = "Currency1", value = 37500 }
		},
		["33750"] = {
			free = { writeLib = "Currency1", value = 27500 },
			season = { writeLib = "Currency2", value = 90 }
		},
		["34500"] = {
			free = { writeLib = "Currency2", value = 50 },
			season = { writeLib = "EventCurrency", value = 18 }
		},
		["35250"] = {
			free = { writeLib = "EventCurrency", value = 8 },
			season = { writeLib = "Currency1", value = 32500 }
		},
		["36000"] = {
			free = { writeLib = "Currency1", value = 33000 },
			season = { writeLib = "Currency2", value = 110 }
		},
		["36750"] = {
			free = { writeLib = "Currency2", value = 60 },
			season = { writeLib = "EventCurrency", value = 22 }
		},
		["37500"] = {
			free = { writeLib = "EventCurrency", value = 11 },
			season = { writeLib = "Currency1", value = 36000 }
		},
		["38250"] = {
			free = { writeLib = "Currency1", value = 30000 },
			season = { writeLib = "Currency2", value = 100 }
		},
		["39000"] = {
			free = { writeLib = "Currency2", value = 70 },
			season = { writeLib = "EventCurrency", value = 15 }
		},
		["39750"] = {
			free = { writeLib = "EventCurrency", value = 9 },
			season = { writeLib = "Currency1", value = 34000 }
		},
		["40500"] = {
			free = { writeLib = "Currency1", value = 28500 },
			season = { writeLib = "Currency2", value = 85 }
		},
		["41250"] = {
			free = { writeLib = "Currency2", value = 55 },
			season = { writeLib = "EventCurrency", value = 24 }
		},
		["42000"] = {
			free = { writeLib = "EventCurrency", value = 13 },
			season = { writeLib = "Currency1", value = 38500 }
		},
		["42750"] = {
			free = { writeLib = "Currency1", value = 34000 },
			season = { writeLib = "Currency2", value = 115 }
		},
		["43500"] = {
			free = { writeLib = "Currency2", value = 65 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["44250"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "Currency1", value = 33000 }
		},
		["45000"] = {
			free = { writeLib = "Currency1", value = 30500 },
			season = { writeLib = "Currency2", value = 95 }
		},
		["45750"] = {
			free = { writeLib = "Currency2", value = 60 },
			season = { writeLib = "EventCurrency", value = 17 }
		},
		["46500"] = {
			free = { writeLib = "EventCurrency", value = 8 },
			season = { writeLib = "Currency1", value = 35500 }
		},
		["47250"] = {
			free = { writeLib = "Currency1", value = 27000 },
			season = { writeLib = "Currency2", value = 105 }
		},
		["48000"] = {
			free = { writeLib = "Currency2", value = 50 },
			season = { writeLib = "EventCurrency", value = 25 }
		},
		["48750"] = {
			free = { writeLib = "EventCurrency", value = 12 },
			season = { writeLib = "Currency1", value = 39000 }
		},
		["49500"] = {
			free = { writeLib = "Currency1", value = 32000 },
			season = { writeLib = "Currency2", value = 90 }
		},
		["50250"] = {
			free = { writeLib = "Currency2", value = 70 },
			season = { writeLib = "EventCurrency", value = 21 }
		},
		["51000"] = {
			free = { writeLib = "EventCurrency", value = 11 },
			season = { writeLib = "Currency1", value = 34500 }
		},
		["51750"] = {
			free = { writeLib = "Currency1", value = 29500 },
			season = { writeLib = "Currency2", value = 110 }
		},
		["52500"] = {
			free = { writeLib = "Currency2", value = 60 },
			season = { writeLib = "EventCurrency", value = 19 }
		},
		["53250"] = {
			free = { writeLib = "EventCurrency", value = 9 },
			season = { writeLib = "Currency1", value = 36500 }
		},
		["54000"] = {
			free = { writeLib = "Currency1", value = 33500 },
			season = { writeLib = "Currency2", value = 100 }
		},
		["54750"] = {
			free = { writeLib = "Currency2", value = 55 },
			season = { writeLib = "EventCurrency", value = 23 }
		},
		["55500"] = {
			free = { writeLib = "EventCurrency", value = 14 },
			season = { writeLib = "Currency1", value = 32000 }
		},
		["56250"] = {
			free = { writeLib = "Currency1", value = 31000 },
			season = { writeLib = "Currency2", value = 105 }
		},
		["57000"] = {
			free = { writeLib = "Currency2", value = 65 },
			season = { writeLib = "EventCurrency", value = 20 }
		},
		["57750"] = {
			free = { writeLib = "EventCurrency", value = 10 },
			season = { writeLib = "Currency1", value = 37000 }
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
		},
		{
			key = "NineBallMatches",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play " .. p .. " 9 ball matches"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 4)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "NineBallWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " 9 ball match" .. (p == "1" and "" or "es")
			end,
			requirement = function()
				return Random.new():NextInteger(1, 3)
			end,
			reward = function(p: number)
				return p * 30
			end
		},
		{
			key = "TrickshotLevels",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Clear " .. p .. " trickshot levels"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 4)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "TrickshotStars",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Earn " .. p .. " stars in trickshot levels"
			end,
			requirement = function()
				return Random.new():NextInteger(5, 8)
			end,
			reward = function(p: number)
				return p * 8
			end
		},
		{
			key = "CommunityClears",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Beat " .. p .. " community trickshot" .. (p == "1" and "" or "s") .. " with every star"
			end,
			requirement = function()
				return Random.new():NextInteger(1, 2)
			end,
			reward = function(p: number)
				return p * 40
			end
		},
		{
			key = "MultiPots",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot 2+ balls in one shot " .. (p == "1" and "once" or p .. " times")
			end,
			requirement = function()
				return Random.new():NextInteger(1, 3)
			end,
			reward = function(p: number)
				return p * 30
			end
		},
		{
			key = "HighStakesPots",
			levelRequirement = 20,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls in 5K+ coin matches"
			end,
			requirement = function()
				return Random.new():NextInteger(15, 25)
			end,
			reward = function(p: number)
				return p * 4
			end
		},
		{
			key = "HighStakesWins",
			levelRequirement = 20,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " 5K+ coin matches"
			end,
			requirement = function()
				return Random.new():NextInteger(2, 4)
			end,
			reward = function(p: number)
				return p * 30
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
		},
		{
			key = "NineBallMatches",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Play " .. p .. " 9 ball matches"
			end,
			requirement = function()
				return Random.new():NextInteger(12, 20)
			end,
			reward = function(p: number)
				return p * 15
			end
		},
		{
			key = "NineBallWins",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " 9 ball matches"
			end,
			requirement = function()
				return Random.new():NextInteger(8, 14)
			end,
			reward = function(p: number)
				return p * 25
			end
		},
		{
			key = "TrickshotLevels",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Clear " .. p .. " trickshot levels"
			end,
			requirement = function()
				return Random.new():NextInteger(10, 16)
			end,
			reward = function(p: number)
				return p * 20
			end
		},
		{
			key = "TrickshotStars",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Earn " .. p .. " stars in trickshot levels"
			end,
			requirement = function()
				return Random.new():NextInteger(25, 40)
			end,
			reward = function(p: number)
				return p * 8
			end
		},
		{
			key = "CommunityClears",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Beat " .. p .. " community trickshots with every star"
			end,
			requirement = function()
				return Random.new():NextInteger(3, 6)
			end,
			reward = function(p: number)
				return p * 40
			end
		},
		{
			key = "MultiPots",
			levelRequirement = 0,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot 2+ balls in one shot " .. p .. " times"
			end,
			requirement = function()
				return Random.new():NextInteger(6, 12)
			end,
			reward = function(p: number)
				return p * 30
			end
		},
		{
			key = "HighStakesPots",
			levelRequirement = 20,
			levelLimit = 1e999,
			description = function(p: string)
				return "Pot " .. p .. " balls in 5K+ coin matches"
			end,
			requirement = function()
				return Random.new():NextInteger(100, 160)
			end,
			reward = function(p: number)
				return p * 4
			end
		},
		{
			key = "HighStakesWins",
			levelRequirement = 20,
			levelLimit = 1e999,
			description = function(p: string)
				return "Win " .. p .. " 5K+ coin matches"
			end,
			requirement = function()
				return Random.new():NextInteger(10, 16)
			end,
			reward = function(p: number)
				return p * 30
			end
		}
	}
}