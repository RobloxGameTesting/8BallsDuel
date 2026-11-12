local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("UserInputService")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
require(ReplicatedStorage.Libraries.Modules.Rarities)
require(ReplicatedStorage.Libraries.Modules.Display)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
game:GetService("RunService")
game:GetService("GuiService")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Colours)
require(ReplicatedStorage.Types.Types)
require(script.InventoryTypes)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local InventoryHelpers = require(script.InventoryHelpers)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local _ = Device:Get() == "Mobile"
local _ = Device:Get() == "Mobile"
local display = PlayerGui:WaitForChild("EffectUI"):WaitForChild("Display")
local Assets = ReplicatedStorage.Assets
local v = Maid.new()
local CurrentCamera = workspace.CurrentCamera

local Inventories = {}

local inventories = {}
local count = 0

function Inventories._getInventories(_)
	return inventories
end

function Inventories:_getInventoryIndexById(p)
	for k, inventory in inventories do
		if inventory.id == p then
			return k
		end
	end

	return nil
end

function Inventories.new(plr, parent, category, slotType)
	count += 1
	local userId = tostring(plr.UserId)
	local v2 = category:sub(1, 1):upper() .. category:sub(2)
	local folder = ReplicatedStorage.Assets.Skins:WaitForChild(v2)

	assert(folder, `Module folder not found for Inventory category: {v2}`)
	assert(folder:IsA("Folder"), `Module folder not found for Inventory category: {v2}`)

	local v3 = {
		id = count,
		plr = plr,
		userId = userId,
		replica = Profiles.GetPlayerReplica(userId),
		category = category,
		capitalCategory = v2,
		writeLibName = v2,
		modules = folder,
		parent = parent,
		callback = nil,
		displaying = nil,
		slots = Maid.new(),
		showDisplay = true,
		slotType = slotType,
		updatedEvent = Instance.new("BindableEvent")
	}

	Inventories.Update(v3)
	v3.replica:ListenToWrite("Inventory", function(p)
		if p ~= v3.category then
			return
		end

		task.spawn(function()
			Inventories.Update(v3)
		end)
	end)

	if v3.writeLibName then
		v3.replica:ListenToWrite("Equipped", function(p)
			if p ~= v3.category then
				return
			end

			task.spawn(function()
				Inventories.Update(v3)
			end)
		end)
	end

	return v3
end

function Inventories.fromList(list, parent, category, slotType)
	count += 1
	local capitalCategory = category:sub(1, 1):upper() .. category:sub(2)
	local folder = ReplicatedStorage.Assets.Skins:WaitForChild(capitalCategory)

	assert(folder, `Module folder not found for Inventory category: {capitalCategory}`)
	assert(folder:IsA("Folder"), `Module folder not found for Inventory category: {capitalCategory}`)

	local v2 = {
		id = count,
		list = list,
		category = category,
		capitalCategory = capitalCategory,
		modules = folder,
		parent = parent,
		callback = nil,
		displaying = nil,
		slots = Maid.new(),
		showDisplay = true,
		slotType = slotType,
		updatedEvent = Instance.new("BindableEvent")
	}

	Inventories.Update(v2)

	return v2
end

function Inventories:SetCallback(callback)
	self.callback = callback
end

function Inventories:Display(instance, displaying: string)
	if not self.showDisplay then
		return
	end

	self.displaying = displaying

	local _ = InventoryHelpers.SingleItemList(LocalPlayer, self.category)[displaying]
	v.destroyedConnection = instance.Destroying:Connect(function()
		Inventories.StopDisplay(self)
	end)
	v.mouseLeave = instance.MouseLeave:Connect(function()
		Inventories.StopDisplay(self, displaying)
	end)

	display.Visible = true
end

function Inventories.StopDisplay(p, p2: string?)
	if p and p.displaying ~= p2 then
		return
	end

	v:Destroy()
	display.Visible = false
end

function Inventories.Update(data)
	local function update(k, _, singleItem, _) -- 1 equivalent call inferred from this helper
		local slot = data.slots[k]

		if data.slotType == "Boosts" then
			slot.Background.Count.Text = "x" .. singleItem.amount
		end
	end

	local function remove(p)
		for k, _ in data.slots._tasks do
			if typeof(k) ~= "string" or p[k] then
				continue
			end

			data.slots[k] = nil
		end
	end

	local function add(k, p, p2, p3)
		local slot = InventoryHelpers.CreateSlot(p2, p3, data.parent, data.slotType)
		slot:FindFirstChild("Button")

		Button.Create(slot, function()
			if data.callback then
				data.callback(p)

				UserInterfaceHelper.Shine()
				Inventories.StopDisplay(data, k)
			end
		end)

		slot.MouseEnter:Connect(function() end)

		slot.MouseLeave:Connect(function()
			Button.Release(slot)

			Inventories.StopDisplay(data, k)
		end)

		data.slots[k] = slot
	end

	if data.list then
		if data.list then
			remove(data.list)

			for k, item in data.list do
				if data.slots[k] then
					continue
				end

				local module = nil

				if data.category == "misc" then
					local child = data.modules:FindFirstChild(item.writeLib)

					if child then
						module = require(child)
					end
				end

				add(k, nil, item, module)
			end
		end
	else
		local singleItemList = InventoryHelpers.SingleItemList(LocalPlayer, data.category)
		remove(singleItemList)

		for k, singleItem in singleItemList do
			local item = singleItem.item

			if data.slots[k] then
				local _itemData = itemData
				update(k, nil, singleItem) -- inferred equivalent call
			elseif typeof(item) == "string" then
				local child = data.modules:FindFirstChild(item)
				local v2

				if child then
					v2 = require(child)
				end

				add(k, item, singleItem, v2)
			end
		end
	end

	data.updatedEvent:Fire()
end

function Inventories.GetSlots(p)
	return p.slots._tasks
end

function Inventories:Category(category)
	self.category = category
	self.capitalCategory = category:sub(1, 1):upper() .. category:sub(2)
	Inventories.Update(self)
end

function Inventories.AddList(p, items)
	if not p.list then
		return
	end

	for k, item in items do
		p.list[k] = item
	end

	Inventories.Update(p)
end

function Inventories.RemoveList(p, items)
	if not p.list then
		return
	end

	for k, _ in items do
		p.list[k] = nil
	end

	Inventories.Update(p)
end

function Inventories:ClearList()
	self.list = {}

	Inventories.Update(self)
end

function Inventories.CanClick(p, interactable)
	for _, slot in p.slots do
		if typeof(slot) ~= "Instance" then
			continue
		end

		local button = slot:FindFirstChild("Button")

		if button then
			button.Interactable = interactable
		end
	end
end

function Inventories:Destroy()
	table.remove(inventories, Inventories:_getInventoryIndexById(self.id))

	self.slots:Destroy()
end

UserInterfaceHelper.FollowMouse(display)

Menu.Closed:Connect(function()
	Inventories.StopDisplay()
end)

return Inventories