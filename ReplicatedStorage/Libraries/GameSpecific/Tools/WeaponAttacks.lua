local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Mouses = require(ReplicatedStorage.Libraries.Classes.Mouses)
local TimeSync = require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.Helpers.OptimizationHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)
local Bullets = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Swings.SwingTypes)
local Swings = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Swings)
local Areas = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Areas)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Areas.AreaTypes)
local Throwables = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables.ThrowableTypes)
local Abilities = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities.AbilityTypes)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
local WeaponAttacks = {}

function WeaponAttacks.CreateBullet(origin: Vector3, lookVector: Vector3, ownerId: string?, bulletType: string, weaponType: string)
	local v = {
		id = tostring(Random.new():NextInteger(1, 1000000)),
		weaponType = weaponType,
		bulletType = bulletType,
		ownerId = ownerId,
		lookVectorHistory = {
			{ lookVector = lookVector, time = TimeSync.time() }
		},
		hitDebounce = {},
		origin = origin
	}

	if ownerId == nil then
		Bullets.newServer(v)
	else
		Bullets.newClient(v)
	end
end

function WeaponAttacks.CreateSwing(data, p, p2)
	local _ = p2.spray[data.shootIndex]

	local v = {
		id = tostring(Random.new():NextInteger(1, 1000000)),
		loadId = "",
		maid = nil,
		masteryType = p2.masteryType,
		swingType = p.attackId,
		owner = data.owner,
		ownerId = tostring(data.owner.UserId),
		hitDebounce = {},
		timeNeeded = 0,
		isOwner = true,
		enemyIdsHit = {},
		raycastHitbox = data.isFirstPerson and data.viewmodelRaycastHitbox or data.raycastHitbox
	}

	Swings.newClient(v)
end

function WeaponAttacks.CreateArea(data, p, p2)
	local v = p2.spray[data.shootIndex]
	local viewmodelOrigin = data.isFirstPerson and v.viewmodelOrigin or v.origin
	local viewmodel = data.isFirstPerson and data.viewmodel or data.tool

	for _, childName in viewmodelOrigin do
		viewmodel = viewmodel:FindFirstChild(childName)
	end

	local v2 = {
		id = tostring(Random.new():NextInteger(1, 1000000)),
		loadId = "",
		maid = nil,
		masteryType = p2.masteryType,
		areaType = p.attackId,
		owner = data.owner,
		ownerId = tostring(data.owner.UserId),
		hitDebounce = {},
		timeNeeded = 0,
		hitList = {},
		region = viewmodel,
		isOwner = true,
		enemyIdsHit = {},
		raycastHitbox = data.raycastHitbox
	}

	Areas.newClient(v2)
end

function WeaponAttacks.CreatePhysics(data, p, p2)
	local v = p2.spray[data.shootIndex]
	local viewmodelOrigin = data.isFirstPerson and v.viewmodelOrigin or v.origin
	local viewmodel = data.isFirstPerson and data.viewmodel or data.tool
	local spread = v.spread
	local spreadY = v.spreadY
	local _recoil = v.recoil
	local character = data.owner.Character

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	for _, childName in viewmodelOrigin do
		viewmodel = viewmodel:FindFirstChild(childName)
	end

	local project = Mouses.Project(data.mouse, "Blacklist")
	local position = project and project.Position or data.owner:GetMouse().Hit.Position
	Random.new():NextNumber(spread.min, spread.max)
	local _ = spreadY and Random.new():NextNumber(spreadY.min, spreadY.max)
	local lookVector = nil
	local speed = nil

	if viewmodel ~= data.tool then
		if Device:Get() == "Mobile" or Device:Get() == "Console" or UserInputService.GamepadEnabled then
			local cframe = workspace.CurrentCamera.CFrame
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { data.owner.Character, workspace.Contents }
			local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * 200, raycastParams)
			local position2 = raycastResult and raycastResult.Position or data.owner:GetMouse().Hit.Position

			lookVector = CFrame.lookAt(viewmodel.Position, position2, Vector3.new(0, 1, 0)).LookVector
			speed = math.clamp((viewmodel.Position - position2).Magnitude / 30, 0, 1)
		elseif Device:Get() == "Desktop" then
			lookVector = CFrame.lookAt(viewmodel.Position, position, Vector3.new(0, 1, 0)).LookVector
			speed = math.clamp((viewmodel.Position - position).Magnitude / 30, 0, 1)
		end
	end

	local v2 = {
		id = tostring(Random.new():NextInteger(1, 1000000)),
		loadId = "",
		weaponType = data.weaponType,
		maid = nil,
		position = viewmodel.Position,
		throwableType = p.attackId,
		owner = data.owner,
		ownerId = tostring(data.owner.UserId),
		headshotMultiplier = p2.headshotMultiplier,
		speed = speed,
		origin = viewmodel.Position,
		lookVector = lookVector,
		isOwner = true
	}

	local client = Throwables.newClient(v2)
	Mouses.AddList(data.mouse, "Blacklist", client.maid.object)
end

function WeaponAttacks.CreateAbility(data, p, p2)
	local v = p2.spray[data.shootIndex]
	local viewmodelOrigin = data.isFirstPerson and v.viewmodelOrigin or v.origin
	local viewmodel = data.isFirstPerson and data.viewmodel or data.tool

	for _, childName in viewmodelOrigin do
		viewmodel = viewmodel:FindFirstChild(childName)
	end

	local v2 = {
		id = tostring(Random.new():NextInteger(1, 1000000)),
		loadId = "",
		maid = nil,
		masteryType = p2.masteryType,
		abilityType = p.attackId,
		owner = data.owner,
		ownerId = tostring(data.owner.UserId),
		origin = viewmodel.Position,
		isOwner = true,
		isEnemy = false
	}

	Abilities.newClient(v2)
end

return WeaponAttacks