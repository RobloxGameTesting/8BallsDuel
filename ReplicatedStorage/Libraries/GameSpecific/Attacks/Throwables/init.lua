local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.Probability)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RunService = game:GetService("RunService")
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
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
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local CollectionService = game:GetService("CollectionService")
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(script.ThrowableTypes)
local ThrowableEvents = require(script.ThrowableEvents)
require(script.ThrowableConstants)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Collisions = require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Modules = script.Modules

local Throwables = {}

local throwables = {}

local function _generateBlacklist(_)
	local blacklist = {}

	table.insert(blacklist, workspace.Contents.Ragdolls)
	table.insert(blacklist, workspace.Contents.Bullets)

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

function Throwables._getCommand(): string
	return "Throwables"
end

function Throwables._getThrowables()
	return throwables
end

function Throwables._getThrowableById(p: string)
	local throwables2 = Throwables._getThrowables()

	for _, throwable in throwables2 do
		if throwable.id == p then
			return throwable
		end
	end

	return nil
end

function Throwables._getThrowableIndex(p)
	for k, v in Throwables._getThrowables(), nil, nil do
		if v.id == p.id then
			return k
		end
	end

	return nil
end

function Throwables._getThrowablesByOwnerId(p: string)
	local throwables2 = {}

	for _, v in Throwables._getThrowables(), nil, nil do
		if v.ownerId == p then
			table.insert(throwables2, v)
		end
	end

	return throwables2
end

function Throwables._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, "Throwables", p2, p3, ...)
			end
		end
	end
end

function Throwables.newServer(p)
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	Throwables.Init(p)
	table.insert(Throwables._getThrowables(), p)
	ThrowableEvents.New:Fire(p.id)

	for _, v in Players:GetPlayers(), nil, nil do
		if v ~= p.owner then
			Loaded.FireClient(v, Throwables._getCommand(), p.id, p)
		end
	end

	return p
end

function Throwables:newClient()
	self.maid = Maid.new()

	Throwables.Init(self)
	table.insert(Throwables._getThrowables(), self)
	ThrowableEvents.New:Fire(self.id)

	if self.isOwner then
		RemoteSignals.FireServer("Throwables", "Throwables", self.id, self)
	end

	return self
end

function Throwables:Init()
	local module = Throwables.GetModule(self)

	local function sharedSetUp(state) -- 2 equivalent calls inferred from this helper
		state.maid = Maid.new()

		local total = 0
		local timeNeeded = module.timeNeeded

		state.maid.destroyConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if timeNeeded <= total then
				Throwables.Destroy(state)
			end
		end)
	end

	if isServer then
		sharedSetUp(self) -- inferred equivalent call
		self.maid.listenerConnection = ThrowableEvents.Hit.Event:Connect(function(p, instance)
			if p ~= self.id then
				return
			end

			local enemyByPart = Enemies._getEnemyByPart(instance)
			local player = PlayerHelpers.GetPlayerFromInstance(instance)

			if enemyByPart then
				local _id = enemyByPart.id
				local hasTag = CollectionService:HasTag(instance, "Headshot")
				local hasTag2 = CollectionService:HasTag(instance, "Shield")
				local _ = { isHeadshot = hasTag, isShield = hasTag2 }

				if hasTag2 then
					Sounds.Play(Sounds.new({ "Feel", "Ricochet2" }, self.maid.object.Position), nil, true)
				end
			elseif player then
				tostring(player.UserId)
			else
				Throwables.HitWall(self, instance)
			end
		end)

		Throwables.Shoot(self)
	else
		local localPlayer = Players.LocalPlayer
		local userId = tostring(localPlayer.UserId)
		local character = localPlayer.Character

		if character then
			character:FindFirstChildWhichIsA("Humanoid")
		end

		sharedSetUp(self) -- inferred equivalent call
		self.isOwner = self.ownerId == userId
	end
end

function Throwables.Shoot(data)
	local module = Throwables.GetModule(data)

	local clone = module.instance:Clone()
	Collisions:AddToGroup(clone, "Throwable")
	clone.Anchored = false
	clone.CFrame = CFrame.new(data.origin)
	clone.Parent = data.ownerId and workspace.Contents.Bullets.Player or workspace.Contents.Bullets.Enemy
	data.maid.object = clone

	local v = Scheduler.BindHeartbeat(function(_: number)
		ModelHelper.SetNetworkOwner(clone, nil)
	end)
	function data.maid.cleanUpNetworkScheduler()
		Scheduler.UnbindHeartbeat(v)
	end

	local dampenRate = module.dampenRate
	local v2 = Scheduler.BindHeartbeat(function(p: number)
		clone.AssemblyAngularVelocity *= 1 - p * dampenRate
	end)
	function data.maid.cleanUpDampenScheduler()
		Scheduler.UnbindHeartbeat(v2)
	end

	local vector3 = Vector3.new(0, -workspace.Gravity, 0)
	local position = clone.Position
	local v3 = position + data.lookVector * 35

	local speed = data.speed
	clone.AssemblyLinearVelocity = (v3 - position - vector3 * 0.5 * 0.4 * 0.4) / 0.4 * speed

	local v4 = {}

	for _, attachment in data.maid.object:GetChildren(), nil, nil do
		if attachment:IsA("Attachment") then
			table.insert(v4, attachment)
		end
	end

	local v5 = data.ownerId and _generateBlacklist(data)

	if not v5 then
		v5 = Enemies._getEnemyModels()

		table.insert(v5, workspace.Contents.Bullets)
		table.insert(v5, workspace.Contents.Ragdolls)
	end

	data.maid.touchedEvent = data.maid.object.Touched:Connect(function(otherPart)
		if table.find(v5, otherPart) then
			return
		end

		Throwables.SetValue(data, "position", data.maid.object.Position, {}, true)
		ThrowableEvents.Hit:Fire(data.id, otherPart)
	end)
end

function Throwables.HitWall(p, p2)
	local module = Throwables.GetModule(p)
	local functionsModule = Throwables.GetFunctionsModule(p)

	if isServer then
		print("Hit wall")

		if module.ricochet then
			return
		end

		functionsModule.onHitPart(p, p2)
		Throwables.Destroy(p)
	end
end

function Throwables.GetModule(p)
	local module = require(Modules:FindFirstChild(p.throwableType))

	return module
end

function Throwables.GetFunctionsModule(p)
	local Functions = require(Modules:FindFirstChild(p.throwableType).Functions)

	return Functions
end

function Throwables:SetValue(p: string, p2, list, flag: boolean)
	if isServer then
		local _ = self[p]
		self[p] = p2

		for _, v in Players:GetPlayers(), nil, nil do
			if not table.find(list, v) then
				RemoteSignals.FireClient(v, "Throwables", "ThrowablesSetValue", self.id, p, p2, list, flag)
			end
		end
	else
		local _ = self[p]
		self[p] = p2

		local localPlayer = Players.LocalPlayer
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		tostring(localPlayer.UserId)

		if self.isOwner and not flag then
			RemoteSignals.FireServer("Throwables", "ThrowablesSetValue", self.id, p, p2, list, flag)
		end
	end
end

function Throwables.Destroy(p)
	ThrowableEvents.Destroyed:Fire(p.id)
	table.remove(Throwables._getThrowables(), Throwables._getThrowableIndex(p))

	local functionsModule = Throwables.GetFunctionsModule(p)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

		local position = p.maid.object.Position
		Throwables.SetValue(p, "position", position, {}, true)
		Loaded.FireAllClients("Throwables", "ThrowablesDestroy", p.id)
		functionsModule.onDestroy(p)
	else
		functionsModule.onDestroy(p)
	end

	p.maid:Destroy()
end

return Throwables