local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
game:GetService("Players")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local Roles = require(ReplicatedStorage.Libraries.GameSpecific.Roles)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local ServerStorage = game:GetService("ServerStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local v = {}

local NameTagHelper = {}

function NameTagHelper.Create(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local userId = tostring(player.UserId)

	if not Profiles.GetPlayerReplica(userId) then
		Profiles.WaitForPlayerReplica(userId)
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	local clone = ServerStorage.Assets.NameUI:Clone()
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
	humanoid.NameDisplayDistance = 0
	clone.DisplayName.Text = player.DisplayName
	clone.Username.Text = player.Name == player.DisplayName and "" or "@" .. player.Name
	clone.Parent = humanoidRootPart
	NameTagHelper.Set(player, clone)

	NameTagHelper.DisplayRole(player)
	NameTagHelper.DisplayScore(player)
end

function NameTagHelper.DisplayRole(p)
	local v2 = NameTagHelper.Get(p)
	local userId = tostring(p.UserId)

	if not v2 then
		return
	end

	local roleModule = Roles.GetRoleModule(userId)
	v2.Title.Text = `[ {roleModule.id} ]`
	v2.Title.UIGradient.Color = Rarities.GetRarityData(roleModule.rarity).colour
end

function NameTagHelper.DisplayScore(p)
	local userId = tostring(p.UserId)
	local playerReplica = Profiles.GetPlayerReplica(userId)
	local v2 = NameTagHelper.Get(p)

	if not v2 then
		return
	end

	if v2 then
		v2.Highscore.Text = playerReplica.Data.topScore
	end
end

function NameTagHelper.PlayerToHideFrom(p, playerToHideFrom)
	local v2 = NameTagHelper.Get(p)

	if not v2 then
		return
	end

	v2.PlayerToHideFrom = playerToHideFrom
end

function NameTagHelper.Get(p)
	return v[tostring(p.UserId)]
end

function NameTagHelper.Set(p, p2)
	local userId = tostring(p.UserId)
	v[userId] = p2
end

return NameTagHelper