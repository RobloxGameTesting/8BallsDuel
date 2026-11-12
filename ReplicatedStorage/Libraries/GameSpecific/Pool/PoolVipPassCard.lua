local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolVip = require(Pool.PoolVip)

local PoolVipPassCard = {}

local POOL_VIP_PASS_INFO = MonetizationConstants.POOL_VIP_PASS_INFO

local function findDescendant(instance, childName: string) -- 3 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName, true)

	if not child then
		error("PoolVipPassCard: no descendant named '" .. childName .. "' under " .. instance:GetFullName())
	end

	return child
end

function PoolVipPassCard.new(instance)
	local maid = Maid.new()
	local section = findDescendant(instance, "VIP") -- inferred equivalent call
	local folder = findDescendant(section, "Buy") -- inferred equivalent call
	local button = findDescendant(folder, "Button") -- inferred equivalent call
	local labels = {}

	for _, label in folder:GetDescendants() do
		if not (label:IsA("TextLabel") and label.Name == "Robux") then
			continue
		end

		label.Text = "..."
		table.insert(labels, label)
	end

	local v = {
		Section = section,
		Buy = folder,
		Button = button,
		RobuxLabels = labels,
		Price = POOL_VIP_PASS_INFO.fallbackPrice,
		Owned = false,
		Maid = maid
	}

	maid:GiveTask(button.Activated:Connect(function()
		if PoolVipPassCard.IsOwned() then
			return
		end

		PoolVipPassCard.Prompt()
	end))

	PoolVipPassCard.Refresh(v)
	PoolVipPassCard.FetchPrice(v)

	return v
end

function PoolVipPassCard:FetchPrice()
	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(POOL_VIP_PASS_INFO.gamepassId, Enum.InfoType.GamePass)
			end)

			if success and result and result.PriceInRobux then
				self.Price = result.PriceInRobux

				PoolVipPassCard.Refresh(self)
				break
			end

			task.wait(1)
		end
	end)
end

function PoolVipPassCard.IsOwned()
	local localPlayer = Players.LocalPlayer

	return localPlayer ~= nil and PoolVip.Owns(localPlayer.UserId)
end

function PoolVipPassCard:Refresh()
	local isOwned = PoolVipPassCard.IsOwned()

	self.Owned = isOwned
	self.Buy.Visible = not isOwned
	self.Button.Active = not isOwned

	for _, robuxLabel in self.RobuxLabels do
		robuxLabel.Text = tostring(self.Price)
	end
end

function PoolVipPassCard.Prompt()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	Sales.Prompt(tostring(localPlayer.UserId), POOL_VIP_PASS_INFO.gamepassId, Enum.InfoType.GamePass, nil, nil)
end

function PoolVipPassCard.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolVipPassCard