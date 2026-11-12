local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local TableHelper = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Helpers"):WaitForChild("TableHelper"))
game:GetService("ReplicatedFirst")

local Types = ReplicatedStorage:WaitForChild("Types")
require(Types:WaitForChild("Types"))
require(Types:WaitForChild("DataTypes"))

local v = {
	currency1 = { mantissa = 100, exponent = 0 },
	currency2 = { mantissa = 0, exponent = 0 },
	spins = 3,
	roleSpins = 0,
	premiumRoleSpins = 0,
	weaponSpins = 0,
	premiumWeaponSpins = 0,
	offlineRewards = {},
	winStreak = 0,
	skillTree = {},
	quests = {},
	achievements = {},
	completeAchievements = {},
	kills = {},
	roleSpinsUsed = {},
	weaponSpinsUsed = {},
	experience = 0,
	level = 1,
	rebirth = 0,
	inventory = {
		titles = {},
		emotes = {},
		pets = {},
		tools = {},
		cueSticks = {
			CueStick1 = { item = "CueStick1" }
		},
		poolTables = {
			PoolTable1 = { item = "PoolTable1" }
		},
		poolEffects = {
			PoolEffect1 = { item = "Smoke" }
		}
	},
	equipped = {
		emotes = {},
		pets = {},
		titles = nil,
		tools = {},
		cueStick = "CueStick1",
		poolTable = "PoolTable1",
		poolEffect = "Smoke"
	},
	selectedSlot = 1,
	roleSlots = {
		{ role = "Citizen", locked = false }
	},
	selectedWeaponSlot = { primary = 1, secondary = 1, melee = 1, utility = 1 },
	weaponSlots = {
		primary = {
			{ item = "Dual Uzis", locked = false }
		},
		secondary = {},
		melee = {},
		utility = {}
	},
	boosts = {
		BoostCurrency1 = 0,
		BoostCurrency2 = 0,
		BoostExp = 0,
		BoostLuck = 0,
		BoostExtraLuck = 0,
		BoostSuperLuck = 0
	},
	mastery = {},
	events = {},
	index = {},
	matchResultsSeen = true,
	matches = {},
	topScore = 0,
	poolStats = { wins = 0, losses = 0, streak = 0, rating = 1200 },
	poolWinnings = {},
	poolVenueWins = {},
	poolVenueBoxes = {},
	poolBotWins = {},
	poolNineBallMatches = 0,
	poolBehavior = {
		v = 1,
		turns = 0,
		turnTime = 0,
		think = 0,
		power = 0,
		spin = 0,
		kick = 0,
		reach = 0,
		sweep = 0,
		bih = 0,
		placeHold = 0,
		placeMoves = 0,
		breaks = 0,
		breakPower = 0,
		breakSide = 0
	},
	poolSeenItems = {},
	poolTrickshots = {},
	poolLevels = {},
	poolLives = 5,
	poolLivesAt = 0,
	poolTrickshotFavourites = {},
	poolOnboardingRewards = {},
	poolCueUpgrades = {},
	poolCardPicks = { pending = {}, nextId = 1 },
	poolCardOpenings = 0,
	poolDailyRewards = { LastDay = 0, Step = 0 },
	poolLifetime = { ballsPotted = 0, breakPots = 0, bestWinStreak = 0, trickshotsPublished = 0 },
	poolAchievements = {},
	poolLeague = {
		tier = 1,
		weekKey = "",
		pendingClaim = false,
		lastTier = 1,
		lastRank = 0,
		lastWinnings = 0,
		lastPrize = 0,
		lastOutcome = ""
	},
	country = "",
	firstPlay = 0,
	lastLogin = 0,
	lastLogout = 0,
	group = nil,
	plays = 0,
	playTime = 0,
	friendPlays = 0,
	onBoarding = {},
	tutorials = {},
	codes = {},
	badges = {},
	dailyReward = { lastReward = 0, claims = 0, streak = 0, streakClaims = 0 },
	levelRewardClaims = 0,
	inviteRewardInvites = {},
	inviteRewardClaims = {},
	inviteRewardProgress = 10,
	inviteRewardCount = 0,
	inviteRewardTime = 0,
	rewardClaims = {},
	configuration = {
		desktopKeybinds = {
			toggleable = true,
			buttons = {
				mouselock = Enum.KeyCode.LeftControl.Value,
				dash = Enum.KeyCode.Q.Value,
				sprint = Enum.KeyCode.LeftShift.Value,
				crouch = Enum.KeyCode.C.Value,
				reload = Enum.KeyCode.R.Value
			}
		},
		consoleKeybinds = {
			toggleable = true,
			buttons = {
				sprint = Enum.KeyCode.ButtonY.Value,
				dash = Enum.KeyCode.ButtonB.Value,
				mouselock = Enum.KeyCode.ButtonL3.Value,
				crouch = Enum.KeyCode.DPadUp.Value,
				reload = Enum.KeyCode.ButtonX.Value
			}
		},
		mobileKeybinds = {
			toggleable = true,
			buttons = {
				shoot = { id = "shoot", size = 1, offsetX = 0.9, offsetY = 1 },
				reload = { id = "reload", size = 0.5, offsetX = 1.6, offsetY = 0.9 },
				dash = { id = "dash", size = 0.85, offsetX = 1, offsetY = -0.05 },
				sprint = { id = "sprint", size = 0.85, offsetX = 1.9, offsetY = -0.05 },
				crouch = { id = "crouch", size = 0.85, offsetX = 2.8, offsetY = -0.05 },
				mouselock = { id = "mouselock", size = 0.7, offsetX = 1, offsetY = 2 }
			}
		},
		audio = { music = 10, soundEffects = 10 },
		misc = {
			roleplayName = "",
			roleplayNumber = "",
			unit = "Metric",
			nameTags = "On",
			shadows = "On",
			instaOpen = "Off",
			autoTeleport = false,
			poolAimMode = "Drag",
			poolAimSensitivity = "5"
		}
	},
	shopPurchases = {},
	packPurchases = {},
	purchases = {},
	gamepasses = {},
	crateOwned = {},
	crateActive = { slot = nil, startTime = nil }
}
return {
	Get = function(_)
		return (TableHelper:DeepCopy(v))
	end
}