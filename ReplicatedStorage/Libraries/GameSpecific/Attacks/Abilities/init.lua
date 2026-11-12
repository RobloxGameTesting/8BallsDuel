local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.Probability)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Scheduler)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Classes.Mouses)
require(ReplicatedStorage.Libraries.Classes.CameraShaker)
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
game:GetService("UserInputService")
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(script.AbilityTypes)
local AbilityEvents = require(script.AbilityEvents)
require(script.AbilityHelpers)
require(script.AbilityConstants)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Modules = script.Modules

local Abilities = {}

local abilities = {}
local abilities2 = RemoteEnums.Abilities

function Abilities._getCommand()
	return abilities2
end

function Abilities._getAbilities()
	return abilities
end

function Abilities._getAbilityById(p: string)
	local abilities3 = Abilities._getAbilities()

	for _, ability in abilities3 do
		if ability.id == p then
			return ability
		end
	end

	return nil
end

function Abilities._getAbilityIndex(p)
	for k, v in Abilities._getAbilities(), nil, nil do
		if v.id == p.id then
			return k
		end
	end

	return nil
end

function Abilities._getAbilitiesByOwnerId(p: string)
	local abilities3 = {}

	for _, v in Abilities._getAbilities(), nil, nil do
		if v.ownerId == p then
			table.insert(abilities3, v)
		end
	end

	return abilities3
end

function Abilities._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, abilities2, p2, p3, ...)
			end
		end
	end
end

function Abilities:newServer(flag: boolean?)
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	local functionsModule = Abilities.GetFunctionsModule(self)

	Abilities.Init(self)
	table.insert(Abilities._getAbilities(), self)
	AbilityEvents.New:Fire(self.id)

	self.loadId = Loaded.AddQueue(Abilities._getCommand(), self.id, function()
		return self
	end)

	for _, v in Players:GetPlayers(), nil, nil do
		if v ~= self.owner then
			Loaded.FireClient(v, Abilities._getCommand(), self.id, self)
		end
	end

	if flag then
		Loaded.FireClient(self.owner, Abilities._getCommand(), self.id, self)
	end

	functionsModule.onCreate(self)

	return self
end

function Abilities:newClient()
	local functionsModule = Abilities.GetFunctionsModule(self)
	self.maid = Maid.new()

	Abilities.Init(self)
	table.insert(Abilities._getAbilities(), self)
	AbilityEvents.New:Fire(self.id)

	if self.isOwner then
		RemoteSignals.FireServer(abilities2, abilities2, self.id, self)
	end

	functionsModule.onCreate(self)

	return self
end

function Abilities:Init()
	local module = Abilities.GetModule(self)

	local function sharedSetUp(p) -- 2 equivalent calls inferred from this helper
		p.maid = Maid.new()

		local total = 0
		local duration = module.duration

		p.maid.destroyConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if duration <= total then
				Abilities.Destroy(p)
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
	end
end

function Abilities.GetModule(p)
	local module = require(Modules:FindFirstChild(p.abilityType))

	return module
end

function Abilities.GetFunctionsModule(p)
	local Functions = require(Modules:FindFirstChild(p.abilityType).Functions)

	return Functions
end

function Abilities:SetValue(p: string, p2, list, flag: boolean)
	if isServer then
		local _ = self[p]
		self[p] = p2

		for _, v in Players:GetPlayers(), nil, nil do
			if not table.find(list, v) then
				RemoteSignals.FireClient(v, abilities2, "SetValue", self.id, p, p2, list, flag)
			end
		end
	else
		local _ = self[p]
		self[p] = p2

		local localPlayer = Players.LocalPlayer
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		tostring(localPlayer.UserId)

		if self.isOwner and not flag then
			RemoteSignals.FireServer(abilities2, "SetValue", self.id, p, p2, list, flag)
		end
	end
end

function Abilities.Destroy(data)
	AbilityEvents.Destroyed:Fire(data.id)
	table.remove(Abilities._getAbilities(), Abilities._getAbilityIndex(data))

	local functionsModule = Abilities.GetFunctionsModule(data)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients(abilities2, abilities2 .. "Destroy", data.id)
		functionsModule.onDestroy(data)
		Loaded.RemoveQueue(data.loadId)
	else
		functionsModule.onDestroy(data)
	end

	data.maid:Destroy()
end

return Abilities