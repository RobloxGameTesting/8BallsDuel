local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(script.ToolTypes)
local WeaponConstants = require(script.WeaponConstants)
require(ReplicatedStorage.Libraries.Modules.Probability)
local WeaponHelpers = require(script.WeaponHelpers)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local WeaponEvents = require(script.WeaponEvents)
require(script.WeaponAttacks)
require(ReplicatedStorage.Libraries.Modules.Scheduler)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Collisions = require(ReplicatedStorage.Libraries.Modules.Collisions)
local Mouses = require(ReplicatedStorage.Libraries.Classes.Mouses)
local CameraShaker = require(ReplicatedStorage.Libraries.Classes.CameraShaker)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Modules.Knockback)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local ShapecastHitbox = require(ReplicatedStorage.Libraries.Classes.ShapecastHitbox)
local CameraHelper = require(ReplicatedStorage.Libraries.Helpers.CameraHelper)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local MobileHelper = require(ReplicatedStorage.Libraries.Helpers.MobileHelper)
require(ReplicatedStorage.Types.NotificationTypes)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
require(ReplicatedStorage.Libraries.Modules.MechanicHandler)
require(ReplicatedStorage.Libraries.Modules.Level)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)

local CurrentCamera = workspace.CurrentCamera
local isServer = RunService:IsServer()
local Modules = script.Modules

local Tools = {}

local weapons = {}

local count = 0

local function _stripForClient(server)
	return {
		id = server.id,
		loadId = server.loadId,
		maid = nil,
		weaponType = server.weaponType,
		owner = server.owner,
		ownerId = server.ownerId,
		tool = server.tool,
		ammo = server.ammo,
		maxAmmo = server.maxAmmo,
		totalAmmo = server.totalAmmo,
		shootIndex = server.shootIndex,
		equipped = server.equipped,
		activated = server.activated,
		rightActivated = server.rightActivated,
		destroyed = server.destroyed,
		extraData = server.extraData
	}
end

local function _changeSVFXParent(data)
	local module = WeaponHelpers.GetModule(data)
	local isFirstPerson = data.isFirstPerson
	local viewmodel = isFirstPerson and data.viewmodel or data.tool
	local v = isFirstPerson and "viewmodelParent" or "parent"

	for k, sound in data.sounds do
		local child

		if module.sounds[k][v] then
			child = viewmodel

			for _, childName in module.sounds[k][v] do
				child = child:FindFirstChild(childName)
			end
		end

		Sounds.Parent(sound, child)
	end

	for k, visual in data.visuals do
		local child

		if module.visuals[k][v] then
			child = viewmodel

			for _, childName in module.visuals[k][v] do
				child = child:FindFirstChild(childName)
			end
		end

		Visuals.Parent(visual, child)
	end
end

function Tools._getCommand(): string
	return "Tools"
end

function Tools._getWeapons()
	return weapons
end

function Tools._getWeaponById(p: string)
	local weapons2 = Tools._getWeapons()

	for _, weapon in weapons2 do
		if weapon.id == p then
			return weapon
		end
	end

	return nil
end

function Tools._getWeaponByToolType(p: string)
	local weapons2 = Tools._getWeapons()

	for _, weapon in weapons2 do
		if WeaponHelpers.GetModule({ weaponType = weapon.weaponType }).toolType == p and weapon.isOwner then
			return weapon
		end
	end

	return nil
end

function Tools._getWeaponIndex(p)
	for weaponIndex, v in Tools._getWeapons(), nil, nil do
		if v.id == p.id then
			return weaponIndex
		end
	end

	error(`Enemy with id {p.id} not found`)
end

function Tools._getWeaponsByOwnerId(p: string)
	local weapons2 = {}

	for _, v in Tools._getWeapons(), nil, nil do
		if v.ownerId == p then
			table.insert(weapons2, v)
		end
	end

	return weapons2
end

function Tools._getEquippedFromOwnerId(p: string)
	for _, v in Tools._getWeapons(), nil, nil do
		if v.ownerId == p and v.equipped then
			return v
		end
	end

	return nil
end

function Tools._fireAllButOwner(p, p2: string, p3: string, ...)
	if isServer then
		local userId = p and tostring(p.UserId)

		for _, v in Players:GetPlayers(), nil, nil do
			if tostring(v.UserId) ~= userId then
				RemoteSignals.FireClient(v, "Tools", p2, p3, ...)
			end
		end
	end
end

function Tools.newServer(owner, weaponType: string)
	local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

	count += 1

	local module = WeaponHelpers.GetModule({ weaponType = weaponType })
	local server = {
		id = tostring(count),
		loadId = "",
		maid = Maid.new(),
		weaponType = weaponType,
		owner = owner,
		ownerId = tostring(owner.UserId),
		tool = nil,
		viewmodel = nil,
		reloading = false,
		ammo = module.ammo,
		maxAmmo = module.ammo,
		totalAmmo = module.totalAmmo,
		shootIndex = 1,
		verifiedShoot = 0,
		equipped = false,
		activated = false,
		rightActivated = false,
		destroyed = false,
		firing = false,
		extraData = {}
	}

	Tools.Init(server)
	table.insert(Tools._getWeapons(), server)
	WeaponEvents.WeaponNew:Fire(server.id)

	server.loadId = Loaded.AddQueue(Tools._getCommand(), Tools._getCommand(), server.id, function()
		return _stripForClient(server)
	end)

	Loaded.FireAllClients(Tools._getCommand(), Tools._getCommand(), server.id, _stripForClient(server))

	return server
end

function Tools:newClient()
	self.maid = Maid.new()
	self.isFirstPerson = false

	Tools.Init(self)
	table.insert(Tools._getWeapons(), self)
	WeaponEvents.WeaponNew:Fire(self.id)

	return self
end

function Tools:Init()
	local module = WeaponHelpers.GetModule(self)

	if isServer then
		local function createTool()
			local clone = module.instance:Clone()
			clone.Name = module.toolType
			clone.Parent = self.owner.Backpack
			Tools.SetValue(self, "tool", clone, {}, true)
			self.maid.model = clone
		end

		createTool()
		self.maid.respawnConnection = self.owner.CharacterAdded:Connect(createTool)
	else
		local localPlayer = Players.LocalPlayer
		local userId = tostring(localPlayer.UserId)
		local animator = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid"):WaitForChild("Animator")

		self.isOwner = self.ownerId == userId
		local mouse = Mouses.new()
		Mouses.AddList(mouse, "Blacklist", workspace.Contents.Ignore)
		self.mouse = mouse
		self.timeNeeded = 0
		self.timeElapsed = 1e999

		Tools.InitTool(self)

		if self.isOwner then
			local cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(cframe: CFrame)
				CurrentCamera.CFrame *= cframe
			end)

			if module.viewModel then
				local clone = module.viewModel:Clone()
				local leftArm = clone:FindFirstChild("Left Arm")
				local rightArm = clone:FindFirstChild("Right Arm")
				local _primaryPart = clone.PrimaryPart

				local animator2 = clone:FindFirstChildWhichIsA("Humanoid"):FindFirstChildWhichIsA("Animator")

				local character = self.owner.Character or self.owner.CharacterAdded:Wait()
				local shirt = character and character:FindFirstChild("Shirt")
				local bodyColors = character and character:FindFirstChildWhichIsA("BodyColors")

				if shirt then
					local clone_2 = shirt:Clone()
					clone_2.Parent = clone
				end

				if bodyColors then
					leftArm.Color = bodyColors.LeftArmColor3
					rightArm.Color = bodyColors.RightArmColor3
				end

				Collisions:AddToGroup(clone, "Viewmodel")
				clone.Name = module.toolType
				clone.Parent = self.owner.Backpack
				Tools.SetValue(self, "viewmodel", clone, {}, true)
				self.maid.viewmodel = clone
				self.viewmodelAnimations = Animations.new(module.viewModelAnimations, animator2)
				Animations.Play(self.viewmodelAnimations, {
					{ animation = "idle", looped = true }
				})

				local function updateTransparency()
					local isFirstPerson = self.isFirstPerson

					ModelHelper.SetLocalTransparencyModifier(clone, isFirstPerson and 0 or 1)
					ModelHelper.SetLocalTransparencyModifier(self.tool, isFirstPerson and 1 or 0)

					_changeSVFXParent(self)

					local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)

					if isFirstPerson then
						Mouselock:Disable()
					else
						Mouselock:Enable()
					end
				end

				updateTransparency()
				self.maid.firstPersonEventConnection = WeaponEvents.WeaponFirstPerson.Event:Connect(updateTransparency)

				self.maid.viewmodelConnection = RunService.RenderStepped:Connect(function(_)
					local isFirstPerson = CameraHelper.IsFirstPerson()

					if isFirstPerson ~= self.isFirstPerson then
						self.isFirstPerson = isFirstPerson
						WeaponEvents.WeaponFirstPerson:Fire(isFirstPerson)
					end

					if self.isFirstPerson and self.equipped and self.viewmodel then
						local cframe = CurrentCamera.CFrame

						if
							CurrentCamera.CameraType == Enum.CameraType.Custom
							or CurrentCamera.CameraType == Enum.CameraType.Track
						then
							clone:PivotTo(cframe)
						end
					end
				end)
			end

			self.cameraShaker = cameraShaker
			self.animations = Animations.new(module.animations, animator)
		end

		Mouses.AddList(mouse, "Blacklist", workspace.Contents.Ragdolls)
		Mouses.AddList(mouse, "Blacklist", workspace.Contents.Bullets)

		local function addPlayer(player)
			local userId2 = tostring(player.UserId)
			local character = player.Character or player.CharacterAdded:Wait()
			Mouses.AddList(mouse, "Blacklist", character)

			self.maid[`{userId2}addedConnection`] = player.CharacterAdded:Connect(function(character2)
				if self.isOwner and player == self.owner then
					Tools.Unequip(self)
				end

				Mouses.AddList(mouse, "Blacklist", character2)
			end)
		end

		self.maid.respawnConnection = Players.PlayerAdded:Connect(addPlayer)

		for _, v in Players:GetPlayers(), nil, nil do
			addPlayer(v)
		end
	end
end

function Tools:InitTool()
	if not self.tool or isServer then
		return
	end

	local module = WeaponHelpers.GetModule({ weaponType = self.weaponType })

	self.visuals = {}
	function self.maid.visuals()
		for _, visual in self.visuals do
			Visuals.Destroy(visual)
		end
	end

	for k, visual in module.visuals do
		local tool = self.tool

		for _, childName in visual.parent do
			tool = tool:FindFirstChild(childName)
		end

		self.visuals[k] = Visuals.new(visual.id, tool)
	end

	self.sounds = {}
	function self.maid.sounds()
		for _, sound in self.sounds do
			Sounds.Destroy(sound)
		end
	end

	for k, sound in module.sounds do
		local tool

		if sound.parent then
			tool = self.tool

			for _, childName in sound.parent do
				tool = tool:FindFirstChild(childName)
			end
		end

		self.sounds[k] = Sounds.new(sound.id, tool)
	end
end

function Tools.SetCooldown(p)
	local cooldown = WeaponHelpers.GetModule(p).spray[p.shootIndex].cooldown
	Tools.SetValue(p, "timeNeeded", cooldown, { p.owner }, false)
end

function Tools.Reload(data)
	local module = WeaponHelpers.GetModule(data)
	local functionsModule = WeaponHelpers.GetFunctionsModule(data)

	if isServer then
		local _pattern = module.spray[data.shootIndex].pattern

		Tools._fireAllButOwner(data.owner, "ToolsReload", data.id)
	elseif data.isOwner then
		if not data.equipped then
			warn("Can't reload because not equipped")
			return
		end

		if data.reloading then
			warn("Can't reload because already reloading")
			return
		end

		if data.ammo == 1e999 then
			warn("Can't reload because this is an inf ammo weapon")
			return
		end

		if data.ammo == data.maxAmmo then
			warn("Can't reload because full ammo")
			return
		end

		if data.totalAmmo <= 0 then
			Notifications.new("TextNotification", {
				message = "<font color=\"#FFFFFF\">No ammo!</font>",
				parent = "TopNotifications",
				audio = { "Restock" }
			})
			return
		end

		RemoteSignals.FireServer("Tools", "ToolsReload", data.id)
		Tools.SetValue(data, "reloading", true, { data.owner }, false)

		Tools.Deactivate(data)
		functionsModule.onReload(data)

		if module.reloadTime then
			Tools.ReloadTimer(data, module.reloadTime)
		end
	else
		functionsModule.onReload(data)
	end
end

function Tools.ReloadTimer(data, p: number)
	local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)
	WeaponHelpers.GetModule(data)

	local total = 0

	data.maid.reloadTimerConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		local v = math.clamp(total / p, 0.01, 1)

		if data.equipped then
			Crosshair.UpdateReload(data, v)
		end

		WeaponEvents.ReloadProgress:Fire(data.id, v)

		if p <= total then
			data.maid.reloadTimerConnection = nil
			WeaponEvents.WeaponCompleteReloadEvent:Fire(data.id)
		end
	end)
end

function Tools:SetValue(p: string, p2, list, flag: boolean)
	WeaponHelpers.GetModule(self)

	if isServer then
		local _ = self[p]
		self[p] = p2

		if p == "tool" then
			Tools.InitTool(self)
		end

		for _, v in Players:GetPlayers(), nil, nil do
			if not table.find(list, v) then
				RemoteSignals.FireClient(v, "Tools", "ToolsSetValue", self.id, p, p2, list, flag)
			end
		end
	else
		require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)

		local _ = self[p]
		self[p] = p2

		local localPlayer = Players.LocalPlayer
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		tostring(localPlayer.UserId)

		if p == "tool" then
			Tools.InitTool(self)
		elseif p == "ammo" then
			WeaponEvents.WeaponAmmoEvent:Fire(self.id)
		end

		if self.isOwner and not flag then
			RemoteSignals.FireServer("Tools", "ToolsSetValue", self.id, p, p2, list, flag)
		end
	end
end

local function sharedSetUp(data)
	local character = data.owner.Character

	if not character then
		return
	end

	for k, v in WeaponHelpers.GetModule({ weaponType = data.weaponType }).grip do
		local part0 = v.Part0
		local part1 = v.Part1
		local c1 = v.C1 or CFrame.new()
		local c0 = v.C0 or CFrame.new()

		local toolGrip = Instance.new("Motor6D")
		toolGrip.Name = "ToolGrip"
		toolGrip.C1 = c1
		toolGrip.C0 = c0
		toolGrip.Part1 = data.tool:FindFirstChild(part1, true)
		toolGrip.Part0 = character:FindFirstChild(part0)
		toolGrip.Parent = character:FindFirstChild(part0)

		data.maid.equipMaid[`motor6D{k}`] = toolGrip
	end

	data.tool.Parent = data.owner.Character
end

function Tools:Equip()
	if not (self.owner.Character and self.tool) then
		return
	end

	local module = WeaponHelpers.GetModule(self)
	local functionsModule = WeaponHelpers.GetFunctionsModule(self)
	local equipMaid = Maid.new()
	self.maid.equipMaid = equipMaid

	if isServer then
		self.equipped = true

		sharedSetUp(self)
		Tools._fireAllButOwner(self.owner, "ToolsEquip", self.id)
	else
		if self.isOwner then
			if HealthHandler.IsDowned(self.ownerId) then
				return
			end

			local weaponsByOwnerId = Tools._getWeaponsByOwnerId(self.ownerId)

			for _, weapon in weaponsByOwnerId do
				if weapon.equipped then
					Tools.Unequip(weapon)
				end
			end

			if self.viewmodel then
				self.viewmodel.Parent = CurrentCamera
			end

			sharedSetUp(self)

			equipMaid.shootConnection = RunService.Heartbeat:Connect(function(dt)
				if not self.equipped then
					return
				end

				self.timeElapsed += dt

				if self.reloading then
					return
				end

				if self.ammo <= 0 then
					if self.totalAmmo > 0 then
						Tools.Reload(self)
					elseif self.totalAmmo <= 0 then
						Tools.Deactivate(self)
					end
				elseif self.timeElapsed >= self.timeNeeded and self.firing then
					self.timeElapsed = 0

					Tools.Attack(self)
				end
			end)

			self.maid.reloadListenConnection = WeaponEvents.WeaponCompleteReloadEvent.Event:Connect(function(p)
				if p == self.id then
					local v = math.clamp(self.maxAmmo - self.ammo, 0, self.totalAmmo)
					Tools.SetValue(self, "totalAmmo", self.totalAmmo - v, { self.owner }, false)
					Tools.SetValue(self, "ammo", self.ammo + v, { self.owner }, false)
					Tools.SetValue(self, "reloading", false, { self.owner }, false)
					WeaponHelpers.GetFunctionsModule(self).onReloadComplete(self)

					if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						Tools.Activate(self)
					end
				end
			end)

			if module.toolType == "Melee" then
				local character = self.owner.Character or self.owner.CharacterAdded:Wait()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { character }
				local v = ShapecastHitbox.new(self.tool, raycastParams)
				function equipMaid.raycastHitbox()
					v:Destroy()
				end
				self.raycastHitbox = v

				if self.viewmodel then
					local viewmodelRaycastHitbox = ShapecastHitbox.new(self.viewmodel, raycastParams)

					function equipMaid.viewmodelRaycastHitbox()
						viewmodelRaycastHitbox:Destroy()
					end

					self.viewmodelRaycastHitbox = viewmodelRaycastHitbox
				else
					self.viewmodelRaycastHitbox = v
				end
			end

			Tools.SetCooldown(self)

			if Device:Get() == "Desktop" then
				equipMaid.reloadConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end

					local playerReplica = Profiles.GetPlayerReplica(self.ownerId)

					if not playerReplica then
						return
					end

					if input.KeyCode.Value == playerReplica.Data.configuration.desktopKeybinds.buttons.reload then
						Tools.Reload(self)
					end
				end)

				equipMaid.activatedConnection = self.mouse.Activated:Connect(function(p)
					if p then
						return
					end

					Tools.Activate(self)
				end)

				equipMaid.deactivatedConnection = self.mouse.Deactivated:Connect(function()
					Tools.Deactivate(self)
				end)
			elseif Device:Get() == "Console" or UserInputService.GamepadEnabled then
				local v = false

				equipMaid.reloadConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end

					local playerReplica = Profiles.GetPlayerReplica(self.ownerId)

					if not playerReplica then
						return
					end

					if input.KeyCode.Value == playerReplica.Data.configuration.consoleKeybinds.buttons.reload then
						Tools.Reload(self)
					end
				end)

				equipMaid.activatedConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end

					if input.KeyCode == Enum.KeyCode.ButtonR2 then
						v = true
						Tools.Activate(self)
					end
				end)

				equipMaid.deactivatedConnection = UserInputService.InputEnded:Connect(function(input, _)
					if input.KeyCode == Enum.KeyCode.ButtonR2 then
						v = false
						Tools.Deactivate(self)
					end
				end)

				local lastTime = nil

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if self.owner.Character then
					raycastParams.FilterDescendantsInstances = { self.owner.Character }
				end

				equipMaid.autoShootConnection = RunService.Heartbeat:Connect(function()
					local cframe = CurrentCamera.CFrame
					local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * 200, raycastParams)
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
							Tools.Activate(self)
						elseif not v and lastTime and tick() - lastTime >= 0 then
							Tools.Deactivate(self)
						end
					end
				end)
			elseif Device:Get() == "Mobile" then
				local shoot = MobileHelper:WaitForButton("shoot")
				local reload = MobileHelper:WaitForButton("reload")

				shoot:SetVisible(true)
				reload:SetVisible(true)

				equipMaid.activatedConnection = shoot.Activated:Connect(function()
					Tools.Activate(self)
					shoot:Press()
				end)

				equipMaid.deactivatedConnection = shoot.Deactivated:Connect(function()
					Tools.Deactivate(self)
					shoot:Release()
				end)

				equipMaid.reloadConnection = reload.Activated:Connect(function()
					Tools.Reload(self)
					reload:Press()
				end)

				equipMaid.reloadConnectionRelease = reload.Deactivated:Connect(function()
					reload:Release()
				end)
			end

			functionsModule.onEquip(self)
			RemoteSignals.FireServer("Tools", "ToolsEquip", self.id)
		else
			functionsModule.onEquip(self)
		end

		self.equipped = true
		WeaponEvents.WeaponEquipped:Fire(self.id)
	end
end

function Tools:Unequip()
	self.maid.equipMaid = nil

	if isServer then
		self.equipped = false

		if self.tool then
			self.tool.Parent = self.owner.Backpack
		end

		Tools._fireAllButOwner(self.owner, "ToolsUnequip", self.id)
	else
		local functionsModule = WeaponHelpers.GetFunctionsModule({ weaponType = self.weaponType })

		self.equipped = false
		self.activated = false

		if not self.isOwner then
			functionsModule.onUnequip(self)

			return
		end

		Tools.SetValue(self, "shootIndex", 1, { self.owner }, false)
		Tools.SetCooldown(self)

		WeaponEvents.WeaponUnequipped:Fire(self.id)
		functionsModule.onUnequip(self)

		if self.viewmodel then
			self.viewmodel.Parent = self.owner.Backpack
		end

		if self.tool then
			self.tool.Parent = self.owner.Backpack
		end

		RemoteSignals.FireServer("Tools", "ToolsUnequip", self.id)
	end
end

function Tools.Toggle(p)
	if isServer then
		return
	end

	if p.equipped then
		Tools.Unequip(p)
	else
		Tools.Equip(p)
	end
end

function Tools.Attack(data)
	WeaponHelpers.GetModule(data)
	local functionsModule = WeaponHelpers.GetFunctionsModule(data)

	if isServer then
		functionsModule.onShootRequest(data)
		Tools._fireAllButOwner(data.owner, "ToolsAttack", data.id)
	elseif data.isOwner then
		functionsModule.onShootRequest(data)
		RemoteSignals.FireServer("Tools", "ToolsAttack", data.id)
	end
end

function Tools:Activate()
	if isServer then
		Tools._fireAllButOwner(self.owner, "ToolsActivate", self.id)
		return
	end

	local functionsModule = WeaponHelpers.GetFunctionsModule(self)

	if self.isOwner then
		if not self.equipped or self.reloading or self.activated then
			return
		end

		local character = self.owner.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (character and humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		if self.ammo == 0 and self.totalAmmo == 0 then
			Notifications.new("TextNotification", {
				message = "<font color=\"#FFFFFF\">No ammo!</font>",
				parent = "TopNotifications",
				audio = { "Restock" }
			})
			return
		end

		if WeaponConstants.AUTO_ROTATE_ON_EQUIP then
			CharacterHelper.AutoRotate(true, self.mouse)
		end

		functionsModule.onActivated(self)
		self.activated = true
		RemoteSignals.FireServer("Tools", "ToolsActivate", self.id)
	else
		functionsModule.onActivated(self)
		self.activated = true
	end
end

function Tools:Deactivate()
	if isServer then
		Tools._fireAllButOwner(self.owner, "ToolsDeactivate", self.id)
		return
	end

	local functionsModule = WeaponHelpers.GetFunctionsModule(self)

	if self.isOwner then
		if not self.activated then
			return
		end

		if not WeaponConstants.AUTO_ROTATE_ON_EQUIP and Device:Get() ~= "Mobile" and Device:Get() == "Desktop" then
			CharacterHelper.StopAutoRotate(4)
		end

		functionsModule.onDeactivated(self)
		self.activated = false
		RemoteSignals.FireServer("Tools", "ToolsDeactivate", self.id)
	else
		functionsModule.onDeactivated(self)
		self.activated = false
	end
end

function Tools:Firing(firing: boolean)
	if self.firing == firing then
		return
	end

	if isServer then
		self.firing = firing
		Tools._fireAllButOwner(self.owner, "ToolsFiring", self.id, self.firing)
	else
		local functionsModule = WeaponHelpers.GetFunctionsModule({ weaponType = self.weaponType })

		self.firing = firing

		if self.firing then
			functionsModule.onFire(self)
		else
			functionsModule.onStopFire(self)
		end

		if self.isOwner then
			RemoteSignals.FireServer("Tools", "ToolsFiring", self.id, self.firing)
		end
	end
end

function Tools.CallFunction(data, p: string, ...)
	if isServer then
		Tools._fireAllButOwner(data.owner, "ToolsCallFunction", data.id, p, ...)
		return
	end

	WeaponHelpers.GetFunctionsModule(data).CallFunction(data, p, ...)

	if data.isOwner then
		RemoteSignals.FireServer("Tools", "ToolsCallFunction", data.id, p, ...)
	end
end

function Tools.Destroy(data)
	WeaponEvents.WeaponDestroyed:Fire(data.id)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)
		Loaded.FireAllClients("Tools", "ToolsDestroy", data.id)
		Loaded.RemoveQueue(data.loadId)
	else
		Tools.Unequip(data)
		Animations.Destroy(data.animations)
	end

	data.maid:Destroy()
	table.remove(Tools._getWeapons(), Tools._getWeaponIndex(data))
end

return Tools