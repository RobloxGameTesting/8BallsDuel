local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local legacyProductIds = { 3605057530 }

local function serverNow() -- 1 equivalent call inferred from this helper
	return workspace:GetServerTimeNow()
end

local function poolStarterPackAge(p) -- 3 equivalent calls inferred from this helper
	local playerReplica = Profiles.GetPlayerReplica((tostring(p.UserId)))
	local firstPlay = playerReplica and playerReplica.Data and playerReplica.Data.firstPlay

	if typeof(firstPlay) == "number" and not (firstPlay <= 0) then
		return serverNow() - firstPlay -- inferred equivalent call
	end

	return nil
end

return {
	SERVER_LUCK_TIME = 900,
	PRODUCT_IDS = {
		ROLE_SPIN_RATES = { [3463284134] = 10, [3463284253] = 25, [3463284429] = 50 },
		PREMIUM_ROLE_SPIN_RATES = { [3463284815] = 1, [3463284920] = 5, [3463285034] = 20 },
		WEAPON_SPIN_RATES = { [3469285824] = 10, [3469285885] = 25, [3469285926] = 50 },
		PREMIUM_WEAPON_SPIN_RATES = { [3469285331] = 1, [3469285445] = 5, [3469285529] = 20 },
		ROLE_SLOT_ID = 3462061385,
		PRIMARY_WEAPON_SLOT_ID = 3469253452,
		SECONDARY_WEAPON_SLOT_ID = 3469253955,
		MELEE_WEAPON_SLOT_ID = 3469254027,
		UTILITY_WEAPON_SLOT_ID = 3469254075,
		REVIVE = 3531224416,
		SHOP_ITEMS = { [3519826038] = "Gloves" },
		CURRENCY1_RATES = { [3514667998] = 500, [3514668130] = 2000, [3514668196] = 6000 },
		CURRENCY2_RATES = { [3514667998] = 500, [3514668130] = 2000, [3514668196] = 6000 },
		SPINS_RATES = { [3514668429] = 1, [3514668480] = 5, [3514668553] = 25 }
	},
	PRANK_IDS = {
		[3514669442] = "Bigger",
		[3514669553] = "Kill",
		[3514669639] = "Ugly",
		[3514669743] = "KillAll",
		[3514669833] = "Shrink"
	},
	STARTER_PACK_INFO = {
		timeLimit = 7200,
		canBuy = function(p): boolean
			local userId = tostring(p.UserId)
			local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
			local v2 = false

			for _, purchas in v.Data.purchases do
				if purchas.product == 3514667715 and purchas.bought then
					v2 = true
					break
				end
			end

			return not v2 and os.time() - v.Data.firstPlay < 8100
		end,
		productId = 3514667715,
		originalCost = { [true] = 1253, [false] = 1104 },
		rewards = {
			[true] = {
				{ writeLib = "Currency1", value = 12000 }
			},
			[false] = {
				{ writeLib = "Currency1", value = 12000 }
			}
		},
		maxLevel = 15,
		minLevel = 0
	},
	POOL_WORLD_PASS_INFO = {
		gamepassId = 1982486441,
		gamepassName = "WorldPass",
		name = "World Pass",
		blurb = "Allows you to unlock all worlds instantly",
		fallbackPrice = 399
	},
	POOL_VIP_PASS_INFO = {
		gamepassId = 2001404253,
		gamepassName = "VIP",
		name = "VIP",
		blurb = "VIP cue, VIP table and a golden [ VIP ] tag by your name",
		fallbackPrice = 499,
		skins = {
			{ category = "cueSticks", item = "VipCue" },
			{ category = "poolTables", item = "VipTable" }
		}
	},
	POOL_STARTER_PACK_INFO = {
		productId = 3712251872,
		legacyProductIds = legacyProductIds,
		canBuy = function(p): boolean
			local userId = tostring(p.UserId)
			local playerReplica = Profiles.GetPlayerReplica(userId)

			if not playerReplica then
				return false
			end

			for _, purchas in playerReplica.Data.purchases do
				if
					(purchas.product == 3712251872 or table.find(legacyProductIds, purchas.product) ~= nil)
					and purchas.bought
				then
					return false
				end
			end

			local v = poolStarterPackAge(p) -- inferred equivalent call
			return not (v and v >= 86400)
		end,
		timeLimit = 86400,
		gracePeriod = 3600,
		getTimeLeft = function(p)
			return (math.max(86400 - (poolStarterPackAge(p) or 0), 0)) -- inferred equivalent call
		end,
		isReceiptOpen = function(p): boolean
			local v = poolStarterPackAge(p) -- inferred equivalent call
			return v == nil or v < 90000
		end,
		gems = 100,
		skins = {
			{ category = "cueSticks", item = "CueStick4" },
			{ category = "poolTables", item = "PoolTable3" },
			{ category = "poolEffects", item = "Sunburst" }
		}
	},
	POOL_GEM_PACKS = {
		{ key = "Gems1", productId = nil, gems = 10 },
		{ key = "Gems2", productId = nil, gems = 100 },
		{ key = "Gems3", productId = nil, gems = 450 },
		{ key = "Gems4", productId = nil, gems = 1000 },
		{ key = "Gems5", productId = nil, gems = 1800 }
	},
	POOL_COIN_PACKS = {
		{ key = "Coins1", productId = 3712253399, coins = 1000 },
		{ key = "Coins2", productId = 3712253419, coins = 10000 },
		{ key = "Coins3", productId = 3712253437, coins = 45000 },
		{ key = "Coins4", productId = 3712256411, coins = 100000 },
		{ key = "Coins5", productId = 3712256470, coins = 180000 }
	}
}