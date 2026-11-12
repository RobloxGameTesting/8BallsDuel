local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
game:GetService("TweenService")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Mouselock)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local StringHelper = require(ReplicatedStorage.Libraries.Helpers.StringHelper)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
game:GetService("StarterPlayer")
require(ReplicatedStorage.Libraries.Modules.MechanicHandler)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = workspace.CurrentCamera
local ToolsUI = PlayerGui:WaitForChild("ToolsUI")
local MainPanel = ToolsUI.MainPanel
local RightPanel = ToolsUI.RightPanel
local LeftPanel = ToolsUI.LeftPanel
local Assets = ReplicatedStorage.Assets
local Equipped = Assets.InterfaceAssets.Tools.Equipped
local Label = Assets.InterfaceAssets.Tools.Label
local Lock = Assets.InterfaceAssets.Tools.Lock
local clones = Maid.new()
local v2 = Maid.new()
local v3 = { "WeaponSlotSpin" }

local v4 = "primary"
local v5 = nil

UserInterfaceHelper:FitScrollingFrame(LeftPanel.Content, "Y", UDim2.fromOffset(0, 5))

local function displayOdds(p)
	RightPanel.Drops.Weapons.Visible = false
	v5 = nil

	for _, child in RightPanel.Drops:GetChildren(), nil, nil do
		if not child:FindFirstChild("Button") then
			continue
		end

		local name = child.Name
		local v6 = Rarities.GetRarityData(name).percent[p]

		if v6 == 0 then
			child.Visible = false
		else
			child.Visible = true
			child.Content.Label.Text = `{string.upper(name)} [ {v6}% ]`
		end
	end
end

displayOdds("Normal")
Button.Create(RightPanel.NormalOdds, function()
	displayOdds("Normal")
end)
Button.Create(RightPanel.PremiumOdds, function()
	displayOdds("Premium")
end)

UserInterfaceHelper.Effect("YellowSparkles").new(RightPanel.Drops.Golden.Content)
local flag = false

for _, child in RightPanel.Drops:GetChildren(), nil, nil do
	if not child:FindFirstChild("Button") then
		continue
	end

	local name = child.Name

	Button.Create(child, function()
		clones:Destroy()

		if v5 == name then
			v5 = nil
			RightPanel.Drops.Weapons.Visible = false
		else
			local count = 0

			for k, v6 in InventoryHelpers.GetCategoryModules("Tools"), nil, nil do
				if not (v6.rarity() == name and StringHelper.Capitalize(v4) == v6.toolType) then
					continue
				end

				count += 1
				local clone = Label:Clone()
				clone.Label.Text = `[ {v6.id} ]`
				clone.Parent = RightPanel.Drops.Weapons
				clones[k] = clone
			end

			RightPanel.Drops.Weapons.UIAspectRatioConstraint.AspectRatio = 8 / count
			RightPanel.Drops.Weapons.Visible = true
			RightPanel.Drops.Weapons.LayoutOrder = RightPanel.Drops[name].LayoutOrder + 1
			v5 = name
		end
	end)
end

local function updateWeapons()
	if flag then
		return
	end

	for _, child in LeftPanel.Content:GetChildren(), nil, nil do
		if not string.find(child.Name, "Slot") then
			continue
		end

		child.Content.Backing.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		child.Content.Label.Text = child.Name

		local lock = child.Content:FindFirstChild("Lock")

		if lock then
			lock:Destroy()
		end
	end

	for k, v6 in data.weaponSlots[v4] do
		local itemData = InventoryHelpers.GetItemData("Tools", v6.item)
		local rarity = itemData.rarity()
		local id = itemData.id

		local parent = LeftPanel.Content["Slot" .. k]
		parent.Content.Backing.UIGradient.Color = Rarities.GetRarityData(rarity).colour
		parent.Content.Label.Text = `[ {id} ]`

		if k == data.selectedWeaponSlot[v4] then
			Equipped.Parent = parent

			MainPanel.Weapon.Text = `[ {id} ]`
			MainPanel.Weapon.UIGradient.Color = Rarities.GetRarityData(rarity).colour
			MainPanel.WeaponType.Text = `{itemData.toolType} Weapon`
			MainPanel.Description.Text = itemData.description
		end

		if v6.locked then
			if not parent.Content:FindFirstChild("Lock") then
				local clone = Lock:Clone()
				clone.Parent = parent.Content
			end
		else
			local lock = parent.Content:FindFirstChild("Lock")

			if lock then
				lock:Destroy()
			end
		end
	end
end

Button.Create(LeftPanel.Lock, function()
	if flag then
		return
	end

	RemoteSignals.FireServer("WeaponSlots", "WeaponSlotLock", v4)
end)

for _, child in LeftPanel.Content:GetChildren(), nil, nil do
	if not child:FindFirstChild("Button") then
		continue
	end

	local v6 = tonumber(string.match(child.Name, "%d+"))

	if v6 then
		Button.Create(child, function()
			if flag then
				return
			end

			RemoteSignals.FireServer("WeaponSlots", "WeaponSlotEquip", v4, v6)
		end)
	end
end

updateWeapons()
v:ListenToWrite("WeaponSlotLock", updateWeapons)
v:ListenToWrite("WeaponSlotEquip", updateWeapons)
v:ListenToWrite("WeaponSlotChange", updateWeapons)
v:ListenToWrite("WeaponSlotAdd", updateWeapons)

local childrenByName = {}

for _, child in MainPanel.Categories:GetChildren(), nil, nil do
	if not child:FindFirstChild("Button") then
		continue
	end

	childrenByName[child.Name] = child

	Button.Create(child, function()
		if flag or child == v4 then
			return
		end

		Button.SetColours(childrenByName, child.Name, "green", "white")
		v4 = string.lower(child.Name)
		RightPanel.Drops.Weapons.Visible = false
		v5 = nil
		updateWeapons()
	end)
end

Button.SetColours(childrenByName, "Primary", "green", "white")

local function updateSpins()
	if data.premiumWeaponSpins <= 0 then
		MainPanel.PremiumSpin.Content.Count.Text = `{1000} coins`
	else
		MainPanel.PremiumSpin.Content.Count.Text = `{data.premiumWeaponSpins}x`
	end

	if data.weaponSpins <= 0 then
		MainPanel.NormalSpin.Content.Count.Text = `{100} coins`
	else
		MainPanel.NormalSpin.Content.Count.Text = `{data.weaponSpins}x`
	end
end

updateSpins()
v:ListenToWrite("WeaponSpins", updateSpins)
v:ListenToWrite("PremiumWeaponSpins", updateSpins)

Button.Create(MainPanel.NormalSpin.Buy, function()
	Menu.Open("WeaponSpins")
end)

Button.Create(MainPanel.PremiumSpin.Buy, function()
	Menu.Open("PremiumWeaponSpins")
end)

Button.Create(MainPanel.PremiumSpin, function()
	if flag then
		return
	end

	RemoteSignals.FireServer("WeaponSlots", "WeaponSlotSpin", v4, "Premium")
end)

Button.Create(MainPanel.NormalSpin, function()
	if flag then
		return
	end

	RemoteSignals.FireServer("WeaponSlots", "WeaponSlotSpin", v4, "Normal")
end)

Menu.Opened:Connect(function(p)
	if p == "Tools" then
		local character = LocalPlayer.Character
		local nameUI = (character and character:FindFirstChild("HumanoidRootPart")):WaitForChild("NameUI")

		if character then
			character:FindFirstChildWhichIsA("Humanoid")
		end

		nameUI.PlayerToHideFrom = LocalPlayer

		v2.cameraConnection = RunService.Heartbeat:Connect(function()
			local character2 = LocalPlayer.Character
			local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return
			end

			CurrentCamera.CFrame = CFrame.new(
				humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 8,
				humanoidRootPart.Position
			)
			CurrentCamera.CameraType = Enum.CameraType.Scriptable
		end)
	end
end)

Menu.Closed:Connect(function(p)
	if p == "Tools" then
		local character = LocalPlayer.Character
		local nameUI = (character and character:FindFirstChild("HumanoidRootPart")):WaitForChild("NameUI")

		nameUI.PlayerToHideFrom = nil

		v2:Destroy()

		CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end)

RemoteSignals.OnClientEvent("WeaponSlots", function(p, p2, p3)
	if not table.find(v3, p) then
		return
	end

	flag = true

	local function display(p4)
		local itemData = InventoryHelpers.GetItemData("Tools", p4)
		local rarity = itemData.rarity()
		local id = itemData.id

		MainPanel.Weapon.Text = `[ {id} ]`
		MainPanel.Weapon.UIGradient.Color = Rarities.GetRarityData(rarity).colour
		MainPanel.WeaponType.Text = itemData.toolType
		MainPanel.Description.Text = itemData.description

		local v6 = LeftPanel.Content[`Slot{p2}`]
		v6.Content.Backing.UIGradient.Color = Rarities.GetRarityData(rarity).colour
		v6.Content.Label.Text = `[ {id} ]`
	end

	local categoryModules = InventoryHelpers.GetCategoryModules("Tools")

	local keysToArray = TableHelper.KeysToArray(categoryModules)

	for _ = 1, 30 do
		display(keysToArray[Random.new():NextInteger(1, #keysToArray)])
		Sounds.Play(Sounds.new({ "Freebie" }, LocalPlayer.Character.HumanoidRootPart), nil, true)
		task.wait(0.05)
	end

	local itemData = InventoryHelpers.GetItemData("Tools", p3)
	local v6 = Visuals.new({ "Teleport" }, LocalPlayer.Character.HumanoidRootPart)

	Visuals.Recolour(v6, Rarities.GetRarityData(itemData.rarity()).colour.Keypoints[1].Value)
	Visuals.Play(v6, nil, true)
	Sounds.Play(Sounds.new({ "PointScored" }, LocalPlayer.Character.HumanoidRootPart), nil, true)
	display(p3)
	flag = false
end)