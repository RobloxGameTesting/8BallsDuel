local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.Probability)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Scheduler)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Classes.Mouses)
require(ReplicatedStorage.Libraries.Classes.CameraShaker)
require(ReplicatedStorage.Libraries.Modules.Device)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
game:GetService("UserInputService")
game:GetService("TweenService")
require(script.BulletTypes)
local BulletEvents = require(script.BulletEvents)
local BulletConstants = require(script.BulletConstants)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local CollectionService = game:GetService("CollectionService")
local TimeSync = require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Helpers.OptimizationHelper)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Modules = script.Modules
local modules = ReplicatedStorage.Libraries.GameSpecific.Tools.Modules

local Bullets = {}

local bullets = {}

local function _generateBlacklist(_)
	local blacklist = {}

	table.insert(blacklist, workspace.Contents.Ragdolls)
	table.insert(blacklist, workspace.Contents.Bullets)
	table.insert(blacklist, workspace.CurrentCamera)

	for _, v in Players:GetPlayers(), nil, nil do
		local character = v.Character

		if character then
			table.insert(blacklist, character)
		end
	end

	return blacklist
end

local function _generateEnemyBlacklist(_)
	local enemyModels = Enemies._getEnemyModels()

	table.insert(enemyModels, workspace.Contents.Bullets)
	table.insert(enemyModels, workspace.Contents.Ragdolls)

	return enemyModels
end

function Bullets._getCommand(): string
	return "Bullets"
end

function Bullets._getBullets()
	return bullets
end

function Bullets._getBulletById(p: string)
	local bullets2 = Bullets._getBullets()

	for _, bullet in bullets2 do
		if bullet.id == p then
			return bullet
		end
	end

	return nil
end

function Bullets._getBulletIndex(p)
	for k, v in Bullets._getBullets(), nil, nil do
		if v.id == p.id then
			return k
		end
	end

	return nil
end

function Bullets._getBulletsByOwnerId(p: string)
	local bullets2 = {}

	for _, v in Bullets._getBullets(), nil, nil do
		if v.ownerId == p then
			table.insert(bullets2, v)
		end
	end

	return bullets2
end

function Bullets._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, "Bullets", p2, p3, ...)
			end
		end
	end
end

function Bullets.newServer(p)
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	Bullets.Init(p)
	table.insert(Bullets._getBullets(), p)
	BulletEvents.BulletNew:Fire(p.id)

	for _, v in Players:GetPlayers(), nil, nil do
		if tostring(v.UserId) ~= p.ownerId then
			Loaded.FireClient(v, Bullets._getCommand(), p.id, p)
		end
	end

	return p
end

function Bullets:newClient()
	self.maid = Maid.new()

	Bullets.Init(self)
	table.insert(Bullets._getBullets(), self)
	BulletEvents.BulletNew:Fire(self.id)

	if Bullets.IsOwner(self) then
		RemoteSignals.FireServer("Bullets", "Bullets", self.id, self)
	end

	return self
end

function Bullets.IsOwner(p): boolean
	if isServer then
		warn("Using IsOwner() on the server")
		return false
	end

	local userId = tostring(Players.LocalPlayer.UserId)

	return p.ownerId == userId
end

function Bullets.IsEnemy(p): boolean
	return not isServer and p.ownerId == nil
end

function Bullets:Init()
	local module = Bullets.GetModule(self)

	local function sharedSetUp(state)
		state.maid = Maid.new()

		local id = tonumber(state.id)
		state.speed = Random.new(id):NextInteger(module.speed.min, module.speed.max)
		local total = 0
		state.timeNeeded = module.distance / state.speed

		state.maid.destroyConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total >= state.timeNeeded then
				Bullets.Destroy(state)
			end
		end)
	end

	if isServer then
		sharedSetUp(self)
		return
	end

	local localPlayer = Players.LocalPlayer
	tostring(localPlayer.UserId)
	local character = localPlayer.Character

	if character then
		character:FindFirstChildWhichIsA("Humanoid")
	end

	sharedSetUp(self)

	if Bullets.IsEnemy(self) or not Bullets.IsOwner(self) then
		self.lookVectorHistory = {
			{
				lookVector = self.lookVectorHistory[#self.lookVectorHistory].lookVector,
				time = TimeSync.time()
			}
		}
	end

	if Bullets.IsOwner(self) or Bullets.IsEnemy(self) then
		self.maid.listenerConnection = BulletEvents.BulletTouched.Event:Connect(function(p, raycastResult: RaycastResult)
			if p ~= self.id then
				return
			end

			local convertRaycastToTable = TableHelper.ConvertRaycastToTable(raycastResult)
			local _normal = convertRaycastToTable.normal
			local instance = convertRaycastToTable.instance
			local enemyByPart = Enemies._getEnemyByPart(instance)
			local player = PlayerHelpers.GetPlayerFromInstance(instance)

			if enemyByPart then
				local id = enemyByPart.id
				local hasTag = CollectionService:HasTag(instance, "Headshot")
				local hasTag2 = CollectionService:HasTag(instance, "Shield")
				Bullets.HitEnemy(self, convertRaycastToTable, id, {
					isHeadshot = hasTag,
					isShield = hasTag2
				})

				if hasTag2 then
					Sounds.Play(Sounds.new({ "Feel", "Ricochet2" }, convertRaycastToTable.position), nil, true)
				end
			elseif player then
				local userId = tostring(player.UserId)

				Bullets.HitPlayer(self, convertRaycastToTable, userId)
			else
				local instance2 = convertRaycastToTable and convertRaycastToTable.instance

				if instance2 and instance2:IsA("BasePart") then
					Bullets.HitWall(self, convertRaycastToTable)
				end
			end
		end)
	end

	Bullets.Shoot(self)
end

function Bullets.Shoot(data)
	local module = Bullets.GetModule(data)

	local lookVector = data.lookVectorHistory[#data.lookVectorHistory].lookVector
	local clone = module.instance:Clone()
	clone.Anchored = true
	clone.CFrame = CFrame.lookAt(data.origin, data.origin + lookVector, Vector3.new(0, 1, 0))
	clone.Parent = data.ownerId and workspace.Contents.Bullets.Player or workspace.Contents.Bullets.Enemy
	data.maid.object = clone

	local z = data.maid.object.Size.Z
	local attachments = {}

	for _, attachment in data.maid.object:GetChildren(), nil, nil do
		if attachment:IsA("Attachment") then
			table.insert(attachments, attachment)
		end
	end

	local filterDescendantsInstances = data.ownerId and _generateBlacklist(data)

	if not filterDescendantsInstances then
		filterDescendantsInstances = Enemies._getEnemyModels()

		table.insert(filterDescendantsInstances, workspace.Contents.Bullets)
		table.insert(filterDescendantsInstances, workspace.Contents.Ragdolls)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances

	data.maid.movementConnection = RunService.Heartbeat:Connect(function(dt)
		local lookVector2 = data.lookVectorHistory[#data.lookVectorHistory].lookVector
		local speed = data.speed
		local _position = data.maid.object.Position
		local position = Bullets.CalculatePosition(data)

		data.maid.object.CFrame = CFrame.lookAlong(position, lookVector2)

		if not Bullets.IsOwner(data) and data.ownerId then
			return
		end

		for _, v in attachments do
			local v2 = v.WorldCFrame.Position - lookVector2 * speed * dt
			local v3 = lookVector2 * (z / 2 + speed * dt)
			local raycastResult = workspace:Raycast(v2, v3, raycastParams)

			if raycastResult then
				BulletEvents.BulletTouched:Fire(data.id, raycastResult)
				break
			end
		end
	end)

	Bullets.GetFunctionsModule(data).onCreate(data)
end

function Bullets:HitWall(p)
	local module = Bullets.GetModule(self)
	local functionsModule = Bullets.GetFunctionsModule(self)
	local instance = p.instance
	local normal = p.normal

	if isServer then
		local playerByUserId = self.ownerId and Players:GetPlayerByUserId((tonumber(self.ownerId)))
		Bullets._fireAllButOwner(playerByUserId, "BulletsHitWall", self.id, p)
		Bullets.Destroy(self)
	elseif not (Bullets.IsEnemy(self) or Bullets.IsOwner(self)) then
		functionsModule.onHitPart(self, p)
	elseif module.ricochet then
		if self.lastRicochetHit and self.lastRicochetHit == instance then
			return
		end

		self.lastRicochetHit = instance

		local lookVector = self.lookVectorHistory[#self.lookVectorHistory].lookVector
		local v = lookVector - 2 * lookVector:Dot(normal) * normal

		Bullets.SetLookVector(self, v)
	else
		RemoteSignals.FireServer("Bullets", "BulletsHitWall", self.id, p)

		functionsModule.onHitPart(self, p)
		Bullets.Destroy(self)
	end
end

function Bullets.HitEnemy(data, p, p2: string, p3)
	local module = Bullets.GetModule(data)
	local functionsModule = Bullets.GetFunctionsModule(data)
	local module2 = modules:FindFirstChild(data.weaponType) and require(modules:FindFirstChild(data.weaponType))
	local v = module.damage * (p3.isHeadshot and module2 and module2.headshotMultiplier or 1) * (p3.isShield and 0.5 or 1)

	if isServer then
		local v2 = p2 and Enemies._getEnemyById(p2)

		if not (data.ownerId and v2 and module2) then
			return
		end

		if data.hitDebounce[v2.id] and tick() - data.hitDebounce[v2.id] < BulletConstants.HIT_DEBOUNCE then
			warn("Enemy was recently hit")
			return
		end

		local lookVector = data.lookVectorHistory[#data.lookVectorHistory].lookVector

		data.hitDebounce[v2.id] = tick()

		Enemies.Knockback(v2, module.knockback, lookVector)
		Enemies.TakeDamage(v2, v, data.ownerId, module2.masteryType)

		local playerByUserId = Players:GetPlayerByUserId((tonumber(data.ownerId)))
		Bullets._fireAllButOwner(playerByUserId, "BulletsHitEnemy", data.id, p, p2, p3)

		if not module.pierce then
			Bullets.Destroy(data)
		end
	else
		local enemyById = Enemies._getEnemyById(p2)

		if not enemyById then
			return
		end

		if Bullets.IsOwner(data) then
			if
				data.hitDebounce[enemyById.id]
				and tick() - data.hitDebounce[enemyById.id] < BulletConstants.HIT_DEBOUNCE
			then
				warn("Enemy was recently hit")
				return
			end

			local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)
			Crosshair:Hitmarker(p3.isHeadshot)

			data.hitDebounce[enemyById.id] = tick()
			functionsModule.onHitEnemy(data, p)
			Enemies.Indicator(enemyById, v)
			RemoteSignals.FireServer("Bullets", "BulletsHitEnemy", data.id, p, p2, p3)

			if not module.pierce then
				Bullets.Destroy(data)
			end
		else
			functionsModule.onHitEnemy(data, p)
		end
	end
end

function Bullets.HitPlayer(data, p, p2: string)
	local module = Bullets.GetModule(data)
	Bullets.GetFunctionsModule(data)
	local playerByUserId = p2 and Players:GetPlayerByUserId((tonumber(p2)))

	if not playerByUserId then
		return
	end

	if isServer then
		if data.ownerId then
			return
		end

		if data.hitDebounce[p2] and tick() - data.hitDebounce[p2] < BulletConstants.HIT_DEBOUNCE then
			warn("Player was recently hit")
			return
		end

		local damage = module.damage

		local character = playerByUserId.Character

		if character and character:FindFirstChildWhichIsA("Humanoid") then
			HealthHandler.TakeDamage(p2, damage)
			data.hitDebounce[p2] = tick()
		end

		local playerByUserId2 = data.ownerId and Players:GetPlayerByUserId(data.ownerId)
		Bullets._fireAllButOwner(playerByUserId2, "BulletsHitPlayer", data.id, p, p2)
		Bullets.Destroy(data)
	else
		if Players.LocalPlayer ~= playerByUserId then
			return
		end

		if data.hitDebounce[p2] and tick() - data.hitDebounce[p2] < BulletConstants.HIT_DEBOUNCE then
			warn("Player was recently hit")
			return
		end

		data.hitDebounce[p2] = tick()

		RemoteSignals.FireServer("Bullets", "BulletsHitPlayer", data.id, p, p2)
		Bullets.Destroy(data)
	end
end

function Bullets.GetModule(p)
	local module = require(Modules:FindFirstChild(p.bulletType))

	return module
end

function Bullets.GetFunctionsModule(p)
	local Functions = require(Modules:FindFirstChild(p.bulletType).Functions)

	return Functions
end

function Bullets.SetLookVector(p, lookVector: Vector3)
	local function sharedSetUp(p2, lookVector2: Vector3) -- 2 equivalent calls inferred from this helper
		local time = p2.lookVectorHistory[1].time

		table.insert(p2.lookVectorHistory, {
			lookVector = lookVector2,
			time = TimeSync.time() - time
		})
	end

	if isServer then
		sharedSetUp(p, lookVector) -- inferred equivalent call
		local playerByUserId = Players:GetPlayerByUserId((tonumber(p.ownerId)))
		Bullets._fireAllButOwner(playerByUserId, Bullets._getCommand() .. "SetLookVector", p.id, lookVector)
	else
		sharedSetUp(p, lookVector) -- inferred equivalent call

		if Bullets.IsOwner(p) then
			RemoteSignals.FireServer("Bullets", "BulletsSetLookVector", p.id, lookVector)
		end
	end
end

function Bullets.CalculatePosition(data)
	local origin = data.origin
	local _timeNeeded = data.timeNeeded

	local time = data.lookVectorHistory[1].time

	for k, v in data.lookVectorHistory do
		local lookVector = v.lookVector
		local time2 = TimeSync.time()
		origin += lookVector * ((time2 - (time + (k == 1 and 0 or v.time)) - (data.lookVectorHistory[k + 1] and time2 - (time + data.lookVectorHistory[k + 1].time) or 0)) * data.speed)
	end

	return origin
end

function Bullets:SetValue(p: string, p2, list, flag: boolean)
	if isServer then
		local _ = self[p]
		self[p] = p2

		for _, v in Players:GetPlayers(), nil, nil do
			if not table.find(list, v) then
				RemoteSignals.FireClient(v, "Bullets", "BulletsSetValue", self.id, p, p2, list, flag)
			end
		end
	else
		local _ = self[p]
		self[p] = p2

		local localPlayer = Players.LocalPlayer
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		tostring(localPlayer.UserId)

		if Bullets.IsOwner(self) and not flag then
			RemoteSignals.FireServer("Bullets", "BulletsSetValue", self.id, p, p2, list, flag)
		end
	end
end

function Bullets.GetLookVector(p)
	return p.lookVectorHistory[#p.lookVectorHistory].lookVector
end

function Bullets.Destroy(p)
	BulletEvents.BulletDestroyed:Fire(p.id)
	table.remove(Bullets._getBullets(), Bullets._getBulletIndex(p))

	local functionsModule = Bullets.GetFunctionsModule(p)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("Bullets", "BulletsDestroy", p.id)
		functionsModule.onDestroy(p)
	else
		functionsModule.onDestroy(p)
	end

	p.maid:Destroy()
end

return Bullets