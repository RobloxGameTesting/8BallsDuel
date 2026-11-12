local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
game:GetService("TweenService")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Mouselock)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
game:GetService("StarterPlayer")
local CameraHelper = require(ReplicatedStorage.Libraries.Helpers.CameraHelper)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = workspace.CurrentCamera
local RolesUI = PlayerGui:WaitForChild("RolesUI")
local Assets = ReplicatedStorage.Assets
local Equipped = Assets.InterfaceAssets.Roles.Equipped
local Label = Assets.InterfaceAssets.Roles.Label
local Lock = Assets.InterfaceAssets.Roles.Lock
local MainPanel = RolesUI.MainPanel
local RightPanel = RolesUI.RightPanel
local LeftPanel = RolesUI.LeftPanel
local clones = Maid.new()
local v2 = Maid.new()
Maid.new()
local v3 = { "RoleSpin" }

local v4 = nil

UserInterfaceHelper:FitScrollingFrame(LeftPanel.Content, "Y", UDim2.fromOffset(0, 5))

local function displayOdds(p)
	RightPanel.Drops.Roles.Visible = false
	v4 = nil

	for _, child in RightPanel.Drops:GetChildren(), nil, nil do
		if not child:FindFirstChild("Button") then
			continue
		end

		local name = child.Name

		local v5 = Rarities.GetRarityData(name).percent[p]

		if v5 == 0 then
			child.Visible = false
		else
			child.Visible = true
			child.Content.Label.Text = `{string.upper(name)} [ {v5}% ]`
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
local flag = false

for _, child in RightPanel.Drops:GetChildren(), nil, nil do
	if not child:FindFirstChild("Button") then
		continue
	end

	local name = child.Name

	Button.Create(child, function()
		clones:Destroy()

		if v4 == name then
			v4 = nil
			RightPanel.Drops.Roles.Visible = false
		else
			local count = 0

			for k, v5 in InventoryHelpers.GetCategoryModules("Roles"), nil, nil do
				if v5.rarity ~= name then
					continue
				end

				count += 1
				local clone = Label:Clone()
				clone.Label.Text = `[ {v5.id} ]`
				clone.Parent = RightPanel.Drops.Roles
				clones[k] = clone
			end

			RightPanel.Drops.Roles.UIAspectRatioConstraint.AspectRatio = 8 / count
			RightPanel.Drops.Roles.Visible = true
			RightPanel.Drops.Roles.LayoutOrder = RightPanel.Drops[name].LayoutOrder + 1
			v4 = name
		end
	end)
end

local function displayRole(p) -- 3 equivalent calls inferred from this helper
	local itemData = InventoryHelpers.GetItemData("Roles", p)
	local rarity = itemData.rarity

	MainPanel.Role.Text = `[ {p} ]`
	MainPanel.Role.UIGradient.Color = Rarities.GetRarityData(rarity).colour
	MainPanel.Description.Text = itemData.description
end

local function updateRoles()
	if flag then
		return
	end

	for _, child in LeftPanel.Content:GetChildren(), nil, nil do
		if not string.find(child.Name, "Slot") then
			continue
		end

		child.Content.Backing.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		child.Content.Label.Text = child.Name
	end

	for k, roleSlot in data.roleSlots do
		local itemData = InventoryHelpers.GetItemData("Roles", roleSlot.role)
		local rarity = itemData.rarity
		local id = itemData.id

		local parent = LeftPanel.Content["Slot" .. k]
		parent.Content.Backing.UIGradient.Color = Rarities.GetRarityData(rarity).colour
		parent.Content.Label.Text = `[ {id} ]`

		if k == data.selectedSlot then
			Equipped.Parent = parent
			displayRole(id) -- inferred equivalent call
		end

		if roleSlot.locked then
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

	RemoteSignals.FireServer("Roles", "RoleLock")
end)

for _, child in LeftPanel.Content:GetChildren(), nil, nil do
	if not child:FindFirstChild("Button") then
		continue
	end

	local v5 = tonumber(string.match(child.Name, "%d+"))

	if v5 then
		Button.Create(child, function()
			if flag then
				return
			end

			RemoteSignals.FireServer("Roles", "RoleEquip", v5)
		end)
	end
end

updateRoles()
v:ListenToWrite("RoleLock", updateRoles)
v:ListenToWrite("RoleEquip", updateRoles)
v:ListenToWrite("RoleChange", updateRoles)
v:ListenToWrite("RoleAdd", updateRoles)

local function updateSpins()
	if data.premiumRoleSpins <= 0 then
		MainPanel.PremiumSpin.Content.Count.Text = `{1000} coins`
	else
		MainPanel.PremiumSpin.Content.Count.Text = `{data.premiumRoleSpins}x`
	end

	if data.roleSpins <= 0 then
		MainPanel.NormalSpin.Content.Count.Text = `{100} coins`
	else
		MainPanel.NormalSpin.Content.Count.Text = `{data.roleSpins}x`
	end
end

updateSpins()
v:ListenToWrite("RoleSpins", updateSpins)
v:ListenToWrite("PremiumRoleSpins", updateSpins)

Button.Create(MainPanel.NormalSpin.Buy, function()
	Menu.Open("RoleSpins")
end)

Button.Create(MainPanel.PremiumSpin.Buy, function()
	Menu.Open("PremiumRoleSpins")
end)

Button.Create(MainPanel.PremiumSpin, function()
	if flag then
		return
	end

	RemoteSignals.FireServer("Roles", "RoleSpin", "Premium")
end)

Button.Create(MainPanel.NormalSpin, function()
	if flag then
		return
	end

	RemoteSignals.FireServer("Roles", "RoleSpin", "Normal")
end)

Menu.Opened:Connect(function(p)
	if p == "Roles" then
		local character = LocalPlayer.Character
		local nameUI = (character and character:FindFirstChild("HumanoidRootPart")):WaitForChild("NameUI")

		if character then
			character:FindFirstChildWhichIsA("Humanoid")
		end

		nameUI.PlayerToHideFrom = LocalPlayer

		CameraHelper.SetScriptableSubject(LocalPlayer, workspace.Lobby.Pads.Roles.Camera, false)
		UserInterfaceHelper.EnableBillboardUIs(false)
	end
end)

Menu.Closed:Connect(function(p)
	if p == "Roles" then
		local character = LocalPlayer.Character
		local nameUI = (character and character:FindFirstChild("HumanoidRootPart")):WaitForChild("NameUI")

		nameUI.PlayerToHideFrom = nil

		v2:Destroy()
		CameraHelper:Reset()
		UserInterfaceHelper.EnableBillboardUIs(true)
		CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end)

RemoteSignals.OnClientEvent("Roles", function(p, _, p2)
	if not table.find(v3, p) then
		return
	end

	flag = true

	local categoryModules = InventoryHelpers.GetCategoryModules("Roles")
	local keysToArray = TableHelper.KeysToArray(categoryModules)

	for _ = 1, 30 do
		displayRole(keysToArray[Random.new():NextInteger(1, #keysToArray)]) -- inferred equivalent call

		Sounds.Play(Sounds.new({ "Freebie" }, nil), nil, true)
		task.wait(0.05)
	end

	local itemData = InventoryHelpers.GetItemData("Roles", p2)
	local v5 = Visuals.new({ "Teleport" }, LocalPlayer.Character.HumanoidRootPart)

	Visuals.Recolour(v5, Rarities.GetRarityData(itemData.rarity).colour.Keypoints[1].Value)
	Visuals.Play(v5, nil, true)
	Sounds.Play(Sounds.new({ "PointScored" }, nil), nil, true)
	displayRole(p2) -- inferred equivalent call
	flag = false
end)