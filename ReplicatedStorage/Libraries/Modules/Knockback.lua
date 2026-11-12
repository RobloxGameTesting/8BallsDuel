local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("RunService")
game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.MobileHelper)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

Maid.new()
local isServer = RunService:IsServer()

local Knockback = {}

function Knockback.Recoil(_, player, p, p2, p3, p4, options)
	if isServer then
		RemoteSignals.FireClient(player, "Knockback", "Knockback", p2, p3, p4)
		return
	end

	local characters = options or {}
	table.insert(characters, player.Character)

	Knockback:Start(p, p2, p3, p4, false, characters):Connect(function(cframe)
		player.Character:PivotTo(cframe)
	end)
end

function Knockback:Start(callback, p: number, p2: number, vector3: Vector3, flag: boolean, filterDescendantsInstances)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances

	local v = p / p2
	local total = 0
	local heartbeatConnection = nil
	local bindableEvent = Instance.new("BindableEvent")

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		local v2 = Knockback:Cast(callback, vector3 * (p2 * dt), flag, raycastParams)

		if v2 then
			bindableEvent:Fire(v2)
		else
			heartbeatConnection:Disconnect()
		end

		if v <= total then
			heartbeatConnection:Disconnect()
		end
	end)

	return bindableEvent.Event
end

function Knockback:Cast(callback, vector3: Vector3, flag: boolean, raycastParams)
	local zeroVector3 = VectorHelper.ZeroVector3(vector3)
	local v = callback() + zeroVector3

	local raycastResult = workspace:Raycast(callback().Position, zeroVector3 * 2, raycastParams)

	if raycastResult and raycastResult.Instance.CanCollide then
		print("wall result: ", raycastResult.Instance:GetFullName())
		return nil
	end

	if flag then
		return (CFrame.lookAlong(v.Position, zeroVector3))
	end

	return v
end

return Knockback