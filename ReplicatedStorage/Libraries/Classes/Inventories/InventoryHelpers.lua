local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Types.Types)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local HttpService = game:GetService("HttpService")
local SharedConstants = require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryTypes)
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Modules.Level)
local Events = require(ReplicatedStorage.Libraries.Modules.Events)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
require(ReplicatedStorage.Libraries.Modules.Probability)
local StringHelper = require(ReplicatedStorage.Libraries.Helpers.StringHelper)
require(ReplicatedStorage.Types.DataTypes)

local Assets = ReplicatedStorage.Assets

local InventoryHelpers = {}

function InventoryHelpers.OwnsItem(p, p2, p3: string)
	local singleItemList = InventoryHelpers.SingleItemList(p, p2)
	local singleItem = singleItemList[p3]

	if not singleItem then
		for _, singleItem2 in singleItemList do
			if table.find(singleItem2.ids, p3) then
				return singleItem2
			end
		end
	end

	return singleItem
end

function InventoryHelpers.GetCategoryModules(childName)
	local modulesByName = {}

	if childName == "Roles" then
		for _, moduleScript in ReplicatedStorage.Libraries.GameSpecific.Roles.Modules:GetChildren(), nil, nil do
			local module = require(moduleScript)
			modulesByName[moduleScript.Name] = module
		end

		return modulesByName
	elseif childName == "Tools" then
		for _, moduleScript in ReplicatedStorage.Libraries.GameSpecific.Tools.Modules:GetChildren(), nil, nil do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local module = require(moduleScript)
			modulesByName[moduleScript.Name] = module
		end

		return modulesByName
	else
		local child = ReplicatedStorage.Assets.Skins:FindFirstChild(childName)
		assert(child, `Folder not found for InventoryHelpers key: {childName}`)

		for _, moduleScript in child:GetChildren(), nil, nil do
			local module = require(moduleScript)
			modulesByName[moduleScript.Name] = module
		end

		return modulesByName
	end
end

function InventoryHelpers.GetRarityList(p)
	local categoryModules = InventoryHelpers.GetCategoryModules(p)
	local chances = {}

	for k, categoryModule in categoryModules do
		chances[k] = categoryModule.chance
	end

	return chances
end

function InventoryHelpers.GetItemData(childName: string, childName2: string)
	local module

	if childName == "Roles" or childName == "Tools" then
		local child = ReplicatedStorage.Libraries.GameSpecific:FindFirstChild(childName)
		local modules = child and child:FindFirstChild("Modules")
		local child2 = modules and modules:FindFirstChild(childName2)

		if not child2 then
			return
		end

		module = require(child2)
	elseif childName == "Abilities" then
		local child = ReplicatedStorage.Libraries.GameSpecific.Attacks:FindFirstChild("Abilities")
		local modules = child and child:FindFirstChild("Modules")
		local child2 = modules and modules:FindFirstChild(childName2)

		if not child2 then
			return
		end

		module = require(child2)
	else
		local child = ReplicatedStorage.Assets.Skins:FindFirstChild(childName)
		local child2 = child and child:FindFirstChild(childName2)

		assert(child, `Category folder was not found for InventoryHelpers key: {childName}`)
		assert(child2, `Module script was not found for InventoryHelpers itemName: {childName2}`)

		module = require(child2)
	end

	assert(module, "Data not found for item in  " .. childName2 .. " category " .. childName)

	return module
end

function InventoryHelpers.HasItemModule(childName: string, childName2: string?)
	if typeof(childName2) ~= "string" or childName2 == "" then
		return false
	end

	local v

	if childName == "Roles" or childName == "Tools" then
		local child = ReplicatedStorage.Libraries.GameSpecific:FindFirstChild(childName)
		v = child and child:FindFirstChild("Modules")
	elseif childName == "Abilities" then
		local attacks = ReplicatedStorage.Libraries.GameSpecific:FindFirstChild("Attacks")
		local child = attacks and attacks:FindFirstChild("Abilities")
		v = child and child:FindFirstChild("Modules")
	else
		v = ReplicatedStorage.Assets.Skins:FindFirstChild(childName)
	end

	local moduleScript = v and v:FindFirstChild(childName2)

	return moduleScript ~= nil and moduleScript:IsA("ModuleScript")
end

function InventoryHelpers.GetItemColour(p: string, p2: string)
	local itemData = InventoryHelpers.GetItemData(p, p2)
	local rarity = itemData.rarity({}, itemData)

	return Rarities.GetRarityData(rarity).colour.Keypoints[1].Value
end

function InventoryHelpers.GetItemSound(p: string, p2: string)
	local itemData = InventoryHelpers.GetItemData(p, p2)
	local rarity = itemData.rarity({}, itemData)

	return Rarities.GetRarityData(rarity).sound
end

function InventoryHelpers.SingleItemList(p, p2)
	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId).Data.inventory[p2]

	if not v then
		return {}
	end

	local result = {}

	for k, amount in v do
		if typeof(amount) == "number" then
			result[k] = { item = k, ids = {}, amount = amount, metadata = {} }
		elseif amount.item then
			local capitalize = StringHelper.Capitalize(p2)

			if InventoryHelpers.HasItemModule(capitalize, amount.item) then
				local itemData = InventoryHelpers.GetItemData(capitalize, amount.item)
				local metadata = {}
				local v2

				if itemData.itemType == "Knife" or itemData.itemType == "Gun" then
					metadata.mutation = amount.mutation
					v2 = amount.mutation .. amount.item
				else
					v2 = amount.item
				end

				if not result[v2] then
					result[v2] = { item = amount.item, ids = {}, metadata = metadata }
				end

				table.insert(result[v2].ids, k)
			end
		end
	end

	return result
end

function InventoryHelpers.Reward(_, p, data)
	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
	local data2 = v.Data

	if not v then
		warn("Replica not found")
		return false
	end

	if data.writeLib == "Items" then
		v:Write("Inventory", "items", HttpService:GenerateGUID(), {
			item = data.itemName,
			mutation = data.mutation
		})
	elseif data.writeLib == "Boosts" then
		local itemName = data.itemName
		local v2 = itemName and data2.inventory.boosts[itemName] or 0
		local value = data.value

		v:Write("Inventory", "boosts", data.itemName, (v2 or 0) + value)
	elseif data.writeLib == "Pets" then
		assert(data.itemName, "data.itemName is nil")
		require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
		local guid = HttpService:GenerateGUID()
		InventoryHelpers.GetItemData("Pets", data.itemName)

		v:Write("Inventory", "pets", guid, data)
		return guid
	else
		if data.writeLib == "Gloves" then
			v:Write("Inventory", "gloves", HttpService:GenerateGUID(), { item = data.itemName })

			return true
		end

		if data.writeLib == "Roles" then
			v:Write("roleSlots", data2.selectedSlot, data.itemName)
		else
			if data.writeLib == "RoleSpins" then
				v:Write("RoleSpins", data.value)
				return true
			end

			if data.writeLib == "PremiumRoleSpins" then
				v:Write("PremiumRoleSpins", data.value)
				return true
			end

			if data.writeLib == "WeaponSpins" then
				v:Write("WeaponSpins", data.value)
				return true
			end

			if data.writeLib == "PremiumWeaponSpins" then
				v:Write("PremiumWeaponSpins", data.value)
				return true
			end

			if data.writeLib == "Currency1" then
				v:Write("Currency1", { mantissa = data.value, exponent = 0 })

				return true
			end

			if data.writeLib == "Currency2" then
				v:Write("Currency2", { mantissa = data.value, exponent = 0 })

				return true
			end

			if data.writeLib == "EventCurrency" then
				return Events:AddCurrency(p, tonumber(data.value) or 0) > 0
			end

			if data.writeLib == "SpinWheel" then
				v:Write("Spins", data.value)
				return true
			end

			if data.writeLib == "EventSpinTickets" then
				v:Write("EventSpinTickets", data.value)
				return true
			end

			if data.writeLib == "EventAbilitySpins" then
				v:Write("EventAbilitySpins", data.value)

				return true
			end

			if data.writeLib == "BoostCapacity" then
				v:Write("Boost", "BoostCapacity", data.value)
				return true
			end

			if data.writeLib == "BoostDamage" then
				v:Write("Boost", "BoostDamage", data.value)
				return true
			end

			if data.writeLib == "BoostPickaxe" then
				v:Write("Boost", "BoostPickaxe", data.value)
				return true
			end

			if data.writeLib == "BoostWalkspeed" then
				v:Write("Boost", "BoostWalkspeed", data.value)
				return true
			end

			if data.writeLib == "BoostLuck" then
				v:Write("Boost", "BoostLuck", data.value)

				return true
			end

			if data.writeLib == "CueStick" or data.writeLib == "PoolTable" or data.writeLib == "PoolEffect" then
				local v2 = {
					CueStick = "cueSticks",
					PoolTable = "poolTables",
					PoolEffect = "poolEffects"
				}

				local itemName = data.itemName

				if itemName then
					local PoolPlayerData = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolPlayerData)

					return PoolPlayerData.GrantSkin(p.UserId, v2[data.writeLib], itemName)
				end

				warn("A " .. data.writeLib .. " reward has no itemName")
				return false
			elseif data.writeLib == "InviteRewardProgress" then
				v:Write(data.writeLib, data.value)
				return true
			end
		end
	end

	return false
end

local v = { CueStick = "cueSticks", PoolTable = "poolTables", PoolEffect = "poolEffects" }

local function poolSkinName(writeLib: string, itemName)
	local success, poolSkins = pcall(require, ReplicatedStorage.Libraries.GameSpecific.Pool.PoolSkins)
	local v2

	if success and itemName then
		v2 = poolSkins.GetItem(v[writeLib], (tostring(itemName)))
	end

	if v2 and v2.name then
		return (tostring(v2.name))
	end

	return (tostring(itemName))
end

local function kindSuffix(value: string, value2: string) -- 3 equivalent calls inferred from this helper
	local v2 = string.lower(value)
	local v3 = string.lower(value2)

	if string.sub(v2, -#v3) == v3 then
		return ""
	end

	return " " .. value2
end

function InventoryHelpers.IsPoolSkinReward(p): boolean
	return typeof(p) == "table" and v[p.writeLib] ~= nil
end

local v2 = { CueStick = "cue", PoolTable = "table", PoolEffect = "VFX" }

function InventoryHelpers.GetOwnedNotification(_, p)
	local v3 = v2[p.writeLib] or "item"
	local v4 = poolSkinName(p.writeLib, p.itemName)
	return "TextNotification", {
		message = "You already own the " .. "<font color=\"rgb(200,200,215)\">" .. v4 .. "</font>" .. kindSuffix(v4, v3) -- inferred equivalent call
	}
end

function InventoryHelpers.GetRewardNotification(_, data)
	if data.writeLib == "Tools" then
		return "TextNotification", {
			message = "Got the " .. "<font color=\"rgb(0,255,30)\">" .. tostring(data.itemName) .. "</font> tool!"
		}
	end

	if data.writeLib == "RoleSpins" then
		return "TextNotification", {
			message = `<font color="rgb(255,255,255)">+{data.value} Role Spins!</font>`
		}
	end

	if data.writeLib == "PremiumRoleSpins" then
		return
			"TextNotification",
			{
				message = `<font color="rgb(255,255,255)">+{data.value} Premium Role Spins!</font>`
			}
	end

	if data.writeLib == "WeaponSpins" then
		return "TextNotification", {
			message = `<font color="rgb(255,255,255)">+{data.value} Weapon Spins!</font>`
		}
	end

	if data.writeLib == "PremiumWeaponSpins" then
		return
			"TextNotification",
			{
				message = `<font color="rgb(255,255,255)">+{data.value} Premium Weapon Spins!</font>`
			}
	end

	if data.writeLib == "Currency1" then
		return "TextNotification", {
			message = `<font color="rgb(255,230,0)">+{data.value} money!</font>`
		}
	end

	if data.writeLib == "Currency2" then
		return "TextNotification", {
			message = `<font color="rgb(120,215,255)">+{data.value} Gems!</font>`
		}
	end

	if data.writeLib == "EventCurrency" then
		local currencyInfo = Events:GetCurrencyInfo()
		local v3 = not (currencyInfo and currencyInfo.name) and "Event Gems" or currencyInfo.name

		return "TextNotification", {
			message = `<font color="rgb(220,150,255)">+{data.value} {v3}!</font>`
		}
	elseif data.writeLib == "CueStick" then
		return "TextNotification", {
			message = "Unlocked the " .. "<font color=\"rgb(255,230,0)\">" .. poolSkinName(data.writeLib, data.itemName) .. "</font>" .. kindSuffix( -- inferred equivalent call
				poolSkinName(data.writeLib, data.itemName),
				"cue"
			) .. "!"
		}
	elseif data.writeLib == "PoolTable" then
		return "TextNotification", {
			message = "Unlocked the " .. "<font color=\"rgb(120,220,140)\">" .. poolSkinName(data.writeLib, data.itemName) .. "</font>" .. kindSuffix( -- inferred equivalent call
				poolSkinName(data.writeLib, data.itemName),
				"table"
			) .. "!"
		}
	else
		if data.writeLib == "PoolEffect" then
			return "TextNotification", {
				message = "Unlocked the " .. "<font color=\"rgb(200,140,255)\">" .. poolSkinName(data.writeLib, data.itemName) .. "</font> VFX!"
			}
		end

		if data.writeLib == "EventSpinTickets" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(240, 0, 0)\">" .. tostring(data.value) .. "</font> Event Spin tickets"
			}
		end

		if data.writeLib == "EventAbilitySpins" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(255,230,0)\">" .. tostring(data.value) .. "</font> ability spin tickets"
			}
		end

		if data.writeLib == "BoostCapacity" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(0, 255, 0)\">" .. NumberHelper.FormatTimerMS(data.value) .. "</font> storage boost"
			}
		end

		if data.writeLib == "BoostDamage" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(0, 255, 0)\">" .. NumberHelper.FormatTimerMS(data.value) .. "</font> damage boost"
			}
		end

		if data.writeLib == "BoostPickaxe" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(0, 255, 0)\">" .. NumberHelper.FormatTimerMS(data.value) .. "</font> pickaxe boost"
			}
		end

		if data.writeLib == "BoostWalkspeed" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(0, 255, 0)\">" .. NumberHelper.FormatTimerMS(data.value) .. "</font> run boost"
			}
		end

		if data.writeLib == "BoostLuck" then
			return "TextNotification", {
				message = "Claimed " .. "<font color=\"rgb(0, 255, 0)\">" .. NumberHelper.FormatTimerMS(data.value) .. "</font> luck boost"
			}
		end

		if data.writeLib == "TierSkip" then
			return "TextNotification", { message = "Season pass tier skipped" }
		end

		if data.writeLib == "EventSpin" then
			return "TextNotification", {
				message = "<font color=\"rgb(240, 0, 0)\">You got the Event Spin!</font>"
			}
		end

		if data.writeLib == "SpinWheel" then
			return "TextNotification", {
				message = "You claimed " .. "<font color=\"rgb(252, 214, 0)\">" .. tostring(data.value) .. "</font> spin wheel tickets!"
			}
		end

		if data.writeLib == "InviteRewardProgress" then
			return "TextNotification", {
				message = "You received " .. "<font color=\"rgb(0, 255, 0)\">" .. tostring(data.value) .. "</font> friend invite points!"
			}
		end

		if data.writeLib == "Gloves" then
			return "TextNotification", {
				message = "Unlocked the " .. "<font color=\"rgb(255,230,0)\">" .. tostring(data.itemName) .. "</font> glove!"
			}
		end

		warn("No reward notification for: " .. data.writeLib)
		return "TextNotification", {
			message = "<font color=\"rgb(0, 255, 0)\">" .. "No reward notification for: " .. data.writeLib .. " Report to developer</font>"
		}
	end
end

function InventoryHelpers.GetNotifications(_, p: string)
	local localPlayer = Players.LocalPlayer
	local userId = tostring(localPlayer.UserId)
	local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data

	if p == "Level" then
		return data.level - data.levelRewardClaims
	end

	if p == "Daily" then
		if os.time() - data.dailyReward.lastReward >= SharedConstants.DAILY_TIME then
			return 1
		end

		return 0
	elseif p == "Friend" then
		local count = 0

		for _, v3 in SharedConstants.FRIEND_REWARDS do
			local requirement = v3.requirement

			if not (requirement <= data.inviteRewardProgress) or data.inviteRewardClaims[tostring(requirement)] then
				continue
			end

			count += 1
		end

		return count
	elseif p == "Event" then
		local betweenRewards, _ = Events:GetBetweenRewards(localPlayer, "GetBetweenHighValue")
		local ownsSeasonPass = Events:OwnsSeasonPass(localPlayer)
		local battlepassClaims = Events:GetBattlepassClaims(localPlayer)
		local count = 0

		for k, _ in Events:GetBattlepassRewards(), nil, nil do
			if not (tonumber(k) <= betweenRewards) then
				continue
			end

			local v3 = false
			local v4 = tostring(k)

			if battlepassClaims[v4] then
				v3 = battlepassClaims[v4].free and not ownsSeasonPass and true
					or battlepassClaims[v4].free and battlepassClaims[v4].season and ownsSeasonPass and true
					or false
			end

			if not v3 then
				count += 1
			end
		end

		return count
	else
		if p == "Codes" then
		end

		return 0
	end
end

local unit = (Vector3.new(0.35, 0.3, 1)).Unit

function InventoryHelpers:MountViewport(instance, cframe: CFrame?, data)
	if not (self and instance) then
		return nil
	end

	local modelViewport = Instance.new("ViewportFrame")
	modelViewport.Name = "ModelViewport"
	modelViewport.AnchorPoint = Vector2.new(0.5, 0.5)
	modelViewport.Position = UDim2.fromScale(0.5, 0.5)
	modelViewport.Size = UDim2.fromScale(1, 1)
	modelViewport.BackgroundTransparency = 1
	modelViewport.ZIndex = self.ZIndex
	modelViewport.Ambient = Color3.fromRGB(190, 190, 190)
	modelViewport.LightColor = Color3.fromRGB(255, 255, 255)
	modelViewport.LightDirection = Vector3.new(-0.4, -1, -0.6)
	local parent

	if self.Parent and self.Parent:IsA("GuiObject") then
		parent = self.Parent
	else
		parent = self
	end

	if data and data.Fill then
		modelViewport.Parent = parent

		local success, result = pcall(data.Fill, modelViewport, instance)

		if success then
			self.Image = ""

			return modelViewport
		end

		modelViewport.Parent = nil

		warn("[InventoryHelpers] viewport Fill failed, using the default framing: " .. tostring(result))
	end

	local clone = instance:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	clone:PivotTo(cframe or CFrame.identity)
	clone.Parent = modelViewport

	local boundingBox, v3 = clone:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40

	local padding = data and data.Padding or 1.08
	local unit2 = (data and data.Direction or unit).Unit
	local position = boundingBox.Position

	local cframe2 = CFrame.lookAt(position + unit2, position)
	local rightVector = cframe2.RightVector
	local upVector = cframe2.UpVector
	local lookVector = cframe2.LookVector
	local v4 = {}

	for _, v5 in { -0.5, 0.5 } do
		for _, v6 in { -0.5, 0.5 } do
			for _, v7 in { -0.5, 0.5 } do
				table.insert(v4, boundingBox:PointToWorldSpace((Vector3.new(v3.X * v5, v3.Y * v6, v3.Z * v7))))
			end
		end
	end

	local function fit()
		local absoluteSize = modelViewport.AbsoluteSize
		local v5 = not (absoluteSize.Y > 0) and 1 or math.max(absoluteSize.X, 1) / absoluteSize.Y
		local v6 = 0.36397023426620234 / padding
		local v7 = v6 * v5
		local maxValue = 0

		for _, v8 in v4 do
			local vector = v8 - position

			maxValue = math.max(
				maxValue,
				-vector:Dot(lookVector) + math.max(
					math.abs((vector:Dot(rightVector))) / v7,
					math.abs((vector:Dot(upVector))) / v6
				)
			)
		end

		camera.CFrame = CFrame.lookAt(position + unit2 * maxValue, position)
	end

	camera.Parent = modelViewport
	modelViewport.CurrentCamera = camera
	modelViewport.Parent = parent

	fit()
	modelViewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

	self.Image = ""

	return modelViewport
end

function InventoryHelpers.CreateSlot(p, data, parent, value)
	local v3 = typeof(data.rarity) == "function" and data.rarity(p, data) or data.rarity
	local v4 = typeof(data.labelTop) == "function" and data.labelTop(p, data) or data.labelTop
	local v5 = typeof(data.labelBottom) == "function" and data.labelBottom(p, data) or data.labelBottom
	local image = typeof(data.image) == "function" and data.image(p, data) or data.image
	local child = Assets.UI.Inventory:FindFirstChild("ItemButton" .. (value or "Generic"))
	assert(child, "Slot ItemButton" .. (value or "Generic") .. " not found in Assets.UI.Inventory")
	local clone = child:Clone()

	local v6 = Rarities.GetRarityData(v3)

	if not v6 then
		warn(string.format("[InventoryHelpers] unknown rarity %q; falling back to Normal", (tostring(v3))))

		v3 = "Normal"
		v6 = Rarities.GetRarityData(v3)
	end

	local v7 = tonumber(string.match(v3, "%d+"))
	local background = clone:FindFirstChild("Background", true)
	local labelTop = clone:FindFirstChild("LabelTop", true)

	local labelBottom = clone:FindFirstChild("LabelBottom", true)
	local icon = clone:FindFirstChild("Icon", true)
	local effect = clone:FindFirstChild("Effect", true)

	assert(background, `Background frame not found in the inventory slot {value}`)

	if v7 then
		clone.LayoutOrder = -v7
	else
		clone.LayoutOrder = -10
	end

	background.UIGradient.Color = v6.colour
	labelTop.Text = v4 or ""
	labelBottom.Text = v5 or ""
	icon.Image = image

	local color = typeof(data.imageTint) == "function" and data.imageTint(p, data) or data.imageTint

	if typeof(color) == "ColorSequence" and icon then
		local imageTint = Instance.new("UIGradient")
		imageTint.Name = "ImageTint"
		imageTint.Color = color
		imageTint.Rotation = 45
		imageTint.Parent = icon
	end

	local model = typeof(data.model) == "function" and data.model(p, data) or data.model

	if typeof(model) == "Instance" and model:IsA("Model") then
		local v8 = typeof(data.modelPivot) == "function" and data.modelPivot(p, data) or data.modelPivot
		local v9 = typeof(data.viewportOptions) == "function" and data.viewportOptions(p, data) or data.viewportOptions

		local mountViewport = InventoryHelpers.MountViewport

		if typeof(v8) ~= "CFrame" then
			v8 = nil
		end

		if typeof(v9) ~= "table" then
			v9 = nil
		end

		mountViewport(icon, model, v8, v9)
	end

	if v6.effect then
		for _, v8 in v6.effect do
			local effect2 = UserInterfaceHelper.Effect(v8)

			if v8 == "Rotation" or v8 == "RotationSlow" then
				effect2.new(background.UIGradient)
			elseif v8 == "BossSparkles" or v8 == "YellowSparkles" or v8 == "Burst" then
				effect2.new(effect)
			elseif v8 == "Startburst" then
				effect2.new(effect)
			elseif v8 == "Shine" then
				local v9 = effect2.new(clone)
				effect2.SetImage(v9, "rbxassetid://17291150156")
			end
		end
	end

	clone.Parent = parent

	return clone
end

return InventoryHelpers