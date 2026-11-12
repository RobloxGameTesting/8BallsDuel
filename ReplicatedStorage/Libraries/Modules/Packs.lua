local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Probability = require(ReplicatedStorage.Libraries.Modules.Probability)
local HttpService = game:GetService("HttpService")
require(ReplicatedStorage.Libraries.Modules.Events)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local StatsHelper = require(ReplicatedStorage.Libraries.Helpers.StatsHelper)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

RunService:IsServer()
local packs = ReplicatedStorage.Assets.Packs

local Packs = {}

function Packs.Open(p: string, childName, p2, p3)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	Profiles.GetPlayerReplica(p)

	local child = packs:FindFirstChild(childName)

	assert(child, `Pack name {childName} not found in ReplicatedStorage>Assets>Packs`)

	local module = require(child)
	local v = {}

	for _ = 1, p2 do
		table.insert(v, (Packs.Generate(p, childName, p3)))
	end

	RemoteSignals.FireClient(playerByUserId, "Packs", "PackOpen", childName, p2, v)

	if module.packType == "Athletes" then
		StatsHelper.IncrementMission(playerByUserId, "AthletePacks", p2)
	elseif module.packType == "Abilities" then
		warn("Increment abilities pack open mission")
	else
		StatsHelper.IncrementMission(playerByUserId, "CosmeticPacks", p2)
	end

	StatsHelper.IncrementMission(playerByUserId, "Packs", p2)
end

function Packs.Give(p, p2, p3)
	Profiles.GetPlayerReplica(p):Write("Packs", p2, p3)
end

function Packs.Generate(p: string, childName, p2)
	local playerReplica = Profiles.GetPlayerReplica(p)
	local child = packs:FindFirstChild(childName)
	Players:GetPlayerByUserId((tonumber(p)))

	assert(playerReplica, "Replica is nil")
	assert(playerReplica:IsActive(), "Replica is not active")
	assert(child, "No pack module found")

	local module = require(child)

	local v = playerReplica.Data.boostLuck and "Luck" or "Normal"

	local chance = module.chances[(p2 and "robux" or "money") .. v]

	local item = Probability.GetItem(chance)

	local packType = module.packType
	local v2 = {}

	for _, reward in module.rewards do
		local itemData = InventoryHelpers.GetItemData(packType, reward)

		if itemData then
			if itemData.rarity({}, itemData) == item then
				v2[reward] = 1
			end
		else
			warn("No item data found for " .. reward .. " in category " .. packType)
		end
	end

	local item2 = Probability.GetItem(v2)

	if not item2 then
		warn("Generated a nil value, ", childName, v2)
		return nil
	end

	local guid = HttpService:GenerateGUID()
	playerReplica:Write("Inventory", string.lower(packType), guid, { item = item2 })

	local chance2 = math.ceil(1 / (chance[item] / 100 * (1 / TableHelper:Count(v2))))

	return { item = tostring(item2), chance = chance2 }
end

return Packs