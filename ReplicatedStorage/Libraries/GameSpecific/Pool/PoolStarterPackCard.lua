local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolSkins = require(Pool.PoolSkins)

local PoolStarterPackCard = {}

local POOL_STARTER_PACK_INFO = MonetizationConstants.POOL_STARTER_PACK_INFO
local Menu = PoolConstants.Menu

local color = Color3.fromRGB(120, 215, 255)

local function buildTile(rewards, layoutOrder: number, text: string, p, image: string?, color2: Color3?, text2: string?)
	local frame = Instance.new("Frame")
	frame.Name = "Reward" .. layoutOrder
	frame.LayoutOrder = layoutOrder
	frame.Size = UDim2.fromScale(0.85, 0.85)
	frame.BackgroundColor3 = Color3.fromRGB(16, 22, 32)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.ZIndex = 1002
	frame.Parent = rewards

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = frame

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.12, 0)
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Color3.fromRGB(8, 10, 14)
	uiStroke.Transparency = 0.25
	uiStroke.Parent = frame
	local v = p ~= nil
	local v2

	if image == nil then
		v2 = false
	else
		v2 = image ~= ""
	end

	local v3 = v or v2

	if v then
		local viewport = Instance.new("ViewportFrame")
		viewport.Name = "Viewport"
		viewport.AnchorPoint = Vector2.new(0.5, 0)
		viewport.Position = UDim2.fromScale(0.5, 0.04)
		viewport.Size = UDim2.fromScale(0.92, 0.62)
		viewport.BackgroundTransparency = 1
		viewport.ZIndex = 1003
		viewport.Parent = frame

		PoolMenuWidgets.ModelPreview(viewport, p)
	elseif v2 then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.AnchorPoint = Vector2.new(0.5, 0)
		icon.Position = UDim2.fromScale(0.5, 0.08)
		icon.Size = UDim2.fromScale(0.62, 0.52)
		icon.BackgroundTransparency = 1
		icon.Image = image
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ZIndex = 1003
		icon.Parent = frame
	end

	local v4

	if text2 == nil then
		v4 = false
	else
		v4 = text2 ~= ""
	end

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.fromScale(0.5, v4 and (v3 and 0.82 or 0.6) or v3 and 0.96 or 0.72)
	label.Size = UDim2.fromScale(0.9, v4 and (v3 and 0.22 or 0.26) or v3 and 0.3 or 0.34)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = color2 or Menu.TextPrimary
	label.FontFace = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	label.ZIndex = 1003
	label.Parent = frame

	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2
	uiStroke2.Color = Color3.fromRGB(20, 12, 6)
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke2.Parent = label

	if not v4 then
		return frame
	end

	local kind = Instance.new("TextLabel")
	kind.Name = "Type"
	kind.AnchorPoint = Vector2.new(0.5, 1)
	kind.Position = UDim2.fromScale(0.5, v3 and 0.99 or 0.78)
	kind.Size = UDim2.fromScale(0.9, v3 and 0.15 or 0.17)
	kind.BackgroundTransparency = 1
	kind.Text = text2
	kind.TextScaled = true
	kind.TextColor3 = Menu.TextMuted
	kind.FontFace = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	kind.ZIndex = 1003
	kind.Parent = frame

	return frame
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolStarterPackCard: %s.%s is missing (looking for %q)",
					instance:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

function PoolStarterPackCard.new(p)
	local maid = Maid.new()
	local tileMaid = Maid.new()
	maid:GiveTask(tileMaid)

	local section = bind(p, "Starterpack")
	local header = bind(p, "StarterpackHeader")
	local folder = bind(section, tostring(POOL_STARTER_PACK_INFO.productId))
	local rewards = bind(folder, "Rewards")

	local labels = {}

	for _, label in folder:GetDescendants() do
		if label:IsA("TextLabel") and label.Name == "Robux" then
			table.insert(labels, label)
		end
	end

	local timer = folder:FindFirstChild("Timer")

	local v = {
		Section = section,
		Header = header,
		Tile = folder,
		Rewards = rewards,
		Robux = labels,
		Timer = 0,
		Maid = 0,
		TileMaid = 0
	}

	if not (timer and timer:IsA("TextLabel")) then
		timer = nil
	end

	v.Timer = timer
	v.Maid = maid
	v.TileMaid = tileMaid

	PoolStarterPackCard.BuildRewards(v)

	local thread = task.spawn(function()
		while true do
			if v.Section.Visible then
				local timeLeft = PoolStarterPackCard.GetTimeLeft()

				if v.Timer then
					v.Timer.Text = PoolStarterPackCard.FormatDeadline(timeLeft)
				end

				if timeLeft <= 0 then
					PoolStarterPackCard.SetVisible(v, false)
				end
			end

			task.wait(1)
		end
	end)

	maid:GiveTask(function()
		task.cancel(thread)
	end)

	local button = folder:FindFirstChild("Button", true)

	if button and button:IsA("GuiButton") then
		maid:GiveTask(button.Activated:Connect(function()
			PoolStarterPackCard.Prompt()
		end))
	end

	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(POOL_STARTER_PACK_INFO.productId, Enum.InfoType.Product)
			end)

			if success and result and result.PriceInRobux then
				for _, v2 in labels do
					v2.Text = tostring(result.PriceInRobux)
				end

				break
			end

			task.wait(1)
		end
	end)

	return v
end

function PoolStarterPackCard.BuildRewards(p)
	p.TileMaid:DoCleaning()
	local count = 0

	for _, skin in POOL_STARTER_PACK_INFO.skins do
		count += 1

		local item = PoolSkins.GetItem(skin.category, skin.item)
		local v

		if item and item.name then
			v = tostring(item.name)
		else
			v = skin.item
		end

		local skinModel = PoolMenuWidgets.FindSkinModel(item)
		local image

		if item and item.image then
			image = tostring(item.image)
		end

		local category = PoolSkins.GetCategory(skin.category)
		local v2

		if item and item.itemType then
			v2 = tostring(item.itemType)
		else
			v2 = not (category and category.Label) and "" or tostring(category.Label)
		end

		p.TileMaid:GiveTask(buildTile(p.Rewards, count, string.upper(v), skinModel, image, nil, string.upper(v2)))
	end

	local layoutOrder = count + 1

	p.TileMaid:GiveTask(buildTile(
		p.Rewards,
		layoutOrder,
		"+" .. NumberHelper:Separate(POOL_STARTER_PACK_INFO.gems),
		nil,
		"rbxassetid://91068843812037",
		color,
		"GEMS"
	))
end

function PoolStarterPackCard.Prompt()
	local localPlayer = Players.LocalPlayer

	if not (localPlayer and PoolStarterPackCard.CanBuy()) then
		return
	end

	Sales.Prompt(tostring(localPlayer.UserId), POOL_STARTER_PACK_INFO.productId, Enum.InfoType.Product, nil, nil)
end

function PoolStarterPackCard.SetVisible(p, visible: boolean)
	p.Section.Visible = visible
	p.Header.Visible = visible
end

function PoolStarterPackCard.CanBuy()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local success, result = pcall(POOL_STARTER_PACK_INFO.canBuy, localPlayer)

	return success and result == true
end

function PoolStarterPackCard.GetTimeLeft()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return 0
	end

	local success, result = pcall(POOL_STARTER_PACK_INFO.getTimeLeft, localPlayer)

	return if success and typeof(result) == "number" then result else 0
end

function PoolStarterPackCard.FormatDeadline(p: number)
	return "ENDS IN " .. NumberHelper.FormatTimerHMS((math.max(p, 0)))
end

function PoolStarterPackCard.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolStarterPackCard