local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Classes.CameraShaker)
local WeaponHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Mouses = require(ReplicatedStorage.Libraries.Classes.Mouses)
local WeaponConstants = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponConstants)
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local WeaponAttacks = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponAttacks)
local Knockback = require(ReplicatedStorage.Libraries.Modules.Knockback)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local MobileHelper = require(ReplicatedStorage.Libraries.Helpers.MobileHelper)

local CurrentCamera = workspace.CurrentCamera
local isServer = RunService:IsServer()
local WeaponFunctionHelpers = {}

function WeaponFunctionHelpers.onShootRequest(data)
	local module = WeaponHelpers.GetModule(data)
	local functionsModule = WeaponHelpers.GetFunctionsModule(data)

	if isServer then
		local v = module.spray[data.shootIndex]
		local pattern = v.pattern

		if not (tick() - data.verifiedShoot > v.cooldown * WeaponConstants.SERVER_VALIDATION_PERCENT) then
			warn("Time hasn't elapsed. Bullet not verified")
			return
		end

		local Verification = require(ServerScriptService.Libraries.Modules.Verification)

		for _, v2 in pattern do
			local v3 = v2.attackType .. v2.attackId
			Verification.Add(data.ownerId, v3)
		end

		Tools.SetValue(data, "verifiedShoot", tick(), {}, true)
		Tools.SetCooldown(data)
	else
		if not data.isOwner then
			functionsModule.onShoot(data)

			return
		end

		if not data.equipped then
			warn("Not equipped")
			return
		end

		local pattern = module.spray[data.shootIndex].pattern

		Tools.SetValue(data, "ammo", data.ammo - 1, { data.owner }, false)

		for _, v in pattern do
			if v.attackType == "Bullet" then
				local v2 = module.spray[data.shootIndex]
				local viewmodelOrigin = data.isFirstPerson and v2.viewmodelOrigin or v2.origin
				local spread = v2.spread
				local spreadY = v2.spreadY
				local character = data.owner.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local viewmodel = data.isFirstPerson and data.viewmodel or data.tool
				local position = ModelHelper.GetChildrenByParentString(viewmodel, viewmodelOrigin).Position
				local project = Mouses.Project(data.mouse, "Blacklist")
				local position2 = project and project.Position or data.owner:GetMouse().Hit.Position
				local number = Random.new():NextNumber(spread.min, spread.max)
				local v3 = spreadY and Random.new():NextNumber(spreadY.min, spreadY.max) or 0
				local lookVector = nil

				if v.flat then
					lookVector = (CFrame.new(position, position + humanoidRootPart.CFrame.LookVector) * CFrame.Angles(math.rad(v3), math.rad(v.angle + number), 0)).LookVector
				elseif Device:Get() == "Mobile" or Device:Get() == "Console" or UserInputService.GamepadEnabled then
					local cframe = workspace.CurrentCamera.CFrame
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = { data.owner.Character }
					local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * 200, raycastParams)
					local position3 = raycastResult and raycastResult.Position or position + cframe.LookVector

					lookVector = CFrame.new(position, position3).LookVector
				elseif Device:Get() == "Desktop" then
					lookVector = (CFrame.lookAt(position, position2, Vector3.new(0, 1, 0)) * CFrame.Angles(math.rad(v3), math.rad(v.angle + number), 0)).LookVector
				end

				WeaponAttacks.CreateBullet(position, lookVector, data.ownerId, v.attackId, module.id)
			elseif v.attackType == "Swing" then
				WeaponAttacks.CreateSwing(data, v, module)
			elseif v.attackType == "Area" then
				WeaponAttacks.CreateArea(data, v, module)
			elseif v.attackType == "Physics" then
				WeaponAttacks.CreatePhysics(data, v, module)
			elseif v.attackType == "Ability" then
				WeaponAttacks.CreateAbility(data, v, module)
			end
		end

		local recoil = module.spray[data.shootIndex].recoil

		if recoil then
			local distance = recoil.distance

			local character = data.owner.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				local speed = recoil.speed
				local v = -humanoidRootPart.CFrame.LookVector

				if v.Y < 0 then
					v -= Vector3.new(0, v.Y, 0)
				end

				local function origin()
					return humanoidRootPart.CFrame
				end

				Knockback:Recoil(data.owner, origin, distance, speed, v, {})
			end
		end

		functionsModule.onShoot(data)

		local v = data.shootIndex + 1

		local v2 = #module.spray < v and 1 or v

		Tools.SetValue(data, "shootIndex", v2, { data.owner }, false)
		Tools.SetCooldown(data)
	end
end

function WeaponFunctionHelpers.onEquip(p)
	if p.isOwner and Device:Get() == "Mobile" then
		local lastTime = nil

		local shoot = MobileHelper:WaitForButton("shoot")

		p.maid.equipMaid.autoShootConnection = RunService.Heartbeat:Connect(function()
			local cframe = CurrentCamera.CFrame
			local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * 200, RaycastParams.new())
			local instance = raycastResult and raycastResult.Instance

			if instance then
				local enemyModels = Enemies._getEnemyModels()
				local flag = false

				for _, ancestor in enemyModels do
					if instance:IsDescendantOf(ancestor) then
						flag = true
					end
				end

				if flag then
					lastTime = tick()
					Tools.Activate(p)
				elseif not shoot.pressed and lastTime and tick() - lastTime >= 0 then
					Tools.Deactivate(p)
				end
			end
		end)
	end
end

return WeaponFunctionHelpers