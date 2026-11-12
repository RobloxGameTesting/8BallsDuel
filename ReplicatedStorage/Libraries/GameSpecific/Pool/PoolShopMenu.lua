local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolCoinShop = require(Pool.PoolCoinShop)
local PoolGemShop = require(Pool.PoolGemShop)
local PoolGalaxyPanel = require(Pool.PoolGalaxyPanel)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolStarterPackCard = require(Pool.PoolStarterPackCard)
local PoolWorldPassCard = require(Pool.PoolWorldPassCard)
local PoolVipPassCard = require(Pool.PoolVipPassCard)

local color = Color3.fromRGB(255, 106, 106)

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolShopMenu: %s.%s is missing (looking for %q)",
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

local PoolShopMenu = {}

function PoolShopMenu.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local shopMenu = instance:WaitForChild("ShopMenu")
	shopMenu.Visible = false

	local parent = bind(shopMenu, "Store")

	local galaxyHeader = Instance.new("Frame")
	galaxyHeader.Name = "GalaxyHeader"
	galaxyHeader.Size = UDim2.fromScale(1, 1)
	galaxyHeader.BackgroundTransparency = 1
	galaxyHeader.BorderSizePixel = 0
	galaxyHeader.LayoutOrder = -9
	galaxyHeader.ZIndex = 1000
	galaxyHeader.Parent = parent
	maid:GiveTask(galaxyHeader)

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 9
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
	uiAspectRatioConstraint.Parent = galaxyHeader

	local label = PoolMenuWidgets.Label(
		galaxyHeader,
		"TextLabel",
		"GALAXY LIMITEDS",
		Color3.fromRGB(255, 255, 255),
		1001
	)

	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.fromScale(0.02, 0.5)
	label.Size = UDim2.fromScale(0.6, 0.8)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local galaxy = Instance.new("Frame")
	galaxy.Name = "Galaxy"
	galaxy.Size = UDim2.fromScale(1, 1)
	galaxy.BackgroundTransparency = 1
	galaxy.BorderSizePixel = 0
	galaxy.LayoutOrder = -8
	galaxy.ZIndex = 1000
	galaxy.Parent = parent
	maid:GiveTask(galaxy)

	local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint2.AspectRatio = 2.1
	uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Width
	uiAspectRatioConstraint2.Parent = galaxy

	local galaxy2 = PoolGalaxyPanel.new(galaxy, 1001)

	local v = {
		Root = shopMenu,
		CoinsLabel = bind(shopMenu, "Coins.Amount"),
		GemsLabel = 0,
		Back = 0,
		Closed = 0,
		CloseBindable = 0,
		StarterPack = 0,
		WorldPass = 0,
		Vip = 0,
		CoinShop = 0,
		GemShop = 0,
		Galaxy = 0,
		CodeBox = 0,
		Maid = 0
	}

	local gems = shopMenu:FindFirstChild("Gems")
	local amount = gems and gems:FindFirstChild("Amount")

	if not (amount and amount:IsA("TextLabel")) then
		amount = nil
	end

	v.GemsLabel = amount

	v.Back = bind(shopMenu, "Back")
	v.Closed = bindableEvent.Event
	v.CloseBindable = bindableEvent
	v.StarterPack = PoolStarterPackCard.new(bind(shopMenu, "Store"))
	v.WorldPass = PoolWorldPassCard.new(bind(shopMenu, "Store"))
	v.Vip = PoolVipPassCard.new(bind(shopMenu, "Store"))
	v.CoinShop = PoolCoinShop.new(bind(shopMenu, "Store"))
	v.GemShop = PoolGemShop.new(bind(shopMenu, "Store"))
	v.Galaxy = galaxy2
	v.CodeBox = bind(shopMenu, "Store.Codes.InputFrame.TextBox")
	v.Maid = maid

	local v2 = bind(shopMenu, "Store.Codes")
	local v3 = bind(v2, "Line1")
	local v4 = bind(v2, "Redeem.Button")

	v2.Visible = false

	v3.Text = "ENTER A CODE"

	local function submit() -- 1 equivalent call inferred from this helper
		local v5 = string.lower((string.gsub(v.CodeBox.Text, "^%s*(.-)%s*$", "%1")))

		if v5 == "" then
			return
		end

		RemoteSignals.FireServer("Codes", "Code", v5)
		v.CodeBox.Text = ""
	end

	maid:GiveTask(v4.Activated:Connect(submit))

	maid:GiveTask(v.CodeBox.FocusLost:Connect(function(flag: boolean)
		if flag then
			submit() -- inferred equivalent call
		end
	end))

	maid:GiveTask(RemoteSignals.OnClientEvent("Codes", function(p: string, flag: boolean?, value: string?)
		if p ~= "Code" then
			return
		end

		local new = Notifications.new
		local v5 = {
			message = flag and "Code redeemed!" or tostring(value or "That code didn't work"),
			colour = 0
		}
		local colour

		if flag then
			colour = Color3.fromRGB(126, 226, 118)
		else
			colour = color
		end

		v5.colour = colour
		new("TextNotification", v5)
	end))

	local uiListLayout = parent:FindFirstChildOfClass("UIListLayout")
	local uiPadding = parent:FindFirstChildOfClass("UIPadding")

	if uiListLayout then
		local function fitCanvas() -- 1 equivalent call inferred from this helper
			local y = uiListLayout.AbsoluteContentSize.Y

			if uiPadding then
				y += uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset
			end

			parent.CanvasSize = UDim2.new(0, 0, 1, (math.max(0, (math.ceil(y - parent.AbsoluteSize.Y)))))
		end

		fitCanvas() -- inferred equivalent call
		maid:GiveTask(uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fitCanvas))
		maid:GiveTask(parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCanvas))
	end

	maid:GiveTask(v.Back.Activated:Connect(function()
		bindableEvent:Fire()
	end))

	return v
end

function PoolShopMenu.Refresh(data, p: number)
	data.CoinsLabel.Text = "$" .. NumberHelper:Separate((math.round(p)))

	local localPlayer = Players.LocalPlayer

	if data.GemsLabel and localPlayer then
		data.GemsLabel.Text = NumberHelper:Separate(PoolPlayerData.GetGems(localPlayer.UserId))
	end

	PoolStarterPackCard.SetVisible(data.StarterPack, PoolStarterPackCard.CanBuy())

	PoolWorldPassCard.Refresh(data.WorldPass)

	PoolVipPassCard.Refresh(data.Vip)
end

function PoolShopMenu.SetVisible(p, visible: boolean)
	p.Root.Visible = visible
end

function PoolShopMenu.SetReplica(p, p2)
	PoolGalaxyPanel.SetReplica(p.Galaxy, p2)
end

function PoolShopMenu.Destroy(data)
	PoolStarterPackCard.Destroy(data.StarterPack)
	PoolVipPassCard.Destroy(data.Vip)
	PoolCoinShop.Destroy(data.CoinShop)
	PoolGemShop.Destroy(data.GemShop)
	PoolGalaxyPanel.Destroy(data.Galaxy)
	data.Maid:DoCleaning()
end

return PoolShopMenu