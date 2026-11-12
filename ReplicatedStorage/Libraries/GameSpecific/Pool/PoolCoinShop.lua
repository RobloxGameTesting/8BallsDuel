local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local PoolGiftPicker = require(script.Parent.PoolGiftPicker)

local POOL_COIN_PACKS = MonetizationConstants.POOL_COIN_PACKS

local function fetchPrice(productId: number, labels) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
			end)

			if success and result and result.PriceInRobux then
				for _, item in labels do
					if item.Parent then
						item.Text = tostring(result.PriceInRobux)
					end
				end

				break
			end

			task.wait(1)
		end
	end)
end

local function hideEmptyRows(instance, frames)
	local v = {}

	for _, v2 in POOL_COIN_PACKS do
		local child = instance:FindFirstChild(v2.key, true)

		if child and child.Parent and child.Parent ~= instance then
			v[child.Parent] = v[child.Parent] or false
		end
	end

	for _, item in frames do
		if item.Parent then
			v[item.Parent] = true
		end
	end

	for guiObject, visible in v do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = visible
		end
	end
end

local PoolCoinShop = {}

function PoolCoinShop.new(instance)
	local maid = Maid.new()

	local coinsHeader = instance:FindFirstChild("CoinsHeader")
	local frames = {}

	for _, v in POOL_COIN_PACKS do
		local frame = instance:FindFirstChild(v.key, true)

		if frame and frame:IsA("Frame") then
			local productId = v.productId

			frame.Visible = true
			table.insert(frames, frame)

			local label = frame:FindFirstChild("Label")

			if label and label:IsA("TextLabel") then
				label.Text = "+" .. NumberHelper:Separate(v.coins)
			end

			local labels = {}

			for _, label2 in frame:GetDescendants() do
				if not (label2:IsA("TextLabel") and label2.Name == "Robux") then
					continue
				end

				label2.Text = "..."
				table.insert(labels, label2)
			end

			local button = frame:FindFirstChild("Button", true)

			if button and button:IsA("GuiButton") then
				maid:GiveTask(button.Activated:Connect(function()
					local localPlayer = Players.LocalPlayer

					if localPlayer then
						Sales.Prompt(tostring(localPlayer.UserId), productId, Enum.InfoType.Product, nil, nil)
					end
				end))
			end

			fetchPrice(productId, labels) -- inferred equivalent call
			local purchase = frame:FindFirstChild("Purchase")

			if purchase and purchase:IsA("GuiObject") then
				maid:GiveTask(PoolGiftPicker.Badge(purchase, productId))
			end
		else
			warn(string.format(
				"PoolCoinShop: no authored tile named %s under %s -- that tier will not be sold",
				v.key,
				instance:GetFullName()
			))
		end
	end

	hideEmptyRows(instance, frames)

	if coinsHeader and coinsHeader:IsA("GuiObject") then
		coinsHeader.Visible = #frames > 0
	end

	if not (coinsHeader and coinsHeader:IsA("GuiObject")) then
		coinsHeader = nil
	end

	return { Header = coinsHeader, Tiles = frames, Maid = maid }
end

function PoolCoinShop.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolCoinShop