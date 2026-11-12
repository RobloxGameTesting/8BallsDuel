local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)

local PoolSkins = {}

PoolSkins.Categories = {
	{
		Id = "cueSticks",
		Equipped = "cueStick",
		Folder = "CueSticks",
		Label = "CUE STICKS",
		Default = "CueStick1"
	},
	{
		Id = "poolTables",
		Equipped = "poolTable",
		Folder = "PoolTables",
		Label = "TABLES",
		Default = "PoolTable1"
	},
	{
		Id = "poolEffects",
		Equipped = "poolEffect",
		Folder = "PoolEffects",
		Label = "VFX",
		Default = "Smoke"
	}
}

function PoolSkins.GetCategory(p: string)
	for _, category in PoolSkins.Categories do
		if category.Id == p then
			return category
		end
	end

	return nil
end

function PoolSkins.GetItem(p: string, childName: string?)
	if not childName then
		return nil
	end

	local category = PoolSkins.GetCategory(p)

	if not category then
		return nil
	end

	local child = ReplicatedStorage.Assets.Skins:FindFirstChild(category.Folder)
	local moduleScript = child and child:FindFirstChild(childName)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, moduleScript)
	return if success then result else nil
end

local function readInfo(p) -- 4 equivalent calls inferred from this helper
	local info

	if typeof(p) == "table" then
		info = p.info
	end

	if info == "Coins" or info == "Gems" or info == "Info" then
		return info
	end

	return nil
end

function PoolSkins.GetPrice(p)
	local info = readInfo(p) -- inferred equivalent call

	if info == "Info" then
		return 0
	end

	local v

	if info then
		v = p.infoLink
	elseif typeof(p) == "table" then
		v = p.price
	end

	return (math.max(tonumber(v) or 0, 0))
end

function PoolSkins.GetPriceCurrency(p): string
	local info = readInfo(p) -- inferred equivalent call

	if info then
		return if info == "Gems" then "Gems" else "Coins"
	elseif typeof(p) == "table" and p.currency == "Gems" then
		return "Gems"
	else
		return "Coins"
	end
end

function PoolSkins.GetObtainedFrom(p)
	if readInfo(p) ~= "Info" then -- inferred equivalent call
		return nil
	end

	local infoLink = p.infoLink

	if infoLink == nil or tostring(infoLink) == "" then
		return nil
	end

	return (tostring(infoLink))
end

function PoolSkins.IsForSale(p)
	local v = false

	if readInfo(p) ~= "Info" then -- inferred equivalent call
		return PoolSkins.GetPrice(p) > 0
	end

	return v
end

function PoolSkins.FormatAmount(p: number)
	return (tostring((math.max(math.round(p), 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

function PoolSkins.FormatPrice(p: number, p2: string)
	local formatAmount = PoolSkins.FormatAmount(p)

	if p2 == "Gems" then
		return formatAmount .. " GEMS"
	end

	return "$" .. formatAmount
end

function PoolSkins.GetAll(p: string)
	local category = PoolSkins.GetCategory(p)
	local all = {}

	if not category then
		return all
	end

	local child = ReplicatedStorage.Assets.Skins:FindFirstChild(category.Folder)

	if not child then
		return all
	end

	for _, moduleScript in child:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success then
			all[moduleScript.Name] = result
		end
	end

	return all
end

function PoolSkins.GetStoredEquippedName(p: number, p2: string)
	local category = PoolSkins.GetCategory(p2)

	if not category then
		return nil
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(p)))
	local equipped = playerReplica and playerReplica.Data and playerReplica.Data.equipped
	local selected = equipped and equipped[category.Equipped]

	if typeof(selected) == "string" and selected ~= "" then
		return selected
	end

	return nil
end

function PoolSkins.GetEquippedName(p: number, p2: string)
	local category = PoolSkins.GetCategory(p2)

	if not category then
		return ""
	end

	local storedEquippedName = PoolSkins.GetStoredEquippedName(p, p2)

	if storedEquippedName and PoolSkins.GetItem(p2, storedEquippedName) then
		return storedEquippedName
	end

	return category.Default
end

function PoolSkins.GetEquipped(p: number, p2: string)
	local category = PoolSkins.GetCategory(p2)

	if category then
		return PoolSkins.GetItem(p2, PoolSkins.GetEquippedName(p, p2)) or PoolSkins.GetItem(p2, category.Default)
	end

	return nil
end

function PoolSkins.Owns(p: number, p2: string, p3: string): boolean
	local playerReplica = Profiles.GetPlayerReplica((tostring(p)))
	local inventory = playerReplica and playerReplica.Data and playerReplica.Data.inventory
	local v = inventory and inventory[p2]

	if typeof(v) ~= "table" then
		return false
	end

	if v[p3] then
		return true
	end

	for _, v2 in v do
		if typeof(v2) == "table" and v2.item == p3 then
			return true
		end
	end

	return false
end

local function localUserId() -- 6 equivalent calls inferred from this helper
	local localPlayer = Players.LocalPlayer

	return if localPlayer then localPlayer.UserId else 0
end

function PoolSkins.GetCueStickModelName(p: number?)
	local getEquipped = PoolSkins.GetEquipped

	if not p then
		p = localUserId() -- inferred equivalent call
	end

	local equipped = getEquipped(p, "cueSticks")
	local modelName = equipped and equipped.modelName

	if typeof(modelName) == "string" and modelName ~= "" then
		return modelName
	end

	return nil
end

function PoolSkins.GetCueName(p: number?)
	local getEquipped = PoolSkins.GetEquipped

	if not p then
		p = localUserId() -- inferred equivalent call
	end

	local equipped = getEquipped(p, "cueSticks")
	local cue = equipped and equipped.cue

	if typeof(cue) == "string" and cue ~= "" then
		return cue
	end

	return PoolConstants.DefaultCue
end

function PoolSkins.GetCueLevel(p: number, p2: string?)
	if not p2 or p2 == "" then
		return 0
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(p)))
	local poolCueUpgrades = playerReplica and playerReplica.Data and playerReplica.Data.poolCueUpgrades

	if typeof(poolCueUpgrades) == "table" then
		return (math.max(math.floor(tonumber(poolCueUpgrades[p2]) or 0), 0))
	end

	return 0
end

function PoolSkins.GetEquippedCueLevel(p: number?)
	if not p then
		p = localUserId() -- inferred equivalent call
	end

	return PoolSkins.GetCueLevel(p, PoolSkins.GetEquippedName(p, "cueSticks"))
end

function PoolSkins.GetCueEffects(p: number?)
	if not p then
		p = localUserId() -- inferred equivalent call
	end

	return PoolConstants.CueEffects(PoolSkins.GetCueName(p), PoolSkins.GetEquippedCueLevel(p))
end

function PoolSkins.GetTableModelName(p: number?)
	local getEquipped = PoolSkins.GetEquipped

	if not p then
		p = localUserId() -- inferred equivalent call
	end

	local equipped = getEquipped(p, "poolTables")
	local modelName = equipped and equipped.modelName

	if typeof(modelName) == "string" and modelName ~= "" then
		return modelName
	end

	return nil
end

function PoolSkins.GetPotEffectName(p: number?)
	local getEquippedName = PoolSkins.GetEquippedName

	if not p then
		p = localUserId() -- inferred equivalent call
	end

	local equippedName = getEquippedName(p, "poolEffects")

	if typeof(equippedName) == "string" and equippedName ~= "" then
		return equippedName
	end

	return nil
end

function PoolSkins.GetPotCue(p: string?)
	local potted = PoolConstants.VisualCues.Potted
	local v

	if p then
		v = PoolSkins.GetItem("poolEffects", p)
	end

	if not v or typeof(v.vfxPath) ~= "table" then
		return potted
	end

	local v2 = { Path = v.vfxPath, Timer = potted.Timer, Colour = 0, Scale = 0 }
	local colour

	if v.tint then
		colour = v.colour
	end

	v2.Colour = colour

	v2.Scale = tonumber(v.vfxScale)
	return v2
end

function PoolSkins.IsKnownEntry(p: string, value, p2): boolean
	if typeof(p2) == "table" and typeof(p2.item) == "string" then
		value = p2.item
	end

	return typeof(value) == "string" and PoolSkins.GetItem(p, value) ~= nil
end

function PoolSkins.CountUnseen(p, p2: string)
	if typeof(p) ~= "table" or not PoolSkins.GetCategory(p2) then
		return 0
	end

	local v

	if typeof(p.inventory) == "table" then
		v = p.inventory[p2]
	else
		v = false
	end

	if typeof(v) ~= "table" then
		return 0
	end

	local poolSeenItems = p.poolSeenItems
	local v2

	if typeof(poolSeenItems) == "table" then
		v2 = poolSeenItems[p2]
	else
		v2 = false
	end

	local v3 = typeof(v2) ~= "table" and {} or v2
	local count = 0

	for k, v4 in v do
		if not PoolSkins.IsKnownEntry(p2, k, v4) or v3[k] then
			continue
		end

		count += 1
	end

	return count
end

function PoolSkins.CountAllUnseen(p)
	local total = 0

	for _, category in PoolSkins.Categories do
		total += PoolSkins.CountUnseen(p, category.Id)
	end

	return total
end

return PoolSkins