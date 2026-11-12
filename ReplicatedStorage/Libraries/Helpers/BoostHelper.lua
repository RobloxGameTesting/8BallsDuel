local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
local BoostHelper = {}

function BoostHelper.CalculateLuckBoost(p: string)
	local replica = Profiles.GetReplica("Game")

	local v = Profiles.GetPlayerReplica(p) or Profiles.WaitForPlayerReplica(p)

	local v2 = {
		Group = {
			type = "additive",
			value = v.Data.group and 1 or 0
		},
		Friends = {
			type = "additive",
			value = #FriendHelper.GetFriendsInServer(p)
		},
		ServerLuck = { type = "additive", value = replica.Data.serverLuck },
		Rebirth = {
			type = "multiplicative",
			value = 1 + v.Data.rebirth
		},
		BoostLuck = {
			type = "multiplicative",
			value = v.Data.boosts.BoostLuck and 2 or 1
		},
		BoostExtraLuck = {
			type = "multiplicative",
			value = v.Data.boosts.BoostExtraLuck and 3 or 1
		},
		BoostSuperLuck = {
			type = "multiplicative",
			value = v.Data.boosts.BoostSuperLuck and 4 or 1
		}
	}
	local v3 = 1

	for _, v4 in { "additive", "multiplicative" } do
		for _, v5 in v2 do
			if v5.type ~= v4 then
				continue
			end

			if v5.type == "additive" then
				v3 += v5.value
			else
				v3 *= v5.value
			end
		end
	end

	return v3, v2
end

function BoostHelper.CalculateMoneyBoost(p: string)
	Profiles.GetReplica("Game")

	if not Profiles.GetPlayerReplica(p) then
		Profiles.WaitForPlayerReplica(p)
	end

	local v = {
		Default = { type = "additive", value = 1 }
	}
	local v2 = 0

	for _, v3 in { "additive", "multiplicative" } do
		for _, v4 in v do
			if v4.type ~= v3 then
				continue
			end

			if v4.type == "additive" then
				v2 += v4.value
			else
				v2 *= v4.value
			end
		end
	end

	return v2, v
end

return BoostHelper