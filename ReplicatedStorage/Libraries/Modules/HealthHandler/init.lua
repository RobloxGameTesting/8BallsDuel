script:SetAttribute("Loaded", false)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local HealthHandlerEvents = require(script.HealthHandlerEvents)
require(ReplicatedStorage.Libraries.Modules.BindableEvents)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
require(ReplicatedStorage.Libraries.Constants.RoundConstants)
local HealthHandlerConstants = require(script.HealthHandlerConstants)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()
local v = Maid.new()
local Assets = ReplicatedStorage.Assets
local Highlight = Assets.Highlight
local v2 = { "HealthHandlerEvents" }

local HealthHandler = {}

function HealthHandler.Init()
	if isServer then
		local function initStats(instance) -- 2 equivalent calls inferred from this helper
			tostring(instance.UserId)
			instance:SetAttribute("Health", 100)
			instance:SetAttribute("MaxHealth", 100)
			instance:SetAttribute("IsDowned", false)
			instance:SetAttribute("ReviveProgress", 0)
		end
		local function initPlayer(instance) -- 1 equivalent call inferred from this helper
			initStats(instance) -- inferred equivalent call
			instance.CharacterAdded:Connect(function(_)
				initStats(instance) -- inferred equivalent call
			end)
		end

		for _, v3 in Players:GetPlayers(), nil, nil do
			initPlayer(v3) -- inferred equivalent call
		end

		Players.PlayerAdded:Connect(initPlayer)
	else
		local localPlayer = Players.LocalPlayer
		local effectUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
		local damage = effectUI:WaitForChild("Damage")
		local heal = effectUI:WaitForChild("Heal")
		local userId = tostring(localPlayer.UserId)
		local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
		local animator = humanoid:WaitForChild("Animator")

		local crawl = humanoid.RigType == Enum.HumanoidRigType.R6 and 76868997529900 or 0
		local v3 = Animations.new({ crawl = crawl }, animator)

		local function updateUI(p)
			if HealthHandlerConstants.HEALTH_UI_REQUIREMENT < p then
				TweenService:Create(damage, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
			end
		end

		HealthHandlerEvents.TakeDamage.Event:Connect(function(p, p2, p3)
			if p ~= userId then
				return
			end

			local v4 = math.clamp(math.abs(p3), 10, 20) / 20

			Sounds.Play(ClientSounds.TakeDamage, nil, false)
			TweenService:Create(damage, TweenInfo.new(0.2), {
				ImageTransparency = 1 - v4
			}):Play()
			task.wait(0.2)
			updateUI(p2)
		end)

		HealthHandlerEvents.Healed.Event:Connect(function(p, p2, p3)
			if p ~= userId then
				return
			end

			updateUI(p2)

			local v4 = math.clamp(math.abs(p3), 10, 20) / 20

			TweenService:Create(heal, TweenInfo.new(0.2), {
				ImageTransparency = 1 - v4
			}):Play()
			task.wait(0.2)

			if HealthHandlerConstants.HEALTH_UI_REQUIREMENT < p2 then
				TweenService:Create(heal, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
			end
		end)

		RemoteSignals.OnClientEvent("HealthHandler", function(p: string, p2: string, ...)
			if not table.find(v2, p) then
				return
			end

			HealthHandlerEvents[p2]:Fire(...)
		end)

		local function setDowned()
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			local humanoid2 = character:FindFirstChildWhichIsA("Humanoid")
			local isDowned = HealthHandler.IsDowned(userId)

			if not humanoid2 then
				return
			end

			local torso = humanoid2.RigType == Enum.HumanoidRigType.R6 and character:FindFirstChild("Torso")

			if torso then
				if isDowned then
					torso.CanCollide = false
				else
					torso.CanCollide = true
				end
			end

			if isDowned then
				humanoid2.WalkSpeed = HealthHandlerConstants.CRAWL_WALKSPEED
				v.walkspeedConnection = humanoid2:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if not HealthHandler.IsDowned(userId) then
						return
					end

					humanoid2.WalkSpeed = HealthHandlerConstants.CRAWL_WALKSPEED
				end)
				humanoid2:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				Animations.Play(v3, {
					{
						animation = "crawl",
						looped = true,
						speed = 0.8,
						priority = Enum.AnimationPriority.Action4
					}
				})

				v.moveConnection = RunService.Heartbeat:Connect(function()
					if humanoid.MoveDirection.Magnitude == 0 then
						Animations.AdjustSpeed(v3, 0)
					else
						Animations.AdjustSpeed(v3, 1)
					end
				end)
			else
				Animations.Stop(v3)
				v.walkspeedConnection = nil
				humanoid2:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			end
		end

		setDowned()
		localPlayer.CharacterAdded:Connect(setDowned)
		localPlayer:GetAttributeChangedSignal("IsDowned"):Connect(setDowned)
	end
end

function HealthHandler.Heal(p: string?, p2: string, healing: number)
	if isServer then
		local playerByUserId = Players:GetPlayerByUserId((tonumber(p2)))

		if playerByUserId then
			local _character = playerByUserId.Character
		end

		local health = HealthHandler.GetHealth(p2)
		local v3 = math.clamp(health + healing, 0, HealthHandler.GetMaxHealth(p2))
		local v4 = v3 - health
		HealthHandler.SetHealth(p2, v3)
		HealthHandlerEvents.Healed:Fire(p2, v3, v4)
		RemoteSignals.FireAllClients("HealthHandler", "HealthHandlerEvents", "Healed", p2, v3, v4)

		local v5 = p and Profiles.GetPlayerReplica(p)

		if v5 and v5:IsActive() then
			v5:Write("Mastery", { Healing = healing })
		end
	end
end

function HealthHandler.TakeDamage(p: string, p2: number)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	local health = HealthHandler.GetHealth(p)
	local v3 = health - p2
	local v4 = v3 - health
	HealthHandler.SetHealth(p, v3)

	HealthHandlerEvents.TakeDamage:Fire(p, v3, v4)
	RemoteSignals.FireAllClients("HealthHandler", "HealthHandlerEvents", "TakeDamage", p, v3, v4)

	local character = playerByUserId.Character
	local clone = Highlight:Clone()
	clone.FillTransparency = 0.5
	clone.OutlineTransparency = 0
	clone.Parent = character

	local total = 0

	TweenService:Create(clone, TweenInfo.new(0.5), { FillTransparency = 1, OutlineTransparency = 1 }):Play()

	local v5 = Maid.new()
	v5.highlight = clone
	v5.cleanUpConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total >= 0.5 then
			v5:Destroy()
		end
	end)
end

function HealthHandler.SetHealth(p: string, value: number)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	local character = playerByUserId.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	playerByUserId:SetAttribute("Health", (math.clamp(value, 0, (HealthHandler.GetMaxHealth(p)))))

	if HealthHandlerConstants.DOWNABLE then
		if HealthHandler.GetHealth(p) == 0 then
			HealthHandler.SetDowned(p, true)
		end
	elseif humanoid then
		humanoid.MaxHealth = playerByUserId:GetAttribute("MaxHealth")
		humanoid.Health = playerByUserId:GetAttribute("Health")
	end
end

function HealthHandler.GetHealth(p: string)
	return Players:GetPlayerByUserId((tonumber(p))):GetAttribute("Health")
end

function HealthHandler.GetMaxHealth(p: string)
	return Players:GetPlayerByUserId((tonumber(p))):GetAttribute("MaxHealth")
end

function HealthHandler.IsDowned(p: string)
	return Players:GetPlayerByUserId((tonumber(p))):GetAttribute("IsDowned")
end

function HealthHandler.SetDowned(p: string, flag: boolean)
	local replica = Profiles.GetReplica("Game")
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	local character = playerByUserId.Character or playerByUserId.CharacterAdded:Wait()

	local function addReviveVisuals(character2)
		local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
		local torso = character2 and character2:FindFirstChild("Torso")

		if not (character2 and humanoidRootPart and torso) then
			return
		end

		local v3 = Maid.new()

		local clone = Assets.UI.ReviveUI:Clone()
		clone.Parent = humanoidRootPart
		v3.ReviveUI = clone

		local clone2 = Assets.UI.ReviveProgressUI:Clone()
		clone2.Parent = torso
		v3.ReviveProgressUI = clone2

		local clone3 = Highlight:Clone()
		clone3.OutlineColor = Color3.fromRGB(255, 0, 0)
		clone3.OutlineTransparency = 0.5
		clone3.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		clone3.Parent = character2
		v3.ReviveHighlight = clone3

		local revivePrompt = Instance.new("ProximityPrompt")
		revivePrompt.Name = "RevivePrompt"
		revivePrompt.ActionText = "REVIVE"
		revivePrompt.ObjectText = ""
		revivePrompt.RequiresLineOfSight = false
		v3.PromptConnection = revivePrompt.Triggered:Connect(function(player)
			local userId = tostring(player.UserId)

			if HealthHandler.IsDowned(userId) then
				Sales.Prompt(userId, MonetizationConstants.PRODUCT_IDS.REVIVE, Enum.InfoType.Product, p)
			else
				v3[`{p}reviveConnection`] = RunService.Heartbeat:Connect(function(dt: number)
					if HealthHandler.IsDowned(userId) then
						return
					end

					local v4 = HealthHandler.GetReviveProgress(p) + dt

					HealthHandler.SetReviveProgress(p, userId, v4)
				end)
			end
		end)
		revivePrompt.TriggerEnded:Connect(function(_)
			v3[`{p}reviveConnection`] = nil
		end)
		revivePrompt.Parent = torso
		v3.RevivePrompt = revivePrompt

		v[p] = v3
		HealthHandler.SetReviveProgress(p, nil, 0)
	end

	if flag then
		playerByUserId:SetAttribute("IsDowned", true)

		addReviveVisuals(character)
		v[`{p}respawnConnection`] = playerByUserId.CharacterAdded:Connect(addReviveVisuals)
	else
		replica:Write("ReviveIncrement", 1)
		playerByUserId:SetAttribute("IsDowned", false)
		v[`{p}respawnConnection`] = nil
		v[p] = nil

		HealthHandler.Heal(nil, p, 10)
		HealthHandler.SetReviveProgress(p, nil, 0)
	end

	HealthHandlerEvents.Downed:Fire(p, flag)
	RemoteSignals.FireAllClients("HealthHandler", "HealthHandlerEvents", "Downed", p, flag)
end

function HealthHandler.SetReviveProgress(p: string, p2: string?, reviveProgress: number)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	playerByUserId:SetAttribute("ReviveProgress", reviveProgress)

	local reviveProgressUI = v[p] and v[p].ReviveProgressUI

	if reviveProgressUI then
		local v3 = playerByUserId:GetAttribute("ReviveProgress") / HealthHandlerConstants.REVIVE_TIME

		reviveProgressUI.Progress.Bar.Percent.Size = UDim2.fromScale(v3, 1)

		if v3 > 0 then
			reviveProgressUI.Progress.Bar.Percent.Display.Size = UDim2.fromScale(1 / v3, 1)
		end
	end

	if playerByUserId:GetAttribute("ReviveProgress") >= HealthHandlerConstants.REVIVE_TIME then
		HealthHandler.SetDowned(p, false)
		local v3 = p2 and Profiles.GetPlayerReplica(p2)

		if v3 and v3:IsActive() then
			v3:Write("Mastery", { Healing = 50 })
		end
	end
end

function HealthHandler.GetReviveProgress(p: string)
	return Players:GetPlayerByUserId((tonumber(p))):GetAttribute("ReviveProgress")
end

function HealthHandler.GetAlivePlayers()
	local alivePlayers = {}

	for _, v3 in Players:GetPlayers(), nil, nil do
		local userId = tostring(v3.UserId)

		if not HealthHandler.IsDowned(userId) then
			table.insert(alivePlayers, v3)
		end
	end

	return alivePlayers
end

script:SetAttribute("Loaded", true)
return HealthHandler