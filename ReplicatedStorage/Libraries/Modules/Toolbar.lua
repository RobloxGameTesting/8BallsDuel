local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
game:GetService("TweenService")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
require(ReplicatedStorage.Libraries.Modules.Rarities)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local WeaponEvents = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Modules.Scheduler)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
local HealthHandlerEvents = require(ReplicatedStorage.Libraries.Modules.HealthHandler.HealthHandlerEvents)
local WeaponHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
local PlaceHelper = require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local toolbar = PlayerGui:WaitForChild("EffectUI"):WaitForChild("Toolbar")
local slots = toolbar:WaitForChild("Slots")
local status = toolbar:WaitForChild("Status")
toolbar:WaitForChild("Keybinds")
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local v = { Primary = 1, Secondary = 2, Melee = 3, Utility = 4 }

local v2 = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
	[Enum.KeyCode.Zero] = 0
}

local _ = {
	[1] = Enum.KeyCode.One,
	[2] = Enum.KeyCode.Two,
	[3] = Enum.KeyCode.Three,
	[4] = Enum.KeyCode.Four,
	[5] = Enum.KeyCode.Five,
	[6] = Enum.KeyCode.Six,
	[7] = Enum.KeyCode.Seven,
	[8] = Enum.KeyCode.Eight,
	[9] = Enum.KeyCode.Nine,
	[0] = Enum.KeyCode.Zero
}

local v3 = Maid.new()

local v4 = {}
local v5 = false
local v6 = nil
local v7 = {}

local Toolbar = {}

local function _getToolbarIndex(p, p2: number)
	return v[p.toolType] or p2
end

function Toolbar.Init()
	if PlaceHelper.GetPlaceType() == "Game" then
		Toolbar.SetCanUse(true)

		UserInterfaceHelper:CoreGuiEnable({ [Enum.CoreGuiType.Backpack] = false })

		local function keybinds()
			if Device:Get() ~= "Console" then
				if UserInputService.GamepadEnabled then
					return
				end

				if Device:Get() == "Desktop" then
					v3.keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if gameProcessed or not v5 then
							return
						end

						local v8 = v2[input.KeyCode]

						if not v8 then
							return
						end

						local v9 = v7[v8]

						if not v9 then
							return
						end

						local weaponById = Tools._getWeaponById(v9)

						if not weaponById or not weaponById.isOwner or HealthHandler.IsDowned(userId) then
							return
						end

						Tools.Toggle(weaponById)
					end)
				elseif Device:Get() == "Mobile" then
					v3.keybindConnection = nil
				end
			end
		end

		keybinds()
		Device.Changed:Connect(keybinds)
		HealthHandlerEvents.Downed.Event:Connect(function(p, p2)
			if not (p == userId and p2) then
				return
			end

			local weaponsByOwnerId = Tools._getWeaponsByOwnerId(p)

			for _, weapon in weaponsByOwnerId do
				if weapon.equipped then
					Tools.Toggle(weapon)
				end
			end
		end)

		WeaponEvents.WeaponNew.Event:Connect(function(p)
			local weaponById = Tools._getWeaponById(p)

			if not (weaponById and weaponById.isOwner) then
				return
			end

			Toolbar.Add(p)
		end)

		WeaponEvents.WeaponDestroyed.Event:Connect(function(p)
			local weaponById = Tools._getWeaponById(p)

			if not (weaponById and weaponById.isOwner) then
				return
			end

			Toolbar.Remove(p)
		end)

		WeaponEvents.WeaponEquipped.Event:Connect(function(p)
			local weaponById = Tools._getWeaponById(p)

			if not weaponById then
				return
			end

			if weaponById.isOwner then
				local slot = v3[weaponById.id].slot
				Toolbar.EquipSlot(slot)
				Toolbar.UpdateStatus(p)
				v3.updateStatusConnection = WeaponEvents.WeaponAmmoEvent.Event:Connect(Toolbar.UpdateStatus)
			end
		end)

		WeaponEvents.WeaponUnequipped.Event:Connect(function(p)
			local weaponById = Tools._getWeaponById(p)

			if not weaponById then
				return
			end

			if weaponById.isOwner then
				Toolbar.UnequipSlot()
				status.Visible = false
				v3.updateStatusConnection = nil
			end
		end)
	else
		warn("Place type doesn't allow the toolbar")
		Toolbar.SetCanUse(false)
	end
end

function Toolbar.EquipSlot(instance)
	Toolbar.UnequipSlot()
	v6 = instance
	local content = instance:FindFirstChild("Content")

	content.Background.UIStroke.Enabled = true
end

function Toolbar.UnequipSlot()
	local content = v6 and v6:FindFirstChild("Content")

	if v6 and content then
		content.Background.UIStroke.Enabled = false
	end

	v6 = nil
end

function Toolbar.UpdateStatus(p)
	local weaponById = Tools._getWeaponById(p)

	if not (weaponById and weaponById.equipped and weaponById.isOwner) then
		return
	end

	local module = WeaponHelpers.GetModule(weaponById)
	local v8 = status
	local weapon = v8:WaitForChild("Weapon")
	local ammo = v8:WaitForChild("Ammo")

	weapon.Text = module.id

	if weaponById.maxAmmo == 1e999 then
		ammo.Text = ""
		return
	end

	local v9 = weaponById.totalAmmo == 0 and "<font color=\"#FF0000\">" or "<font color=\"#FFFFFF\">"
	ammo.Text = `<b>{weaponById.ammo}</b><font size="8">{v9}/{weaponById.totalAmmo}</font></font>`
end

function Toolbar.Add(p)
	local v8 = Maid.new()
	local weaponById = Tools._getWeaponById(p)
	local module = WeaponHelpers.GetModule({ weaponType = weaponById.weaponType })

	local slot = InventoryHelpers.CreateSlot(nil, module, slots, "v5")
	slot.Name = module.toolType
	slot.Content.Background.UIGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	local clone = ReplicatedStorage.Assets.UI.Inventory.SlotTimer:Clone()
	clone.Visible = false
	clone.Parent = slot.Content
	v8.slot = slot
	v8.reloadBar = clone
	v8.reloadProgressToolbarConnection = WeaponEvents.ReloadProgress.Event:Connect(function(p2: string, p3: number)
		if p2 ~= weaponById.id then
			return
		end

		if p3 == 1 then
			clone.Visible = false
			return
		end

		clone.Visible = true
		clone.Bar.Percent.Size = UDim2.fromScale(p3, 1)
		clone.Bar.Percent.Display.Size = UDim2.fromScale(1 / p3, 1)
	end)

	Button.Create(slot, function()
		Tools.Toggle(weaponById)
	end)

	v3[weaponById.id] = v8
	v4[weaponById.id] = weaponById

	Toolbar.Sort()

	bindableEvent:Fire()
end

function Toolbar.Remove(p: string)
	v3[p] = nil
	v4[p] = nil

	Toolbar.Sort()
	bindableEvent2:Fire()
end

function Toolbar.Sort()
	table.clear(v7)
	local v8 = 5

	for k, task in v3._tasks do
		local weaponById = Tools._getWeaponById(k)

		if not weaponById then
			continue
		end

		local layoutOrder = v[WeaponHelpers.GetModule({ weaponType = weaponById.weaponType }).toolType]
		local v9

		if layoutOrder then
			v9 = v8
		else
			v9 = v8 + 1
			layoutOrder = v8
		end

		v7[layoutOrder] = k

		task.slot.LayoutOrder = layoutOrder

		if Device:Get() == "Mobile" or Device:Get() == "Console" then
			task.slot.Content.Slot.Text = ""
		else
			task.slot.Content.Slot.Text = tostring(layoutOrder == 10 and 0 or layoutOrder)
		end

		v8 = v9
	end
end

function Toolbar.SetCanUse(visible)
	toolbar.Visible = visible
	v5 = true
end

function Toolbar:Get()
	return slots:FindFirstChild(self)
end

return Toolbar