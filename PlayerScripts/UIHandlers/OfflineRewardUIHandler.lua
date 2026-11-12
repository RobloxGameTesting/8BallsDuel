local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Modules"):WaitForChild("Profiles"))
game:GetService("TweenService")
game:GetService("SoundService")
game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Device)
game:GetService("CollectionService")
require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
require(ReplicatedStorage.Libraries.Modules.Light)
require(ReplicatedStorage.Libraries.Modules.Music)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Classes.Inventories)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local CurrencyHelper = require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
Profiles.GetReplica("Game")
local content = PlayerGui:WaitForChild("OfflineRewardUI").Background.Content
local replica = Profiles.GetReplica("Game")

local function update()
	local offlineRewards = v.Data.offlineRewards

	if TableHelper:Count(offlineRewards) > 0 then
		for childName, offlineReward in offlineRewards do
			local child = content:FindFirstChild(childName)
			local formatMoney = CurrencyHelper.FormatMoney(offlineReward)

			child.Label.Text = "+" .. formatMoney
		end
	end
end

local function claim()
	local effect = UserInterfaceHelper.Effect("ParticleRain")
	local fullScreenNotifications = PlayerGui:WaitForChild("EffectUI"):WaitForChild("FullScreenNotifications")

	effect.new(fullScreenNotifications, "rbxassetid://123893377813143")
	effect.new(fullScreenNotifications, "rbxassetid://17092093716")

	Sounds.Play(Sounds.new({ "Loot", "Tier1" }, nil), nil, true)
	Sounds.Play(Sounds.new({ "Loot", "Tier2" }, nil), nil, true)
	Sounds.Play(Sounds.new({ "UserInterface", "Transactions", "Tier4" }, nil), nil, true)

	Menu.Close("OfflineReward")
end

update()
v:ListenToWrite("OfflineRewards", update)
v:ListenToWrite("ResetOfflineRewards", claim)

Button.Create(content.Claim, function()
	replica:FireServer("OfflineClaim")
end)