local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(script.LootTypes)
local LootConstants = require(script.LootConstants)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local HttpService = game:GetService("HttpService")

assert(RunService:IsClient(), "Loots is a client-only module and cannot be required on the server")

local LocalPlayer = Players.LocalPlayer
local Display = script.Parent.Assets.Display
local Drop = script.Parent.Assetsscript.Drop
local isServer = RunService:IsServer()
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace }

local Loots = {}

local v = {}

local v2 = Maid.new()
local v3 = {}
local v4 = {}
local v5 = Maid.new()

local function _init()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	task.spawn(function()
		while LocalPlayer do
			character = LocalPlayer.Character
			humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			task.wait(0.5)
		end
	end)

	Scheduler.BindHeartbeat(function(p)
		for _, v6 in v do
			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				break
			end

			local vector = humanoidRootPart.Position - v6.obj.Position
			local dot = vector:Dot(vector)

			if dot < 16 then
				Loots.Collect(v6)
			elseif dot < math.pow(v6.collectReach, 2) then
				local magnitude = (humanoidRootPart.Position - v6.obj.Position).Magnitude
				local v7 = math.clamp(1 / ((humanoidRootPart.Position - v6.obj.Position).Magnitude / 10), 0, magnitude)
				local cframe = v6.obj.CFrame
				local v8 = v6.obj.CFrame + vector.Unit * v7
				local v9 = p / 0.1

				v6.obj.CFrame = cframe:Lerp(v8, (math.clamp(v9, 0, 1)))
			end
		end
	end)
end

_init()

function Loots.new(drop, position: Vector3, p: number, value: number)
	local raycastResult = workspace:Raycast(position + Vector3.new(0, 0, 0), Vector3.new(0, -100, 0), raycastParams)
	position = raycastResult and raycastResult.Position or position
	local image = LootConstants.DROP_ICONS[drop]

	assert(image, `Drop parameter {drop} isn't a valid drop type`)

	local clone = Drop:Clone()
	clone.UI.Icon.Image = image
	clone.Position = position
	clone.Parent = workspace

	local v6 = {
		maid = Maid.new(),
		displayed = false,
		obj = clone,
		value = p,
		drop = drop,
		origin = position,
		spread = value or 9,
		travelTime = random:NextNumber(0.04, 0.06),
		collectReach = random:NextInteger(10, 20),
		disarrayY = random:NextInteger(0, 2),
		uid = HttpService:GenerateGUID()
	}

	v6.maid.obj = clone

	Loots.Init(v6)
	v[v6.uid] = v6

	return v6
end

function Loots.Init(data)
	local origin = data.origin
	local number = random:NextNumber(7, 9)
	local v6 = origin + Vector3.new(
		random:NextNumber(-data.spread, data.spread),
		number,
		(random:NextNumber(-data.spread, data.spread))
	)
	local v7 = { origin, v6, v6 + Vector3.new(0, -number + data.obj.Size.Y / 2, 0) }
	local v8 = VectorHelper.DrawBezier(v7, 10)

	data.obj.Position = v8[1]
	data.obj.Parent = workspace

	task.spawn(function()
		for _, position in v8 do
			local tween = TweenService:Create(data.obj, TweenInfo.new(data.travelTime, Enum.EasingStyle.Linear), {
				Position = position
			})

			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

function Loots.Collect(data)
	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local ui = data.obj:FindFirstChild("UI")

	if humanoidRootPart then
		TweenService:Create(data.obj, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
			Position = humanoidRootPart.Position
		}):Play()
	end

	for _, image in ui:GetChildren(), nil, nil do
		if image:IsA("ImageLabel") then
			TweenService:Create(image, TweenInfo.new(0.1), { ImageTransparency = 1 }):Play()
		end
	end

	RemoteSignals.FireServer(RemoteEnums.ItemDrops, "ItemDropsCollect", data.drop, data.value)

	Loots.Display(data)
	Loots.Destroy(data)
end

function Loots:Display()
	if isServer or self.displayed then
		return nil
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local drop = self.drop
	local v6 = self.value
	local v7 = v2[drop] and true or false

	Sounds.Play(Sounds.new({ "Money", `Coin Throws {random:NextInteger(1, 3)} (SFX)` }, self.obj.Position), nil, true)

	self.displayed = true
	v2[drop] = v2[drop] or Maid.new()
	v4[drop] = tick()
	v6 = v3[drop] and v3[drop] + v6 or v6
	v3[drop] = v6

	local DISPLAY_DURATION = LootConstants.DISPLAY_DURATION
	local total = 0

	local v8 = Scheduler.BindHeartbeat(function(p)
		total += p

		if DISPLAY_DURATION <= total then
			v2[drop] = nil
		end
	end)

	v5[drop] = function()
		Scheduler.UnbindHeartbeat(v8)
	end

	if not v7 then
		v2[drop].displayUI = Display:Clone()
		v2[drop].cleanUpFunction = function()
			v3[drop] = 0
			v4[drop] = nil
			v5[drop] = nil
		end
	end

	local image = LootConstants.DISPLAY_ICONS[drop]
	v2[drop].displayUI.UI.Icon.Image = image

	if humanoidRootPart then
		if v7 then
			TweenService:Create(v2[drop].displayUI, TweenInfo.new(0.1), {
				Position = humanoidRootPart.Position + LootConstants.OFFSETS[drop]
			}):Play()
		else
			v2[drop].displayUI.Position = humanoidRootPart.Position + (drop == "Diamond" and Vector3.new(0, 2, 0) or Vector3.new(0, 0, 0))
		end
	end

	v2[drop].displayUI.Parent = workspace
	v2[drop].displayUI.UI.Label.Text = v3[drop]

	return v3[drop]
end

function Loots.Destroy(p)
	v[p.uid] = nil
	p.maid:Destroy()
end

return Loots