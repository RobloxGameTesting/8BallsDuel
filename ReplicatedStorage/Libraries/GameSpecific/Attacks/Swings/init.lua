local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
game:GetService("UserInputService")
game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
require(ReplicatedStorage.Libraries.Modules.Probability)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Scheduler)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Classes.Mouses)
require(ReplicatedStorage.Libraries.Classes.CameraShaker)
require(ReplicatedStorage.Libraries.Modules.Device)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)

require(script.SwingTypes)
local SwingEvents = require(script.SwingEvents)
local SwingConstants = require(script.SwingConstants)
require(script.SwingHelpers)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local isServer = RunService:IsServer()
local Modules = script.Modules

local Swings = {}

local swings = {}

local function _generateBlacklist(p)
	local characters = {}

	if not p.isOwner then
		return characters
	end

	for _, v in Players:GetPlayers(), nil, nil do
		local character = v.Character

		if character then
			table.insert(characters, character)
		end
	end

	return characters
end

function Swings._getCommand(): string
	return "Swings"
end

function Swings._getSwings()
	return swings
end

function Swings._getSwingById(p: string)
	local swings2 = Swings._getSwings()

	for _, swing in swings2 do
		if swing.id == p then
			return swing
		end
	end

	return nil
end

function Swings._getSwingIndex(p)
	for k, v in Swings._getSwings(), nil, nil do
		if v.id == p.id then
			return k
		end
	end

	return nil
end

function Swings._getSwingsByOwnerId(p: string)
	local swings2 = {}

	for _, v in Swings._getSwings(), nil, nil do
		if v.ownerId == p then
			table.insert(swings2, v)
		end
	end

	return swings2
end

function Swings._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, "Swings", p2, p3, ...)
			end
		end
	end
end

function Swings:newServer()
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	Swings.Init(self)
	table.insert(Swings._getSwings(), self)
	SwingEvents.SwingNew:Fire(self.id)

	self.loadId = Loaded.AddQueue(Swings._getCommand(), self.id, function()
		return self
	end)

	for _, v in Players:GetPlayers(), nil, nil do
		if v ~= self.owner then
			Loaded.FireClient(v, Swings._getCommand(), self.id, self)
		end
	end

	return self
end

function Swings:newClient()
	self.maid = Maid.new()

	Swings.Init(self)
	table.insert(Swings._getSwings(), self)
	SwingEvents.SwingNew:Fire(self.id)

	if self.isOwner then
		RemoteSignals.FireServer("Swings", "Swings", self.id, self)
	end

	return self
end

function Swings:Init()
	local module = Swings.GetModule(self)

	local function sharedSetUp(state) -- 2 equivalent calls inferred from this helper
		state.maid = Maid.new()

		local total = 0
		state.timeNeeded = module.duration

		state.maid.destroyConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total >= state.timeNeeded then
				Swings.Destroy(state)
			end
		end)
	end

	if isServer then
		sharedSetUp(self) -- inferred equivalent call
	else
		local localPlayer = Players.LocalPlayer
		local userId = tostring(localPlayer.UserId)
		local character = localPlayer.Character

		if character then
			character:FindFirstChildWhichIsA("Humanoid")
		end

		sharedSetUp(self) -- inferred equivalent call
		self.isOwner = self.ownerId == userId

		if self.isOwner then
			self.maid.listenerConnection = SwingEvents.SwingTouched.Event:Connect(function(p, raycastResult: RaycastResult)
				if p ~= self.id then
					return
				end

				local convertRaycastToTable = TableHelper.ConvertRaycastToTable(raycastResult)
				local _normal = convertRaycastToTable.normal
				local instance = convertRaycastToTable.instance
				local enemyByPart = Enemies._getEnemyByPart(instance)

				if enemyByPart then
					local id = enemyByPart.id
					local hasTag = CollectionService:HasTag(instance, "Headshot")
					local hasTag2 = CollectionService:HasTag(instance, "Shield")
					local v = { isHeadshot = hasTag, isShield = hasTag2 }

					if hasTag2 then
						warn("Do half damage if it hits a shield")
						Swings.HitEnemy(self, convertRaycastToTable, id, v)

						Sounds.Play(Sounds.new({ "Feel", "Ricochet2" }, convertRaycastToTable.position), nil, true)
					elseif hasTag then
						Swings.HitEnemy(self, convertRaycastToTable, id, v)
					else
						Swings.HitEnemy(self, convertRaycastToTable, id, v)
					end
				end
			end)

			Swings.Swing(self)
		end
	end
end

function Swings.Swing(data)
	if isServer then
		return
	end

	if data.isOwner then
		local module = Swings.GetModule(data)

		local function onHitListener(raycastResult: RaycastResult)
			local enemyByPart = Enemies._getEnemyByPart(raycastResult.Instance)

			if enemyByPart and not table.find(data.enemyIdsHit, enemyByPart.id) then
				table.insert(data.enemyIdsHit, enemyByPart.id)

				SwingEvents.SwingTouched:Fire(data.id, raycastResult)
			end
		end

		data.raycastHitbox:OnHit(onHitListener)
		task.spawn(function()
			task.wait(module.delay)
			data.raycastHitbox:HitStart()
		end)
	end
end

function Swings.HitEnemy(data, p, p2: string, p3)
	local module = Swings.GetModule(data)
	local functionsModule = Swings.GetFunctionsModule(data)

	local v = module.damage * (p3.isHeadshot and 1.2 or 1)

	if isServer then
		local v2 = p2 and Enemies._getEnemyById(p2)

		if not v2 then
			return
		end

		if data.hitDebounce[v2.id] and tick() - data.hitDebounce[v2.id] < SwingConstants.HIT_DEBOUNCE then
			warn("Enemy was recently hit")
			return
		end

		data.hitDebounce[v2] = tick()

		local humanoidRootPart = data.owner
			and data.owner.Character
			and data.owner.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local lookVector = humanoidRootPart.CFrame.LookVector
			Enemies.Knockback(v2, module.knockback, lookVector)
		end

		Enemies.TakeDamage(v2, v, data.ownerId, data.masteryType)

		Swings._fireAllButOwner(data.owner, "SwingsHitEnemy", data.id, p, p2, p3)

		if not module.pierce then
			Swings.Destroy(data)
		end
	else
		local enemyById = Enemies._getEnemyById(p2)

		if not enemyById then
			return
		end

		if data.isOwner then
			if data.hitDebounce[enemyById] and tick() - data.hitDebounce[enemyById] < SwingConstants.HIT_DEBOUNCE then
				warn("Enemy was recently hit")
				return
			end

			local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)
			Crosshair:Hitmarker(p3.isHeadshot)

			data.hitDebounce[enemyById] = tick()
			functionsModule.onHitEnemy(data, p)
			Enemies.Indicator(enemyById, v)
			RemoteSignals.FireServer("Swings", "SwingsHitEnemy", data.id, p, p2, p3)

			if not module.pierce then
				Swings.Destroy(data)
			end
		else
			functionsModule.onHitEnemy(data, p)
		end
	end
end

function Swings.GetModule(p)
	local module = require(Modules:FindFirstChild(p.swingType))

	return module
end

function Swings.GetFunctionsModule(p)
	local Functions = require(Modules:FindFirstChild(p.swingType).Functions)

	return Functions
end

function Swings.Destroy(data)
	SwingEvents.SwingDestroyed:Fire(data.id)
	table.remove(Swings._getSwings(), Swings._getSwingIndex(data))

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("Swings", "SwingsDestroy", data.id)
		Loaded.RemoveQueue(data.loadId)
	elseif data.isOwner then
		data.raycastHitbox:OnStopped(function(callback)
			callback()
		end)
		data.raycastHitbox:HitStop()
	end

	data.maid:Destroy()
end

return Swings