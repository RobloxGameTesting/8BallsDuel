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
require(ReplicatedStorage.Libraries.Classes.Visuals)
game:GetService("UserInputService")
game:GetService("TweenService")
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(script.AreaTypes)
local AreaEvents = require(script.AreaEvents)
require(script.AreaHelpers)
require(script.AreaConstants)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Modules = script.Modules

local Areas = {}

local areas = {}

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

function Areas._getCommand(): string
	return "Areas"
end

function Areas._getAreas()
	return areas
end

function Areas._getAreaById(p: string)
	local areas2 = Areas._getAreas()

	for _, area in areas2 do
		if area.id == p then
			return area
		end
	end

	return nil
end

function Areas._getAreaIndex(p)
	for k, v in Areas._getAreas(), nil, nil do
		if v.id == p.id then
			return k
		end
	end

	return nil
end

function Areas._getAreasByOwnerId(p: string)
	local areas2 = {}

	for _, v in Areas._getAreas(), nil, nil do
		if v.ownerId == p then
			table.insert(areas2, v)
		end
	end

	return areas2
end

function Areas._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, "Areas", p2, p3, ...)
			end
		end
	end
end

function Areas:newServer()
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	Areas.Init(self)
	table.insert(Areas._getAreas(), self)
	AreaEvents.New:Fire(self.id)

	self.loadId = Loaded.AddQueue(Areas._getCommand(), self.id, function()
		return self
	end)

	for _, v in Players:GetPlayers(), nil, nil do
		if v ~= self.owner then
			Loaded.FireClient(v, Areas._getCommand(), self.id, self)
		end
	end

	return self
end

function Areas.newClient(p)
	Areas.Init(p)
	table.insert(Areas._getAreas(), p)
	AreaEvents.New:Fire(p.id)

	if p.isOwner then
		RemoteSignals.FireServer("Areas", "Areas", p.id, p)
	end

	Areas.Activate(p)

	return p
end

function Areas:Init()
	local module = Areas.GetModule(self)

	local function sharedSetUp(state) -- 2 equivalent calls inferred from this helper
		state.maid = Maid.new()

		local total = 0
		state.timeNeeded = module.duration

		state.maid.destroyConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total >= state.timeNeeded then
				Areas.Destroy(state)
			end
		end)
	end

	if isServer then
		sharedSetUp(self) -- inferred equivalent call
	else
		local userId = tostring(Players.LocalPlayer.UserId)
		sharedSetUp(self) -- inferred equivalent call
		self.isOwner = self.ownerId == userId

		if self.isOwner then
			self.maid.listenerConnection = AreaEvents.Touched.Event:Connect(function(p: string, p2)
				if p ~= self.id then
					return
				end

				local enemyByPart = Enemies._getEnemyByPart(p2)

				if enemyByPart then
					local id = enemyByPart.id
					local humanoidRootPart = self.owner
						and self.owner.Character
						and self.owner.Character:FindFirstChild("HumanoidRootPart")

					if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						return
					end

					Areas.HitEnemy(self, id, humanoidRootPart.CFrame.LookVector)
				end
			end)
		end
	end
end

function Areas.Activate(data)
	if isServer then
		return
	end

	if data.isOwner then
		local region = data.region
		Areas.GetModule(data)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = Enemies._getEnemyRootParts()
		local partsInPart = workspace:GetPartsInPart(region, overlapParams)

		for _, v in partsInPart do
			AreaEvents.Touched:Fire(data.id, v)
		end
	end
end

function Areas.HitEnemy(data, p: string, vector3: Vector3)
	local module = Areas.GetModule(data)
	Areas.GetFunctionsModule(data)

	if isServer then
		local module2 = Areas.GetModule(data)
		local v = p and Enemies._getEnemyById(p)

		if not v or table.find(data.hitList, v.id) then
			return
		end

		table.insert(data.hitList, v.id)

		Enemies.TakeDamage(v, module2.damage, data.ownerId, data.masteryType)

		Areas._fireAllButOwner(data.owner, "AreasHitEnemy", data.id, p)
	else
		local enemyById = Enemies._getEnemyById(p)

		if not enemyById or not data.isOwner or table.find(data.hitList, enemyById.id) then
			return
		end

		local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)
		Crosshair:Hitmarker(false)

		table.insert(data.hitList, enemyById.id)

		Enemies.Indicator(enemyById, module.damage)
		RemoteSignals.FireServer("Areas", "AreasHitEnemy", data.id, p, vector3)
	end
end

function Areas.GetModule(p)
	local module = require(Modules:FindFirstChild(p.areaType))

	return module
end

function Areas.GetFunctionsModule(p)
	local Functions = require(Modules:FindFirstChild(p.areaType).Functions)

	return Functions
end

function Areas.Destroy(data)
	AreaEvents.Destroyed:Fire(data.id)
	table.remove(Areas._getAreas(), Areas._getAreaIndex(data))

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("Areas", "AreasDestroy", data.id)
		Loaded.RemoveQueue(data.loadId)
	else
		local _isOwner = data.isOwner
	end

	data.maid:Destroy()
end

return Areas