local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data
local starterWeaponEquipUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StarterWeaponEquipUI")
local CategoryLabel = ReplicatedStorage.Assets.InterfaceAssets.StarterWeaponEquip.CategoryLabel
local content = starterWeaponEquipUI.Content
local header = content.Header
local options = content.Options
local categories = content.Categories
local v = Maid.new()
local slots = Maid.new()
local slotsByToolType = Maid.new()
local isStudio = RunService:IsStudio()
local v2 = { "StarterWeaponEquip" }

local v3 = { "Primary", "Secondary", "Melee", "Utility" }

local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local count = 0
local v4 = {}

local function getOwnedWeaponList()
	local ownedWeaponList = {}

	if isStudio then
		for _, tool in data.inventory.tools do
			local item = tool.item

			if not table.find(ownedWeaponList, item) then
				table.insert(ownedWeaponList, item)
			end
		end
	else
		for _, weaponSlot in data.weaponSlots do
			for _, v5 in weaponSlot do
				local item = v5.item

				if not table.find(ownedWeaponList, item) then
					table.insert(ownedWeaponList, item)
				end
			end
		end
	end

	return ownedWeaponList
end

local function showCategory(childName)
	slots:Destroy()

	header.Label.Text = string.upper(childName)

	local function selectWeapon(p)
		local itemData = InventoryHelpers.GetItemData("Tools", p)
		RemoteSignals.FireServer("StarterWeapon", "StarterWeapon", p)

		local slot = InventoryHelpers.CreateSlot(nil, itemData, categories[childName], "v2")
		slot.Button:Destroy()
		slotsByToolType[itemData.toolType] = slot
		bindableEvent:Fire()
	end

	local count2 = 0
	local v5 = nil
	local v6 = false

	for _, v7 in getOwnedWeaponList(), nil, nil do
		local itemData = InventoryHelpers.GetItemData("Tools", v7)

		if slots[v7] or itemData.toolType ~= childName then
			continue
		end

		count2 += 1

		local slot = InventoryHelpers.CreateSlot(nil, itemData, options, "v2")
		slot.LayoutOrder = -itemData.cost

		Button.Create(slot, function()
			selectWeapon(v7)
		end)

		slots[v7] = slot
		v5 = v7
	end

	if count2 <= 1 then
		v6 = true

		if v5 then
			selectWeapon(v5)
		end
	end

	if not v6 then
		bindableEvent.Event:Wait()
	end

	local index = table.find(v3, childName)
	local v7 = index and index + 1
	return v7 and v3[v7]
end

local function showOrder(childName: string)
	count += 1
	table.find(v3, childName)
	local v5 = count
	local child = categories:FindFirstChild(childName)

	if not child then
		return
	end

	function v.highlightFunction()
		child.Content.Background.Size = UDim2.fromScale(0.9, 0.9)
		child.Content.Background.ImageTransparency = 0.5
		child.Content.Background.ImageColor3 = Color3.fromRGB(94, 94, 94)
	end
	child.Content.Background.Size = UDim2.fromScale(1.15, 1.15)
	child.Content.Background.ImageTransparency = 0
	child.Content.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)

	local v6 = showCategory(childName)

	if v5 ~= count then
		return
	end

	if not v6 then
		bindableEvent2:Fire()

		return
	end

	if not table.find(v4, v6) then
		table.insert(v4, v6)
	end

	showOrder(v6)
end

Menu.Opened:Connect(function(p)
	if p ~= "StarterWeaponEquip" then
		return
	end

	slotsByToolType:Destroy()
	slots:Destroy()

	v4 = { "Primary" }
	showOrder("Primary")
end)

for _, name in v3 do
	local clone = CategoryLabel:Clone()
	clone.Name = name
	clone.Content.Background.Size = UDim2.fromScale(0.9, 0.9)
	clone.Content.Background.ImageTransparency = 0.5
	clone.Parent = categories

	Button.Create(clone, function()
		if not table.find(v4, name) then
			return
		end

		showOrder(name)
	end)
end

bindableEvent2.Event:Connect(function()
	Menu.Close("StarterWeaponEquip")
end)

RemoteSignals.OnClientEvent("StarterWeapon", function(p, ...)
	if not table.find(v2, p) then
		return
	end

	Menu.Open("StarterWeaponEquip")
end)

script:SetAttribute("Loaded", true)