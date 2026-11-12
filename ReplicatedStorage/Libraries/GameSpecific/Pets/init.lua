local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Modules.Probability)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Collisions = require(ReplicatedStorage.Libraries.Modules.Collisions)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Modules.Knockback)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
game:GetService("CollectionService")
game:GetService("ServerStorage")
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local StateMachine = require(ReplicatedStorage.Libraries.Classes.StateMachine)
require(script.PetTypes)
require(script.PetConstants)
local PetEvents = require(script.PetEvents)
local PetHelpers = require(script.PetHelpers)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Assets = ReplicatedStorage.Assets
local Highlight = Assets.Highlight
local BossHealth = Assets.UI.BossHealth

local Pets = {}

local pets = {}

local lastTime = tick()

local function _stripForClient(server)
	return {
		ownerId = server.ownerId,
		id = server.id,
		loadId = server.loadId,
		maid = nil,
		npc = server.npc,
		model = server.model,
		size = server.size,
		health = server.health,
		maxHealth = server.maxHealth,
		animations = {},
		overlapAnimations = {},
		animationSequence = {},
		offsetWorld = server.offsetWorld,
		cframe = server.cframe,
		lastHitData = server.lastHitData,
		stats = server.stats
	}
end

function Pets._getCommand(): string
	return "Pets"
end

function Pets._getPets()
	return pets
end

function Pets._getPetById(p: string)
	local pets2 = Pets._getPets()

	for _, pet in pets2 do
		if pet.id == p then
			return pet
		end
	end

	return nil
end

function Pets._getPetIndex(p)
	for petIndex, v in Pets._getPets(), nil, nil do
		if v.id == p.id then
			return petIndex
		end
	end

	error(`Pet with id {p.id} not found`)
end

function Pets.newServer(npc: string, cframe: CFrame, ownerId: string?, id: string)
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	local itemData = InventoryHelpers.GetItemData("Pets", npc)
	local clone = PetHelpers.GetModule({ npc = npc }).instance:Clone()
	local _primaryPart = clone.PrimaryPart
	local stats

	if ownerId then
		stats = Profiles.GetPlayerReplica(ownerId).Data.inventory.pets[id]
	else
		stats = PetHelpers.GeneratePet(npc)
	end

	clone:ScaleTo(1 + stats.weight / itemData.weight.max / 2)
	clone:PivotTo(cframe)
	clone.Parent = workspace.Contents.Pets

	local server = {
		id = id,
		loadId = "",
		maid = Maid.new(),
		offsetWorld = Vector3.new(0, 0, 0),
		ownerId = ownerId,
		npc = npc,
		model = clone,
		stateMachine = nil,
		health = 100,
		maxHealth = 100,
		damageFrom = {},
		damageStateActive = false,
		damageCooldownReady = {},
		lastHitData = nil,
		lastPathTime = 0,
		size = clone:GetExtentsSize(),
		origin = cframe,
		cframe = cframe,
		animationSequence = {},
		sounds = {},
		visuals = {},
		hitboxActive = {},
		stats = stats
	}

	for _, part in clone:GetDescendants(), nil, nil do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanQuery = false
		part.CanTouch = false
		part.CanCollide = false
	end

	server.maid.model = clone
	Collisions:AddToGroup(clone, "Zombie")

	table.insert(Pets._getPets(), server)
	Pets.Init(server)

	server.loadId = Loaded.AddQueue(Pets._getCommand(), Pets._getCommand(), server.id, function()
		return _stripForClient(server)
	end)
	Loaded.FireAllClients(Pets._getCommand(), Pets._getCommand(), server.id, _stripForClient(server))

	return server
end

function Pets.newClient(p)
	table.insert(Pets._getPets(), p)
	Pets.Init(p)

	return p
end

function Pets:Init()
	local module = PetHelpers.GetModule(self)
	local functionsModule = PetHelpers.GetFunctionsModule(self)
	PetEvents.PetCreated:Fire(self.id)

	if isServer then
		local model = self.model
		local primaryPart = model.PrimaryPart
		model:FindFirstChildWhichIsA("Animator", true)

		local v = (self.ownerId and "Player" or "Wild") .. "Pet"
		local stateMachine = StateMachine.new(self.id, v, primaryPart.Position)
		local functionsModule2 = PetHelpers.GetFunctionsModule(self)

		stateMachine.newStateEvent.Event:Connect(function(p: string)
			if functionsModule2[`on{p}`] then
				functionsModule2[`on{p}`](self)
			end
		end)

		StateMachine.SetState(stateMachine, module.initialState)

		local v2 = Scheduler.BindHeartbeat(function(p: number)
			StateMachine.Update(stateMachine, p)
		end)
		function self.maid.cleanUpScheduler()
			Scheduler.UnbindHeartbeat(v2)
		end

		self.stateMachine = stateMachine

		self.visuals = {}

		for k, visual in module.visuals do
			local model2 = self.model

			for _, childName in visual.parent do
				model2 = model2:FindFirstChild(childName)
			end

			self.visuals[k] = Visuals.new(visual.id, model2)
		end

		function self.maid.visuals()
			for _, visual in self.visuals do
				Visuals.Destroy(visual)
			end
		end

		self.sounds = {}

		for k, sound in module.sounds do
			local model2

			if sound.parent then
				model2 = self.model

				for _, childName in sound.parent do
					model2 = model2:FindFirstChild(childName)
				end
			end

			self.sounds[k] = Sounds.new(sound.id, model2)
		end

		function self.maid.sounds()
			for _, visual in self.visuals do
				Sounds.Destroy(visual)
			end
		end

		ModelHelper.SetNetworkOwner(self.model, nil)
	else
		local _stats = self.stats
		local model = self.model
		local _ownerId = self.ownerId

		local animator = model:FindFirstChildWhichIsA("Animator", true)
		self.animations = Animations.new(module.animations, animator)
		self.overlapAnimations = Animations.new(module.overlapAnimations, animator)

		model.Parent = workspace.Contents.Pets
		self.maid = Maid.new()
	end

	functionsModule.onCreate(self)
end

function Pets.SetState(data, p: string?)
	if isServer then
		RemoteSignals.FireAllClients("Pets", "PetsSetState", data.id, p)
		return
	end

	local stateMaid = Maid.new()

	if p ~= "Follow" then
		data.maid.stateMaid = nil

		return
	end

	local number = Random.new():NextNumber(0.1, 0.3)
	PetHelpers.GetModule(data)

	stateMaid.followConnection = RunService.Heartbeat:Connect(function(_: number)
		local playerByUserId = data.ownerId and Players:GetPlayerByUserId((tonumber(data.ownerId)))
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (character and humanoidRootPart and data.model and data.model.PrimaryPart) then
			return
		end

		local v = humanoidRootPart.Position + data.offsetWorld

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character, data.model }

		local v2 = v + Vector3.new(0, 25, 0)
		local raycastResult = workspace:Raycast(v2, Vector3.new(0, -300, 0), raycastParams)

		if raycastResult then
			v = raycastResult.Position + Vector3.new(0, data.size.Y / 2, 0)
		end

		local v3

		if (Pets.GetCFrame(data).Position - v).Magnitude < 0.0001 then
			v3 = data.model.PrimaryPart.CFrame.LookVector
		else
			v3 = CFrame.new(Pets.GetCFrame(data).Position, v).LookVector
		end

		local cframe = CFrame.new(v, v + v3)
		Pets.SetCFrame(data, cframe, number, false)
	end)
	data.maid.stateMaid = stateMaid
end

function Pets:SetPositionOffset(offsetWorld: Vector3)
	self.offsetWorld = offsetWorld

	if isServer then
		RemoteSignals.FireAllClients("Pets", "PetsSetPositionOffset", self.id, offsetWorld)
	end
end

function Pets:SetCFrame(cframe: CFrame, value: number, flag: boolean)
	self.cframe = cframe

	if isServer then
		if flag then
			require(ServerScriptService.Libraries.Modules.Loaded)
			RemoteSignals.FireAllClients("Pets", "PetsSetCFrame", self.id, cframe, value, flag)
		end
	else
		ModelHelper:CFrame(self.model, cframe, TweenInfo.new(value or 0.1, Enum.EasingStyle.Linear))
	end
end

function Pets.GetCFrame(p)
	return p.cframe
end

function Pets:SetAnimation(animationSequence)
	self.animationSequence = animationSequence

	if isServer then
		RemoteSignals.FireAllClients("Pets", "PetsSetAnimation", self.id, animationSequence)
	elseif animationSequence then
		Animations.Play(self.animations, animationSequence)
	else
		Animations.Stop(self.animations)
	end
end

function Pets.GetOwner(p)
	return p.ownerId and Players:GetPlayerByUserId((tonumber(p.ownerId)))
end

function Pets.Indicator(p)
	local model = p.model
	local primaryPart = model and model.PrimaryPart

	if not (model and primaryPart and primaryPart:IsA("BasePart")) then
		return
	end

	local clone = Highlight:Clone()
	clone.FillTransparency = 0.5
	clone.OutlineTransparency = 0
	clone.Parent = model

	local total = 0

	TweenService:Create(clone, TweenInfo.new(0.2), { FillTransparency = 1, OutlineTransparency = 1 }):Play()

	local hitMaid = Maid.new()
	hitMaid.highlight = clone
	hitMaid.cleanUpConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total >= 0.2 then
			hitMaid:Destroy()
		end
	end)

	if tick() - lastTime > 0.1 then
		lastTime = tick()
		Sounds.SetPitch(ClientSounds.ZombieHit, Random.new():NextNumber(0.9, 1.1))
		Sounds.Play(ClientSounds.ZombieHit, nil, false)
	end

	p.maid.hitMaid = hitMaid
end

function Pets.TakeDamage(p, p2: number, userId: string)
	if p2 == 0 then
		warn("0 damage, no need to call the function")
		return
	end

	PetHelpers.GetModule(p)
	local rounded = NumberHelper:Round(p2, 0, true)

	if isServer then
		if not p.damageFrom[userId] then
			p.damageFrom[userId] = {}
		end

		Pets.SetValue(p, "lastHitData", { damage = rounded, userId = userId })
		Pets.SetValue(p, "health", p.health - rounded)
	end
end

function Pets:SetValue(p, p2)
	PetHelpers.GetModule(self)
	local v = self[p]
	self[p] = p2

	if isServer then
		RemoteSignals.FireAllClients("Pets", "PetsSetValue", self.id, p, p2)
	else
		local localPlayer = Players.LocalPlayer
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		tostring(localPlayer.UserId)
	end

	if p == "health" then
		local v2 = v - p2
		PetEvents.PetHit:Fire(self.id, v2)

		if not isServer then
			local nameUI = self.model and self.model:FindFirstChild("NameUI")
			local health = nameUI and nameUI:FindFirstChild("Health")

			assert(nameUI, "NameUI not found")
			assert(health, "HealthFrame not found")
			health.Visible = true
		end

		if self.health <= 0 then
			PetEvents.PetDied:Fire(self.id, v2)

			if isServer then
				Pets.Destroy(self)
			end
		end
	end
end

function Pets.IsDead(p): boolean
	local model = p.model
	local primaryPart = model and model.PrimaryPart

	if p.health <= 0 then
		return true
	end

	return not model or not model.PrimaryPart or not primaryPart or not primaryPart:IsA("BasePart")
end

function Pets.StopPathfinding(p)
	p.maid.pathConnection = nil
end

function Pets.Destroy(data)
	PetHelpers.GetModule(data)
	local functionsModule = PetHelpers.GetFunctionsModule(data)
	local model = data.model
	local primaryPart = model and model.PrimaryPart

	if primaryPart then
		local _cframe = primaryPart.CFrame
	end

	data.maid.threadId = nil
	data.maid.cleanUpScheduler = nil
	data.maid.cleanUpAttackThreadId = nil
	data.maid.fallOutConnection = nil

	PetEvents.PetDestroyed:Fire(data.id)
	functionsModule.onDestroy(data)
	table.remove(Pets._getPets(), Pets._getPetIndex(data))
	PetEvents.PetCleanUp:Fire(data.id)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("PetsDestroy", data.id)
		Loaded.RemoveQueue(data.loadId)
	end

	data.maid:Destroy()
end

return Pets