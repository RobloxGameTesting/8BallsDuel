local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)
local WeaponEvents = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local CameraShaker = require(ReplicatedStorage.Libraries.Classes.CameraShaker)
local WeaponHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Classes.Mouses)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponConstants)
game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponAttacks)
require(ReplicatedStorage.Libraries.Modules.Knockback)
local WeaponFunctionHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponFunctionHelpers)
local ToolFunctionHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolFunctionHelpers)

local Functions = {}

function Functions.onShoot(data)
	require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)

	local v = WeaponHelpers.GetModule(data).spray[data.shootIndex]
	local tool = data.tool

	if not v.extraData then
		return
	end

	local arm = v.extraData.arm
	local spotLight = tool:FindFirstChild(arm .. "RightMuzzle")
		and tool:FindFirstChild(arm .. "RightMuzzle"):FindFirstChildWhichIsA("SpotLight")
	local particleEmitter = tool:FindFirstChild(arm):FindFirstChild("Bullets"):FindFirstChildWhichIsA("ParticleEmitter")

	Visuals.Play(data.visuals["shoot" .. arm], nil, false)

	if particleEmitter then
		particleEmitter:Emit(1)
	end

	if spotLight then
		spotLight.Brightness = Random.new():NextNumber(1, 4)
		spotLight.Range = Random.new():NextNumber(5, 25)
	end
end

function Functions.onShootRequest(p)
	local _ = WeaponHelpers.GetModule(p).spray[p.shootIndex]

	WeaponEvents.WeaponAttackEvent:Fire(p.id)

	WeaponFunctionHelpers.onShootRequest(p)
end

function Functions.onReload(data)
	if data.isOwner then
		Animations.Play(data.animations, {
			{ animation = "reload", speed = 1.5, priority = Enum.AnimationPriority.Action },
			{ animation = "idle", looped = true, priority = Enum.AnimationPriority.Idle }
		})

		Animations.Play(data.viewmodelAnimations, {
			{ animation = "reload", speed = 1.5, priority = Enum.AnimationPriority.Action },
			{ animation = "idle", looped = true, priority = Enum.AnimationPriority.Idle }
		})
	end
end

function Functions.onReloadComplete(_) end

function Functions.onFire(data)
	Sounds.Play(data.sounds.shooting, "Manual", false, 1)

	if data.isOwner then
		data.cameraShaker:ShakeSustain(CameraShaker.Presets.Minigun)
		data.cameraShaker:Start()
	end
end

function Functions.onStopFire(data)
	local tool = data.tool
	local spotLight = tool:FindFirstChild("RightMuzzle"):FindFirstChildWhichIsA("SpotLight")
	local spotLight2 = tool:FindFirstChild("LeftMuzzle"):FindFirstChildWhichIsA("SpotLight")

	if spotLight then
		spotLight.Brightness = 0
	end

	if spotLight2 then
		spotLight2.Brightness = 0
	end

	Sounds.Stop(data.sounds.shooting, 0.1)

	if data.isOwner then
		data.cameraShaker:StopSustained()
	end
end

function Functions.onEquip(data)
	if data.isOwner then
		Animations.Play(data.animations, {
			{ animation = "idle", looped = true, priority = Enum.AnimationPriority.Idle }
		})

		Animations.Play(data.viewmodelAnimations, {
			{ animation = "equip" },
			{ animation = "idle", looped = true, priority = Enum.AnimationPriority.Idle }
		})
	end

	ToolFunctionHelpers.Equip(data)
	ToolFunctionHelpers.DisplayMastery(data)
	WeaponFunctionHelpers.onEquip(data)
end

function Functions.onUnequip(data)
	if data.isOwner then
		Tools.Firing(data, false)
		Animations.Stop(data.animations)
		data.cameraShaker:Stop()
	end

	ToolFunctionHelpers.Unequip(data)
	ToolFunctionHelpers.HideMastery(data)
end

function Functions.onActivated(data)
	if data.isOwner then
		Animations.Play(data.animations, {
			{ animation = "press" },
			{ animation = "shoot", looped = true }
		})

		Animations.Play(data.viewmodelAnimations, {
			{ animation = "shoot", looped = true, speed = 3 }
		})

		Tools.Firing(data, true)
	end
end

function Functions.onDeactivated(data)
	if data.isOwner then
		Tools.Firing(data, false)
		Animations.Play(data.viewmodelAnimations, {
			{ animation = "idle", looped = true, priority = Enum.AnimationPriority.Idle }
		})

		Animations.Play(data.animations, {
			{ animation = "idle", looped = true, priority = Enum.AnimationPriority.Idle }
		})
	end
end

return Functions