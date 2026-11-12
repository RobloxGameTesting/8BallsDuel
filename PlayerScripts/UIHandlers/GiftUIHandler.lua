local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local MarketplaceService = game:GetService("MarketplaceService")
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Menu)

local LocalPlayer = Players.LocalPlayer
local gift = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GiftUI").Gift
local v = Maid.new()

UserInterfaceHelper:FitScrollingFrame(gift.Content, "Y", UDim2.new(0, 0, 0, 10))

local function addPlayer(userId)
	local playerByUserId = Players:GetPlayerByUserId(userId)
	local clone = ReplicatedStorage.Assets.UI.GiftLabel:Clone()
	clone.Name = userId
	clone.Label.Text = PlayerHelpers.GetName(playerByUserId)
	clone.Parent = gift.Content
	v[userId] = clone

	Button.Create(clone, function()
		local giftId = Sales.GetGiftId()

		if not giftId then
			return
		end

		Sales.Set(LocalPlayer, giftId, true, userId)
		MarketplaceService:PromptProductPurchase(LocalPlayer, giftId)
	end)

	clone.PlayerIcon.Image = PlayerHelpers.GetProfileIcon(playerByUserId) or ""
end

local function removePlayer(userId) -- 1 equivalent call inferred from this helper
	v[userId] = nil
end

for _, v2 in Players:GetPlayers(), nil, nil do
	addPlayer(tostring(v2.UserId))
end

Players.PlayerAdded:Connect(function(player)
	addPlayer(tostring(player.UserId))
end)
Players.PlayerRemoving:Connect(function(player)
	removePlayer(tostring(player.UserId)) -- inferred equivalent call
end)