--!native
local RunService = game:GetService("RunService")

local Settings = require(script.Parent.Settings)
require(script.Parent.Types)
local Solvers = require(script.Parent.Solvers)
local Visualizers = require(script.Parent.Visualizers)

function CreateHitbox(instance2, p)
	local hitbox = {
		Instance = instance2,
		RaycastParams = p or RaycastParams.new(),
		CastData = {
			CastType = "Raycast",
			Size = Vector3.new(0, 0, 0),
			CFrame = CFrame.identity,
			Radius = 0
		},
		Active = false,
		Resolution = 60,
		Callbacks = {},
		Attributes = {},
		FilterPartsHit = false
	}

	local instanceSet = {}
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}

	local v5 = 0
	local v6 = 0

	local postSimulationConnection = nil
	local allSegments = {}

	local function ReturnHitboxAfterCallbackInsertion(list, p2) -- 4 equivalent calls inferred from this helper
		table.insert(list, p2)
		return hitbox
	end

	function hitbox:GetAllSegments()
		return allSegments
	end

	function hitbox.GetSegment(_, p2)
		return allSegments[p2]
	end

	function hitbox.SetResolution(_, resolution: number)
		hitbox.Resolution = resolution
		return hitbox
	end

	function hitbox.SetCastData(_, instance)
		hitbox.CastData = {
			CastType = instance.CastType or "Raycast",
			Size = instance.Size or Vector3.new(0, 0, 0),
			CFrame = instance.CFrame or CFrame.identity,
			Radius = instance.Radius or 0
		}

		for _, v7 in hitbox:GetAllSegments() do
			v7.CastData = {
				CastType = v7.Instance:GetAttribute("CastType") or hitbox.CastData.CastType,
				Size = v7.Instance:GetAttribute("CastSize") or hitbox.CastData.Size,
				CFrame = v7.Instance:GetAttribute("CastCFrame") or hitbox.CastData.CFrame,
				Radius = v7.Instance:GetAttribute("CastRadius") or hitbox.CastData.Radius
			}
		end

		return hitbox
	end

	function hitbox.BeforeStart(_, p2)
		return ReturnHitboxAfterCallbackInsertion(v, p2) -- inferred equivalent call
	end

	function hitbox.OnUpdate(_, p2)
		return ReturnHitboxAfterCallbackInsertion(v2, p2) -- inferred equivalent call
	end

	function hitbox.OnHit(_, p2)
		return ReturnHitboxAfterCallbackInsertion(v3, p2) -- inferred equivalent call
	end

	function hitbox.OnStopped(_, p2)
		return ReturnHitboxAfterCallbackInsertion(v4, p2) -- inferred equivalent call
	end

	function hitbox.RemoveSegment(_, p2)
		if allSegments[p2] then
			allSegments[p2] = nil
		end

		return hitbox
	end

	function hitbox:AddSegment(instance)
		local v7 = {}

		if not instance:HasTag(Settings.Tag) and instance.Name ~= Settings.Tag then
			return v7
		end

		local solver = Solvers[instance.ClassName]

		if not solver then
			error(`{instance:GetFullName()}'s class type {instance.ClassName} is not supported by ShapecastHitbox`)
		end

		v7.Distance = 0
		v7.Instance = instance
		v7.Position = solver:ToPosition(v7)
		v7.LastDirection = Vector3.new(-1, -1, -1)
		v7.CastData = {
			CastType = v7.Instance:GetAttribute("CastType") or hitbox.CastData.CastType,
			Size = v7.Instance:GetAttribute("CastSize") or hitbox.CastData.Size,
			CFrame = v7.Instance:GetAttribute("CastCFrame") or hitbox.CastData.CFrame,
			Radius = v7.Instance:GetAttribute("CastRadius") or hitbox.CastData.Radius
		}

		function v7._update(_)
			if v7.Instance.Parent == nil then
				allSegments[instance] = nil
				return
			end

			local castType = v7.CastData.CastType
			local raycastResult, lastDirection = Solvers[castType]:Cast(v7, hitbox.RaycastParams)
			local magnitude = lastDirection.Magnitude

			if raycastResult then
				hitbox.RaycastResult = raycastResult

				if hitbox.FilterPartsHit then
					local filterDescendantsInstances = hitbox.RaycastParams.FilterDescendantsInstances
					table.insert(filterDescendantsInstances, raycastResult.Instance)

					instanceSet[raycastResult.Instance] = true
					hitbox.RaycastParams.FilterDescendantsInstances = filterDescendantsInstances
				end

				for _, callback in v3 do
					task.defer(callback, raycastResult, v7)
				end
			end

			local adornment = Settings.Debug_Visible and Visualizers[castType]:GetAdornment()

			if adornment then
				Visualizers[castType]:ToRender(adornment, v7, solver:ToVisual(v7), magnitude, raycastResult)
				task.delay(
					Settings[`Debug_Instance_{castType}_Destroy_Time`],
					Visualizers[castType].ReturnAdornment,
					Visualizers[castType],
					adornment
				)
			end

			if magnitude > 0 then
				v7.LastDirection = lastDirection
				v7.Distance += magnitude
			end

			v7.Position = v7.Instance.WorldPosition
		end

		allSegments[instance] = v7

		return v7
	end

	function hitbox:Reconcile()
		assert(hitbox.Instance ~= nil, "No instance tied to this hitbox! Please set with Hitbox.Instance!")
		table.clear(allSegments)

		for _, descendant in hitbox.Instance:GetDescendants() do
			hitbox:AddSegment(descendant)
		end

		return hitbox
	end

	function hitbox.HitStart(_, value: number?, p2)
		for _, v7 in hitbox:GetAllSegments() do
			v7.Position = nil
			v7.Position = Solvers[v7.Instance.ClassName]:ToPosition(v7)
			v7.Distance = 0
		end

		for _, v7 in v do
			v7()
		end

		hitbox.RaycastResult = nil
		hitbox.RaycastParams = p2 or hitbox.RaycastParams
		hitbox.Active = true

		v6 = os.clock()
		v5 = value or 1e999

		return hitbox
	end

	function hitbox:HitStop()
		if not hitbox.Active then
			return hitbox
		end

		v5 = 0
		hitbox.Active = false

		for _, v7 in v4 do
			v7(function()
				table.clear(v)
				table.clear(v2)
				table.clear(v3)
				table.clear(v4)
			end)
		end

		if not hitbox.FilterPartsHit then
			return hitbox
		end

		local filterDescendantsInstances = hitbox.RaycastParams.FilterDescendantsInstances

		for k in instanceSet do
			local index = table.find(filterDescendantsInstances, k)

			if index then
				table.remove(filterDescendantsInstances, index)
			end
		end

		table.clear(instanceSet)
		hitbox.RaycastParams.FilterDescendantsInstances = filterDescendantsInstances

		return hitbox
	end

	function hitbox.Destroy(_)
		postSimulationConnection:Disconnect()
	end

	local function Init() -- 1 equivalent call inferred from this helper
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			if v5 > 0 then
				local now = os.clock()
				local v7 = now - v6

				if 1 / hitbox.Resolution <= v7 then
					v6 = now

					for _, v8 in v2 do
						v8(v7)
					end

					for _, v8 in hitbox:GetAllSegments() do
						task.defer(v8._update, v8)
					end
				end

				v5 -= v7
			end

			if v5 <= 0 then
				hitbox:HitStop()
			end
		end)

		hitbox:Reconcile()
	end

	Init() -- inferred equivalent call
	return hitbox
end

return CreateHitbox