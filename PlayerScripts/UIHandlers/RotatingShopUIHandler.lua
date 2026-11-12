local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("RunService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Menu)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Colours = require(ReplicatedStorage.Libraries.Modules.Colours)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local background = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RotatingShopUI").Background
local list = background.Content.List
local timer = background.Header.Timer
local replica = Profiles.GetReplica("Shop")
local Assets = ReplicatedStorage.Assets
local clones = Maid.new()

UserInterfaceHelper:FitScrollingFrame(list, "Y", UDim2.fromOffset(0, 3))

local categoryModules = InventoryHelpers.GetCategoryModules("Gloves")

for k, _ in categoryModules do
	local itemData = InventoryHelpers.GetItemData("Gloves", k)
	local clone = Assets.UI.Shop.RotatingItemFrame:Clone()
	clone.Name = itemData.name
	clone.LayoutOrder = itemData.price
	clone.Currency.Label.Text = `${NumberHelper:Abbreviate(itemData.price, 0, false)}`
	clone.Description.Text = `{itemData.damage.min}-{itemData.damage.max} Damage Per Slap`
	clone.Label.Text = itemData.name
	clone.RebirthCover.Label.Text = `Rebirth {itemData.rebirth} Required`
	clone.Parent = list

	Button.Create(clone.Buy, function()
		local v2 = data.shopPurchases.Gloves
			and data.shopPurchases.Gloves[replica.Data.iteration]
			and data.shopPurchases.Gloves[replica.Data.iteration][k]
			or 0

		if replica.Data.shop.Gloves[k] - v2 == 0 then
			return
		end

		RemoteSignals.FireServer("Shop", "Shop", "rotating", "Gloves", replica.Data.iteration, k)
	end)

	clones[k] = clone
end

local function updateShop()
	local rotating = replica.Data.rotating
	local iteration = tostring(replica.Data.iteration)

	for _, v2 in rotating do
		for k, _ in v2 do
			local v3 = data.shopPurchases.Gloves
				and data.shopPurchases.Gloves[iteration]
				and data.shopPurchases.Gloves[iteration][k]
				or 0

			local v4 = replica.Data.shop.Gloves[k] - v3

			local itemData = InventoryHelpers.GetItemData("Gloves", k)
			local v5 = clones[k]

			v5.Available.Text = `Available: {v4}`
			v5.RebirthCover.Visible = itemData.rebirth > data.rebirth
			v5.Buy.Content.Background.UIGradient.Color = Colours.questComplete

			if v4 == 0 then
				v5.Buy.Content.Background.UIGradient.Color = Colours.err
				v5.Buy.Content.Label.Text = "SOLD OUT"
			else
				v5.Buy.Content.Label.Text = "Buy 1x"
			end
		end
	end
end

local function setTimer()
	timer.Text = NumberHelper.FormatTimerHMS(replica.Data.timeLeft)
end

updateShop()
timer.Text = NumberHelper.FormatTimerHMS(replica.Data.timeLeft)

v:ListenToWrite("Inventory", updateShop)
v:ListenToWrite("Equipped", updateShop)
v:ListenToWrite("ShopPurchase", updateShop)
replica:ListenToWrite("TimeLeft", setTimer)
replica:ListenToWrite("Rotating", updateShop)
replica:ListenToWrite("Iteration", updateShop)