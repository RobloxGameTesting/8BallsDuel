local CollectionService = game:GetService("CollectionService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local MarketplaceService = game:GetService("MarketplaceService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)

local userId = tostring(Players.LocalPlayer.UserId)

local function apply(child)
	local name = tonumber(child.Name)
	local robux = child:FindFirstChild("Robux", true)
	local amount = child:FindFirstChild("Amount", true)

	if not name then
		warn("Product name isn't a number")
		return
	end

	local gamePass = child:GetAttribute("InfoType") == "Gamepass" and Enum.InfoType.GamePass or Enum.InfoType.Product

	Button.Create(child, function()
		local name2 = tonumber(child.Name)

		if not name2 then
			return
		end

		Sales.Prompt(userId, name2, gamePass, nil, nil)
		Sounds.Play(Sounds.new({ "Abilities", "Curve" }, nil), nil, true)
	end)

	task.spawn(function()
		for _ = 1, 10 do
			if pcall(function()
				local productInfoAsync = MarketplaceService:GetProductInfoAsync(name, gamePass)

				if robux then
					robux.Text = productInfoAsync.PriceInRobux
				end

				if amount then
					if MonetizationConstants.PRODUCT_IDS.CURRENCY1_RATES[name] then
						amount.Text = `+{NumberHelper:Separate(MonetizationConstants.PRODUCT_IDS.CURRENCY1_RATES[name])} Coins`
					elseif MonetizationConstants.PRODUCT_IDS.SPINS_RATES[name] then
						amount.Text = `+{NumberHelper:Separate(MonetizationConstants.PRODUCT_IDS.SPINS_RATES[name])} Spins`
					elseif MonetizationConstants.PRODUCT_IDS.PREMIUM_ROLE_SPIN_RATES[name] then
						amount.Text = `{NumberHelper:Separate(MonetizationConstants.PRODUCT_IDS.PREMIUM_ROLE_SPIN_RATES[name])} ROLE SPINS`
					elseif MonetizationConstants.PRODUCT_IDS.ROLE_SPIN_RATES[name] then
						amount.Text = `{NumberHelper:Separate(MonetizationConstants.PRODUCT_IDS.ROLE_SPIN_RATES[name])} ROLE SPINS`
					elseif MonetizationConstants.PRODUCT_IDS.WEAPON_SPIN_RATES[name] then
						amount.Text = `{NumberHelper:Separate(MonetizationConstants.PRODUCT_IDS.WEAPON_SPIN_RATES[name])} WEAPON SPINS`
					elseif MonetizationConstants.PRODUCT_IDS.PREMIUM_WEAPON_SPIN_RATES[name] then
						amount.Text = `{NumberHelper:Separate(MonetizationConstants.PRODUCT_IDS.PREMIUM_WEAPON_SPIN_RATES[name])} WEAPON SPINS`
					end
				end
			end) then
				break
			end

			task.wait(1)
		end
	end)
end

local function tag(frame)
	for _, child in frame:GetChildren(), nil, nil do
		local button = child:FindFirstChild("Button")

		if child:GetAttribute("InfoType") ~= "Gamepass" or not Enum.InfoType.GamePass then
			local _product = Enum.InfoType.Product
		end

		if not button then
			continue
		end

		apply(child)
		child:GetPropertyChangedSignal("Name"):Connect(function()
			apply(child)
		end)

		local gift = child:FindFirstChild("Gift", true)

		if gift and gift:IsA("Frame") then
			Button.Create(gift, function()
				Menu.Open("Gift")
				Sounds.Play(Sounds.new({ "UserInterface", "Transactions", "Starterpack" }, nil), nil, true)
			end)
		end
	end
end

local function removeTag() end

CollectionService:GetInstanceRemovedSignal("RobuxShop"):Connect(removeTag)
CollectionService:GetInstanceAddedSignal("RobuxShop"):Connect(tag)

for _, frame in CollectionService:GetTagged("RobuxShop"), nil, nil do
	if frame:IsA("Frame") then
		tag(frame)
	else
		warn(`RobuxShop tagged item isn't a frame: {frame:GetFullName()}`)
	end
end