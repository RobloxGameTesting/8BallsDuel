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
require(ReplicatedStorage.Types.Types)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryTypes)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local background = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ShopUI").Background
local list = background.Content.List
local header = background.Header
local replica = Profiles.GetReplica("Shop")
local Assets = ReplicatedStorage.Assets
local clones = Maid.new()

local v2 = string.lower("Gloves")

UserInterfaceHelper:FitScrollingFrame(list, "Y", UDim2.fromOffset(0, 3))

local categoryModules = InventoryHelpers.GetCategoryModules("Gloves")

for k, _ in categoryModules do
	local itemData = InventoryHelpers.GetItemData("Gloves", k)
	local clone = Assets.UI.Shop.ItemFrame:Clone()
	clone.Name = itemData.name
	clone.LayoutOrder = itemData.price
	clone.Currency.Label.Text = `${NumberHelper:Abbreviate(itemData.price, 0, false)}`
	clone.Description.Text = `{itemData.damage.min}-{itemData.damage.max} Damage Per Slap`
	clone.Label.Text = itemData.name
	clone.RebirthCover.Label.Text = `Rebirth {itemData.rebirth} Required`
	clone.Parent = list

	Button.Create(clone.Buy, function()
		if InventoryHelpers.OwnsItem(LocalPlayer, v2, k) then
			RemoteSignals.FireServer("Shop", "Equip", v2, k)
		else
			RemoteSignals.FireServer("Shop", "Shop", "rotating", "Gloves", replica.Data.iteration, k)
		end
	end)

	clones[k] = clone
end

local function updateShop()
	local gloves = replica.Data.shop.Gloves
	tostring(replica.Data.iteration)

	for k, _ in gloves do
		local itemData = InventoryHelpers.GetItemData("Gloves", k)
		local v3 = clones[k]

		v3.RebirthCover.Visible = itemData.rebirth > data.rebirth

		if InventoryHelpers.OwnsItem(LocalPlayer, v2, k) then
			if table.find(data.equipped[v2], k) then
				v3.Buy.Content.Label.Text = "Unequip"
				v3.Buy.Content.Background.UIGradient.Color = Colours.err
			else
				v3.Buy.Content.Label.Text = "Equip"
				v3.Buy.Content.Background.UIGradient.Color = Colours.eventCurrency
			end
		else
			v3.Buy.Content.Background.UIGradient.Color = Colours.questComplete
			v3.Buy.Content.Label.Text = "Buy"
		end
	end
end

updateShop()
v:ListenToWrite("Inventory", updateShop)
v:ListenToWrite("Equipped", updateShop)
v:ListenToWrite("ShopPurchase", updateShop)
replica:ListenToWrite("Shop", updateShop)