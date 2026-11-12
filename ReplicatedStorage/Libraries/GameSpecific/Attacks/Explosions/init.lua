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
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
game:GetService("UserInputService")
game:GetService("TweenService")
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

require(script.ExplosionTypes)
local ExplosionEvents = require(script.ExplosionEvents)
require(script.ExplosionConstants)
require(script.ExplosionHelpers)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Modules = script.Modules

local Explosions = {}

local explosions = {}

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

function Explosions._getCommand(): string
	return "Explosions"
end

function Explosions._getExplosions()
	return explosions
end

function Explosions._getExplosionById(p: string)
	local explosions2 = Explosions._getExplosions()

	for _, explosion in explosions2 do
		if explosion.id == p then
			return explosion
		end
	end

	return nil
end

function Explosions._getExplosionIndex(p)
	for k, v in Explosions._getExplosions(), nil, nil do
		if v.id == p.id then
			return k
		end
	end

	return nil
end

function Explosions._getExplosionsByOwnerId(p: string)
	local explosions2 = {}

	for _, v in Explosions._getExplosions(), nil, nil do
		if v.ownerId == p then
			table.insert(explosions2, v)
		end
	end

	return explosions2
end

function Explosions._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, "Explosions", p2, p3, ...)
			end
		end
	end
end

function Explosions:newServer()
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	Explosions.Init(self)
	table.insert(Explosions._getExplosions(), self)
	ExplosionEvents.ExplosionNew:Fire(self.id)

	self.loadId = Loaded.AddQueue(Explosions._getCommand(), self.id, function()
		return self
	end)

	for _, v in Players:GetPlayers(), nil, nil do
		if v ~= self.owner then
			Loaded.FireClient(v, Explosions._getCommand(), self.id, self)
		end
	end

	return self
end

function Explosions.newClient(p)
	Explosions.Init(p)
	table.insert(Explosions._getExplosions(), p)
	ExplosionEvents.ExplosionNew:Fire(p.id)

	if p.isOwner then
		RemoteSignals.FireServer("Explosions", "Explosions", p.id, p)
	end

	Explosions.Explode(p)

	return p
end

function Explosions:Init()
	local module = Explosions.GetModule(self)

	local function sharedSetUp(state) -- 2 equivalent calls inferred from this helper
		state.maid = Maid.new()

		local total = 0
		state.timeNeeded = module.duration

		state.maid.destroyConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total >= state.timeNeeded then
				Explosions.Destroy(state)
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

		Explosions.GetFunctionsModule(self).onCreate(self)

		if self.isOwner then
			self.maid.listenerConnection = ExplosionEvents.ExplosionTouched.Event:Connect(function(p, p2)
				if p ~= self.id then
					return
				end

				local enemyByPart = Enemies._getEnemyByPart(p2)
				local player = PlayerHelpers.GetPlayerFromInstance(p2)

				if enemyByPart then
					local id = enemyByPart.id
					Explosions.HitEnemy(self, id)
				elseif player then
					local userId2 = tostring(player.UserId)
					Explosions.HitPlayer(self, userId2)
				end
			end)
		end
	end
end

function Explosions.Explode(data)
	if isServer then
		return
	end

	if data.isOwner then
		local module = Explosions.GetModule(data)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = {}

		local partBoundsInRadius = workspace:GetPartBoundsInRadius(data.position, module.radius, overlapParams)

		for _, v in partBoundsInRadius do
			ExplosionEvents.ExplosionTouched:Fire(data.id, v)
		end
	end
end

function Explosions.HitPlayer(data, p: string)
	Explosions.GetModule(data)
	local functionsModule = Explosions.GetFunctionsModule(data)

	if isServer then
		if table.find(data.hitList, p) then
			warn("Enemy has already been hit!")
			return
		end

		table.insert(data.hitList, p)

		functionsModule.onPlayerHit(data, p)
		Explosions._fireAllButOwner(data.owner, "ExplosionsHitPlayer", data.id, p)
	else
		if table.find(data.hitList, p) then
			warn("Enemy has already been hit!")
			return
		end

		table.insert(data.hitList, p)

		functionsModule.onPlayerHit(data, p)

		if data.isOwner then
			RemoteSignals.FireServer("Explosions", "ExplosionsHitPlayer", data.id, p)
		end
	end
end

function Explosions.HitEnemy(data, p: string)
	Explosions.GetModule(data)
	local functionsModule = Explosions.GetFunctionsModule(data)

	if isServer then
		local v = p and Enemies._getEnemyById(p)

		if not v then
			return
		end

		if table.find(data.hitList, v.id) then
			warn("Enemy has already been hit!")
			return
		end

		table.insert(data.hitList, v.id)

		functionsModule.onEnemyHit(data, p)
		Explosions._fireAllButOwner(data.owner, "ExplosionsHitEnemy", data.id, p)
	else
		local enemyById = Enemies._getEnemyById(p)

		if not enemyById then
			return
		end

		if table.find(data.hitList, enemyById.id) then
			warn("Enemy has already been hit!")
			return
		end

		table.insert(data.hitList, enemyById.id)

		functionsModule.onEnemyHit(data, p)

		if data.isOwner then
			RemoteSignals.FireServer("Explosions", "ExplosionsHitEnemy", data.id, p)
		end
	end
end

function Explosions.GetModule(p)
	local module = require(Modules:FindFirstChild(p.explosionType))

	return module
end

function Explosions.GetFunctionsModule(p)
	local Functions = require(Modules:FindFirstChild(p.explosionType).Functions)

	return Functions
end

function Explosions.Destroy(data)
	ExplosionEvents.ExplosionDestroyed:Fire(data.id)
	table.remove(Explosions._getExplosions(), Explosions._getExplosionIndex(data))

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("Explosions", "ExplosionsDestroy", data.id)
		Loaded.RemoveQueue(data.loadId)
	else
		Explosions.GetFunctionsModule(data).onDestroy(data)

		local _isOwner = data.isOwner
	end

	data.maid:Destroy()
end

return Explosions