local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local effectUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
local v2 = Maid.new()
local Boost = ReplicatedStorage.Assets.UI.Boost
local boosts = effectUI.Boosts

local function createBoost(k)
	local itemData = InventoryHelpers.GetItemData("Misc", k)
	local clone = Boost:Clone()
	clone.Content.Label.Text = itemData.labelTop({ value = 0 }, nil)
	clone.Content.Icon.Image = itemData.image(nil, nil)
	clone.Content.Hover.Title.Text = itemData.labelBottom()
	clone.Parent = boosts

	v2[k .. "MouseEnter"] = clone.MouseEnter:Connect(function()
		clone.Content.Hover.Visible = true
	end)

	v2[k .. "MouseLeave"] = clone.MouseLeave:Connect(function()
		clone.Content.Hover.Visible = false
	end)

	return clone
end

local function updateBoosts()
	for k, boost in data.boosts do
		if boost == 0 then
			v2[k] = nil
		else
			local itemData = InventoryHelpers.GetItemData("Misc", k)
			local v3 = v2[k] or createBoost(k)
			v3.Content.Label.Text = itemData.labelTop({ value = boost }, nil)
			v2[k] = v3
		end
	end
end

v:ListenToWrite("Boost", updateBoosts)

while true do
	updateBoosts()
	task.wait(1)
end