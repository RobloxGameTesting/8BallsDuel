local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolicyServiceHelper = require(ReplicatedStorage.Libraries.Helpers.PolicyServiceHelper)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local v = PolicyServiceHelper:Get(LocalPlayer)

local function hide(guiObject, ...): boolean
	for _, childName in { ... } do
		if not guiObject then
			return false
		end

		guiObject = guiObject:FindFirstChild(childName)
	end

	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Visible = false

		return true
	end

	return false
end

local v2 = false

local function setVisible()
	if not v.ArePaidRandomItemsRestricted then
		return
	end

	local shopUI = PlayerGui:FindFirstChild("ShopUI")

	local poolMenuUI = PlayerGui:FindFirstChild("PoolMenuUI")
	local _eventsMenu = poolMenuUI and poolMenuUI:FindFirstChild("EventsMenu")
	local spinUI = PlayerGui:FindFirstChild("SpinUI")

	if shopUI then
		local v3 = hide(shopUI, "Categories", "CurrencyHeader")
		local v4 = hide(shopUI, "Menus", "CurrencyHeader")
		local v5 = hide(shopUI, "Menus", "Currency")

		if not (v3 or v4 or v5 or v2) then
			v2 = true
			warn("[PolicyService] ArePaidRandomItemsRestricted is set, but none of the shop currency paths exist any more -- the restriction is NOT being applied to ShopUI. The paths need re-pointing at the rebuilt shop.")
		end
	end

	hide(spinUI, "BuySpins")
end

setVisible()
PlayerGui.ChildAdded:Connect(setVisible)