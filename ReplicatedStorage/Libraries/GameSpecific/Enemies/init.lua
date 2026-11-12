local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
require(script.EnemyTypes)
local EnemyConstants = require(script.EnemyConstants)
require(ReplicatedStorage.Libraries.Modules.Probability)
local EnemyHelpers = require(script.EnemyHelpers)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local EnemyEvents = require(script.EnemyEvents)
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local StateMachine = require(ReplicatedStorage.Libraries.Classes.StateMachine)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Collisions = require(ReplicatedStorage.Libraries.Modules.Collisions)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Knockback = require(ReplicatedStorage.Libraries.Modules.Knockback)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Level = require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local Paths = require(ReplicatedStorage.Libraries.Modules.Paths)
require(ReplicatedStorage.Libraries.Modules.Paths.PathTypes)
game:GetService("CollectionService")
game:GetService("ServerStorage")
require(ReplicatedStorage.Libraries.GameSpecific.AttackController.AttackControllerTypes)
local AttackController = require(ReplicatedStorage.Libraries.GameSpecific.AttackController)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
require(ReplicatedStorage.Types.GameSpecificTypes)
require(ReplicatedStorage.Libraries.Modules.Indicator)
local Roles = require(ReplicatedStorage.Libraries.GameSpecific.Roles)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local Modules = script.Modules
local Assets = ReplicatedStorage.Assets
local Highlight = Assets.Highlight
local BossHealthUI = Assets.UI.BossHealthUI
local BossHealth = Assets.UI.BossHealth

local Enemies = {}

local enemies = {}

local lastTime = tick()

local function _stripForClient(server)
	return {
		id = server.id,
		loadId = server.loadId,
		maid = nil,
		npc = server.npc,
		model = server.model,
		attackHitbox = server.attackHitbox,
		bodyHitbox = server.bodyHitbox,
		health = server.health,
		maxHealth = server.maxHealth,
		lastHitData = server.lastHitData,
		miscData = server.miscData
	}
end

function Enemies._getCommand(): string
	return "Enemies"
end

function Enemies._getEnemies()
	return enemies
end

function Enemies._getEnemyById(p: string)
	local enemies2 = Enemies._getEnemies()

	for _, enemy in enemies2 do
		if enemy.id == p then
			return enemy
		end
	end

	return nil
end

function Enemies._getEnemyByPart(p)
	local enemies2 = Enemies._getEnemies()

	for _, enemy in enemies2 do
		if not enemy.model then
			continue
		end

		local v = p

		while v ~= game do
			if v == enemy.model then
				return enemy
			end

			if not v.Parent then
				break
			end

			v = v.Parent
		end
	end

	return nil
end

function Enemies._getEnemyIndex(p)
	for enemyIndex, v in Enemies._getEnemies(), nil, nil do
		if v.id == p.id then
			return enemyIndex
		end
	end

	error(`Enemy with id {p.id} not found`)
end

function Enemies._getEnemyRootParts()
	local torsos = {}

	for _, v in Enemies._getEnemies(), nil, nil do
		if not v.bodyHitbox then
			continue
		end

		local torso = v.bodyHitbox:FindFirstChild("Torso")

		if torso and torso:IsA("Instance") then
			table.insert(torsos, torso)
		end
	end

	return torsos
end

function Enemies._getEnemyModels()
	local models = {}

	for _, v in Enemies._getEnemies(), nil, nil do
		if v.model then
			table.insert(models, v.model)
		end
	end

	return models
end

function Enemies.newServer(npc: string, cframe: CFrame, id: string)
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	local module = EnemyHelpers.GetModule({ npc = npc })

	local maxHealth = module.maxHealth

	local clone = module.instances[Random.new():NextInteger(1, #module.instances)]:Clone()
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	local humanoid = clone:FindFirstChildWhichIsA("Humanoid")

	local server = {
		id = id,
		loadId = "",
		maid = Maid.new(),
		npc = npc,
		model = clone,
		stateMachine = nil,
		health = maxHealth,
		maxHealth = maxHealth,
		alerted = not module.enemyConfiguration.alertRequirement,
		damageFrom = {},
		damageStateActive = false,
		damageCooldownReady = {},
		lastHitData = nil,
		path = Paths.new(module.enemyConfiguration.pathfinding.agentParameters, humanoidRootPart, humanoid),
		lastPathTime = 0,
		sounds = {},
		visuals = {},
		hitboxActive = {},
		miscData = {}
	}

	for _, part in clone:GetDescendants(), nil, nil do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanQuery = false
		part.CanTouch = false
		part.CanCollide = false
	end

	local clone2 = module.bodyHitbox:Clone()
	local humanoidRootPart2 = clone2:FindFirstChild("HumanoidRootPart")
	clone2:PivotTo(humanoidRootPart.CFrame)
	humanoidRootPart2:Destroy()

	for _, part in clone2:GetChildren(), nil, nil do
		if not part:IsA("BasePart") then
			continue
		end

		local part2 = clone:FindFirstChild(part.Name)

		if part2 then
			if part2:IsA("BasePart") then
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = part
				weldConstraint.Part1 = part2
				weldConstraint.Parent = part

				part.Massless = true
			end
		else
			warn("Didn't find a corresponding part for the " .. part.Name .. " body hitbox ")
		end
	end

	clone2.Parent = humanoidRootPart

	local clone3 = module.attackHitbox:Clone()
	local humanoidRootPart3 = clone3:FindFirstChild("HumanoidRootPart")
	clone3:PivotTo(humanoidRootPart.CFrame)
	humanoidRootPart3:Destroy()

	for _, part in clone3:GetChildren(), nil, nil do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanQuery = false
		part.Touched:Connect(function() end)

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = humanoidRootPart

		part.Massless = true
	end

	clone3.Parent = humanoidRootPart

	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	clone:PivotTo(cframe)
	clone.Parent = workspace.Contents.Enemies
	server.maid.model = clone
	server.attackHitbox = clone3
	server.maid.attackHitbox = clone3
	server.bodyHitbox = clone2
	server.maid.bodyHitbox = clone2
	Collisions:AddToGroup(clone, "Zombie")

	if EnemyConstants.PREVENT_GROUPING then
		local clone4 = Assets.EnemyAssets.Hitbox:Clone()
		local v = module.boundingBox.X - 1
		clone4.Size = Vector3.new(20, v, v)
		clone4:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966))
		clone4.WeldConstraint.Part1 = humanoidRootPart
		clone4.Parent = server.model
	end

	table.insert(Enemies._getEnemies(), server)
	Enemies.Init(server)

	server.loadId = Loaded.AddQueue(Enemies._getCommand(), Enemies._getCommand(), server.id, function()
		return _stripForClient(server)
	end)

	Loaded.FireAllClients(Enemies._getCommand(), Enemies._getCommand(), server.id, _stripForClient(server))

	return server
end

function Enemies.newClient(p)
	table.insert(Enemies._getEnemies(), p)
	Enemies.Init(p)

	return p
end

function Enemies:Init()
	local module = EnemyHelpers.GetModule(self)
	local functionsModule = EnemyHelpers.GetFunctionsModule(self)
	EnemyEvents.EnemyCreated:Fire(self.id)

	if isServer then
		local model = self.model
		local humanoid = model:FindFirstChildWhichIsA("Humanoid")
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
		local animator = model:FindFirstChildWhichIsA("Animator", true)

		local functionsModule2 = EnemyHelpers.GetFunctionsModule(self)

		self.animations = Animations.new(module.animations, animator)
		self.overlapAnimations = Animations.new(module.overlapAnimations, animator)

		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

		humanoid.WalkSpeed = module.walkSpeed

		if module.enemyConfiguration.alertRequirement and module.enemyConfiguration.alertRequirement.requiresTimer then
			task.spawn(function()
				task.wait(module.enemyConfiguration.alertRequirement.timerDuration)
				Enemies.SetValue(self, "alerted", true)
			end)
		end

		local stateMachine = StateMachine.new(self.id, "Enemy", humanoidRootPart.Position)

		stateMachine.newStateEvent.Event:Connect(function(p: string)
			if functionsModule2[`on{p}`] then
				functionsModule2[`on{p}`](self)
			end
		end)

		StateMachine.SetState(stateMachine, module.initialState)

		local v = Scheduler.BindHeartbeat(function(p: number)
			StateMachine.Update(stateMachine, p)
		end)
		function self.maid.cleanUpScheduler()
			Scheduler.UnbindHeartbeat(v)
		end

		self.stateMachine = stateMachine

		if module.enemyConfiguration.bulletSpray then
			local attackController = AttackController.new(self.id, module.enemyConfiguration.bulletSpray)
			self.attackController = attackController

			local v2 = Scheduler.BindHeartbeat(function(p: number)
				AttackController.Update(attackController, self, p)
			end)

			function self.maid.cleanUpAttackThreadId()
				Scheduler.UnbindHeartbeat(v2)
			end
		end

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

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {
			workspace.Contents.Bullets,
			workspace.Contents.Ragdolls,
			workspace.Contents.Enemies
		}

		local raycastResult = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -50, 0), raycastParams)

		if raycastResult then
			local distance = raycastResult.Distance
			model:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -distance + module.hipHeight, 0))
		end

		local attackHitbox = self.attackHitbox
		self.hitboxActive = {}

		for _, part in attackHitbox:GetChildren(), nil, nil do
			if not part:IsA("BasePart") then
				continue
			end

			self.hitboxActive[part.Name] = {}

			part.Touched:Connect(function(otherPart)
				local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)
				local userId = playerFromCharacter and tostring(playerFromCharacter.UserId)

				if userId and not table.find(self.hitboxActive[part.Name], userId) then
					table.insert(self.hitboxActive[part.Name], userId)
				end
			end)

			part.TouchEnded:Connect(function(otherPart)
				local parent = otherPart.Parent
				local playerFromCharacter = parent and Players:GetPlayerFromCharacter(parent)
				local userId = playerFromCharacter and tostring(playerFromCharacter.UserId)

				local index = userId and table.find(self.hitboxActive[part.Name], userId)

				if index then
					table.remove(self.hitboxActive[part.Name], index)
				end
			end)
		end
	else
		self.maid = Maid.new()

		if module.class == "Boss" then
			local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

			if EnemyConstants.BILLBOARD_BOSS_HEALTH then
				local clone = BossHealthUI:Clone()
				clone.Parent = self.model
				self.maid.bossHealthUI = clone
			end

			if EnemyConstants.SCREEN_BOSS_HEALTH then
				local mainUI = playerGui:WaitForChild("MainUI")
				local clone = BossHealth:Clone()
				clone.Parent = mainUI:WaitForChild("HealthLabels")
				self.maid.bossHealthScreenUI = clone
			end
		end
	end

	functionsModule.onCreate(self)

	if not isServer then
		Enemies.UpdateHealthUI(self)
	end
end

function Enemies.Knockback(p, p2, vector3: Vector3)
	local module = EnemyHelpers.GetModule(p)
	local model = p.model
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")

	if not (model and humanoidRootPart and humanoidRootPart:IsA("BasePart") and module.canKnockback) then
		return
	end

	local v = p2.distance
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = Enemies._getEnemyModels()

	local raycastResult = workspace:Raycast(humanoidRootPart.Position, vector3 * p2.distance, raycastParams)

	if raycastResult then
		v = math.clamp(raycastResult.Distance, 0, p2.distance)
	end

	ModelHelper:CFrame(model, humanoidRootPart.CFrame + vector3 * v, TweenInfo.new(v / p2.speed))
end

function Enemies.Indicator(p, _: number)
	local model = p.model
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")

	if not (model and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
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

function Enemies.TakeDamage(data, p: number, userId: string, p2)
	if p == 0 then
		warn("0 damage, no need to call the function")
		return
	end

	local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)

	Tools._getEquippedFromOwnerId(userId)
	local module = EnemyHelpers.GetModule(data)
	local roleModule = Roles.GetRoleModule(userId)
	local playerReplica = Profiles.GetPlayerReplica(userId)

	if not (playerReplica and playerReplica:IsActive()) then
		return
	end

	local v = playerReplica.Data.mastery[p2] or 0
	local damage = NumberHelper:Round(
		(roleModule.onDealDamage(userId, p2, p) or p) * (1 + Level:GetLevel(v, "MASTERY_EQUATION") * 0.01),
		0,
		true
	) * (1 + Level:GetLevel(playerReplica.Data.mastery[p2] or 0, "MASTERY_EQUATION") * 0.01)

	if isServer then
		if not data.damageFrom[userId] then
			data.damageFrom[userId] = {}
		end

		if not data.damageFrom[userId][p2] then
			data.damageFrom[userId][p2] = 0
		end

		data.damageFrom[userId][p2] += math.clamp(damage, 0, data.maxHealth)

		if module.enemyConfiguration.alertRequirement and module.enemyConfiguration.alertRequirement.requiresDamage then
			Enemies.SetValue(data, "alerted", true)
		end

		local position = data.model.PrimaryPart.Position
		RemoteSignals.FireAllClients(RemoteEnums.Indicator, damage, position)
		Enemies.SetValue(data, "lastHitData", { damage = damage, userId = userId })
		Enemies.SetValue(data, "health", data.health - damage)
	end
end

function Enemies.Attack(data, p: string, flag: boolean)
	local model = data.model
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")
	local functionsModule = EnemyHelpers.GetFunctionsModule(data)

	if not (model and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local module = EnemyHelpers.GetModule(data)
	local attackHitbox = data.maid.attackHitbox

	if not attackHitbox then
		return
	end

	if data.visuals.attack then
		Visuals.Play(data.visuals.attack, nil, false)
	end

	if data.sounds.attack then
		Sounds.Play(data.sounds.attack, nil, false)
	end

	if functionsModule.onAttack then
		functionsModule.onAttack(data)
	end

	local playerFromCharacters = {}

	local function checkAndDealDamage()
		for _, child in attackHitbox:GetChildren(), nil, nil do
			if child.Name ~= p then
				continue
			end

			local touchingParts = child:GetTouchingParts()

			for _, touchingPart in touchingParts do
				local parent = touchingPart and touchingPart.Parent
				local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
				local userId = playerFromCharacter and tostring(playerFromCharacter.UserId)

				if not parent or not playerFromCharacter or table.find(playerFromCharacters, playerFromCharacter) then
					continue
				end

				local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")
				local humanoid = parent:FindFirstChildWhichIsA("Humanoid")
				local health = HealthHandler.GetHealth(userId)
				local maxHealth = HealthHandler.GetMaxHealth(userId)

				if not humanoidRootPart2 or not humanoid or health <= 0 then
					continue
				end

				table.insert(playerFromCharacters, playerFromCharacter)

				local stateMachine = data.stateMachine
				local name = stateMachine and stateMachine.currentState and stateMachine.currentState.name
				local v = nil

				if name == "Attack" then
					v = module.enemyConfiguration.attackState
				elseif name == "Charge" then
					v = module.enemyConfiguration.chargeState
				end

				if not v then
					continue
				end

				local v2 = health / maxHealth
				local damage = TableHelper:DeepCopy(v).damage

				if v2 < 0.5 then
					damage *= 0.8
				end

				local v3 = math.clamp(damage * (math.clamp(#Players:GetPlayers() / 1.8, 1, 1e999) * 1), 0, 22)

				HealthHandler.TakeDamage(userId, v3)
				local speed = v.knockbackInfo.speed

				local function origin()
					return humanoidRootPart2.CFrame
				end

				Knockback:Recoil(
					playerFromCharacter,
					origin,
					v.knockbackInfo.distance,
					speed,
					CFrame.new(
						humanoidRootPart.Position,
						NumberHelper:SetVector3(humanoidRootPart2.Position, humanoidRootPart.Position.Y)
					).LookVector,
					{}
				)
			end
		end
	end

	if not flag then
		checkAndDealDamage()

		return
	end

	local total = 0

	data.maid.attackConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total >= 0.05 then
			total = 0
			checkAndDealDamage()
		end
	end)
end

function Enemies.StopAttack(p)
	p.maid.attackConnection = nil
end

function Enemies:SetValue(p, p2)
	EnemyHelpers.GetModule(self)
	local v = self[p]
	self[p] = p2

	if isServer then
		RemoteSignals.FireAllClients("Enemies", "EnemiesSetValue", self.id, p, p2)

		if p == "health" then
			local v2 = v - p2
			EnemyEvents.EnemyHit:Fire(self.id, v2)

			if self.health <= 0 then
				EnemyEvents.EnemyDied:Fire(self.id, v2)
				Enemies.Destroy(self)
			end
		end
	else
		local localPlayer = Players.LocalPlayer
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		tostring(localPlayer.UserId)

		if p == "health" then
			local v2 = v - p2

			Enemies.UpdateHealthUI(self)
			EnemyEvents.EnemyHit:Fire(self.id, v2)

			if self.health <= 0 then
				EnemyEvents.EnemyDied:Fire(self.id, v2)
			end
		end
	end
end

function Enemies.UpdateHealthUI(data)
	local module = EnemyHelpers.GetModule(data)
	local functionsModule = EnemyHelpers.GetFunctionsModule(data)
	local v = math.clamp(data.health, 0, data.maxHealth) / data.maxHealth

	if isServer then
		return
	end

	if module.class == "Boss" then
		if data.maid.bossHealthUI then
			data.maid.bossHealthUI.BossHealth.Health.Health.Text = math.floor((math.clamp(data.health, 0, data.maxHealth))) .. "HP"
			data.maid.bossHealthUI.BossHealth.Label.Text = string.upper(module.id)
			data.maid.bossHealthUI.BossHealth.Health.Percent.Size = UDim2.new(v, 0, 1, 0)
			data.maid.bossHealthUI.BossHealth.Health.Percent.Display.Size = UDim2.new(1 / v, 0, 1, 0)

			data.maid.bossHealthUI.BossHealth.LineRight.Position = UDim2.new(
				0.5,
				data.maid.bossHealthUI.BossHealth.Label.TextBounds.X / 2 + data.maid.bossHealthUI.BossHealth.LineRight.AbsoluteSize.X / 2 + 9,
				0.25,
				0
			)

			data.maid.bossHealthUI.BossHealth.LineLeft.Position = UDim2.new(
				0.5,
				-data.maid.bossHealthUI.BossHealth.Label.TextBounds.X / 2 - data.maid.bossHealthUI.BossHealth.LineRight.AbsoluteSize.X / 2 - 9,
				0.25,
				0
			)
		end

		if data.maid.bossHealthScreenUI then
			data.maid.bossHealthScreenUI.Health.Health.Text = math.floor((math.clamp(data.health, 0, data.maxHealth))) .. "HP"
			data.maid.bossHealthScreenUI.Label.Text = string.upper(module.id)
			data.maid.bossHealthScreenUI.Health.Percent.Size = UDim2.new(v, 0, 1, 0)
			data.maid.bossHealthScreenUI.Health.Percent.Display.Size = UDim2.new(1 / v, 0, 1, 0)

			data.maid.bossHealthScreenUI.LineRight.Position = UDim2.new(
				0.5,
				data.maid.bossHealthScreenUI.Label.TextBounds.X / 2 + data.maid.bossHealthScreenUI.LineRight.AbsoluteSize.X / 2 + 9,
				0.25,
				0
			)

			data.maid.bossHealthScreenUI.LineLeft.Position = UDim2.new(
				0.5,
				-data.maid.bossHealthScreenUI.Label.TextBounds.X / 2 - data.maid.bossHealthScreenUI.LineRight.AbsoluteSize.X / 2 - 9,
				0.25,
				0
			)
		end
	end

	if functionsModule.onUpdateHealthUI then
		functionsModule.onUpdateHealthUI(data)
	end
end

function Enemies:StartPathfinding(vector3: Vector3)
	local model = self.model
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")
	local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
	local module = EnemyHelpers.GetModule(self)

	if
		not model
		or not humanoidRootPart
		or not humanoid
		or tick() - self.lastPathTime < module.enemyConfiguration.pathfinding.rate
	then
		return
	end

	self.lastPathTime = tick()

	task.spawn(function()
		local v = humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2, 0)

		if Paths.CreatePathYield(self.path, v, vector3) then
			Paths.StartFollowing(self.path)
		end
	end)
end

function Enemies.StopPathfinding(p)
	Paths.StopFollowing(p.path)
end

function Enemies.Destroy(data)
	local functionsModule = EnemyHelpers.GetFunctionsModule(data)
	EnemyHelpers.GetModule(data)

	functionsModule.onDestroy(data)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("Enemies", "EnemiesDestroy", data.id)
		Loaded.RemoveQueue(data.loadId)

		StateMachine.Destroy(data.stateMachine)
	end

	EnemyEvents.EnemyDestroyed:Fire(data.id)
	table.remove(Enemies._getEnemies(), Enemies._getEnemyIndex(data))
	EnemyEvents.EnemyCleanUp:Fire(data.id)

	data.maid.threadId = nil
	data.maid.cleanUpScheduler = nil
	data.maid.cleanUpAttackThreadId = nil
	data.maid.fallOutConnection = nil
	data.maid:Destroy()
end

return Enemies