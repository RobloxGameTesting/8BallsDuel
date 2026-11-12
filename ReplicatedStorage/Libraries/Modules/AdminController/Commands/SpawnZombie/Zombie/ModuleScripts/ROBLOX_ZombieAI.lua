local ROBLOX_HumanoidList = require(game.ServerStorage.ROBLOX_HumanoidList)
local ROBLOX_AIUtilities = require(game.ServerStorage.ROBLOX_AIUtilities)

local ROBLOXZombieAI = {}

function updateDisplay(p, p2)
	local thread = coroutine.create(function()
		while true do
			wait()

			if p2 then
				p.Text = p2.Name
			end
		end
	end)
	coroutine.resume(thread)
end

function ROBLOXZombieAI.new(instance)
	local v = {}

	local configurations = instance.Configurations
	local v2 = {}
	local function loadConfig(childName, p) -- 7 equivalent calls inferred from this helper
		if configurations:FindFirstChild(childName) then
			v2[childName] = configurations:FindFirstChild(childName).Value
		else
			v2[childName] = p
		end
	end

	loadConfig("AttackRange", 3) -- inferred equivalent call
	loadConfig("FieldOfView", 180) -- inferred equivalent call
	loadConfig("AggroRange", 200) -- inferred equivalent call
	loadConfig("ChanceOfBoredom", 0.5) -- inferred equivalent call
	loadConfig("BoredomDuration", 10) -- inferred equivalent call
	loadConfig("Damage", 10) -- inferred equivalent call
	loadConfig("DamageCooldown", 1) -- inferred equivalent call
	local ROBLOX_StateMachine = require(game.ServerStorage.ROBLOX_StateMachine)
	local v3 = ROBLOX_StateMachine.new()
	local ROBLOX_PathfindingLibrary = require(game.ServerStorage.ROBLOX_PathfindingLibrary)
	local v4 = ROBLOX_PathfindingLibrary.new()
	local v5 = nil
	local v6 = nil

	local v7 = os.time()

	local idle = v3.NewState()
	idle.Name = "Idle"
	function idle.Action() end
	function idle.Init()
		v7 = os.time()
	end

	local search = v3.NewState()
	search.Name = "Search"
	local v8 = os.time()
	local v9 = nil
	function search.Action()
		if instance then
			local now = os.time()

			if now - v8 > 2 then
				v8 = now
				local v10 = math.random(5, 10)

				if math.random() > 0.5 then
					v10 *= -1
				end

				local v11 = math.random(5, 10)

				if math.random() > 0.5 then
					v11 *= -1
				end

				local closeEmptySpace = ROBLOX_AIUtilities:FindCloseEmptySpace(instance)

				v9 = Vector3.new(
					instance.HumanoidRootPart.Position.X + v10,
					instance.HumanoidRootPart.Position.Y,
					instance.HumanoidRootPart.Position.Z + v11
				)

				v9 = closeEmptySpace
			end

			if v9 then
				v4:MoveToTarget(instance, v9)
			end
		end
	end
	function search.Init()
		v7 = os.time()
	end

	local pursue = v3.NewState()
	pursue.Name = "Pursue"
	function pursue.Action()
		if v5 then
			if (instance.HumanoidRootPart.Position - v5.HumanoidRootPart.Position).magnitude > v2.AttackRange + 5 then
				v4:MoveToTarget(instance, v5.HumanoidRootPart.Position)
			else
				instance.Humanoid:MoveTo(v5.HumanoidRootPart.Position)
			end
		end
	end
	function pursue.Init() end

	local attack = v3.NewState()
	attack.Name = "Attack"
	local v10 = os.time()
	local track = instance.Humanoid:LoadAnimation(instance.Animations.Attack)
	function attack.Action()
		instance.Humanoid:MoveTo(v5.HumanoidRootPart.Position)
		local now = os.time()

		if now - v10 > 3 then
			v10 = now
			track:Play()
		end
	end

	local hunt = v3.NewState()
	hunt.Name = "Hunt"
	function hunt.Action()
		if v6 then
			v4:MoveToTarget(instance, v6)
		end
	end
	function hunt.Init()
		v7 = os.time() + v2.BoredomDuration / 2
	end

	local canSeeTarget = v3.NewCondition()
	canSeeTarget.Name = "CanSeeTarget"
	function canSeeTarget.Evaluate(): boolean
		if not instance then
			return false
		end

		local current = ROBLOX_HumanoidList:GetCurrent()

		local parents = {}
		local parents2 = {}

		for _, v11 in pairs(current) do
			if not (v11 and v11.Parent and v11.Parent:FindFirstChild("HumanoidRootPart") and v11.Health > 0) then
				continue
			end

			if not (v11.WalkSpeed > 0) then
				continue
			end

			local humanoidRootPart = v11.Parent:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and (instance.HumanoidRootPart.Position - humanoidRootPart.Position).magnitude <= v2.AggroRange) then
				continue
			end

			if v11.Parent.Name == "Zombie" then
				table.insert(parents2, v11.Parent)
			else
				table.insert(parents, v11.Parent)
			end
		end

		local closestVisibleTarget = ROBLOX_AIUtilities:GetClosestVisibleTarget(
			instance,
			parents,
			parents2,
			v2.FieldOfView
		)

		if closestVisibleTarget then
			v5 = closestVisibleTarget
			return true
		end

		return false
	end

	canSeeTarget.TransitionState = pursue

	local targetDead = v3.NewCondition()
	targetDead.Name = "TargetDead"
	function targetDead.Evaluate(): boolean
		return not (v5 and v5.Humanoid) or v5.Humanoid.Health <= 0
	end

	targetDead.TransitionState = idle

	local health = instance.Humanoid.Health
	local gotDamaged = v3.NewCondition()
	gotDamaged.Name = "GotDamaged"
	function gotDamaged.Evaluate(): boolean
		if instance and health > instance.Humanoid.Health then
			return true
		end

		return false
	end

	gotDamaged.TransitionState = search

	local gotBored = v3.NewCondition()
	gotBored.Name = "GotBored"
	function gotBored.Evaluate(): boolean
		local now = os.time()

		if not (now - v7 > v2.BoredomDuration and math.random() < v2.ChanceOfBoredom) then
			return false
		end

		v7 = now

		if gotBored.TransitionState == search then
			gotBored.TransitionState = idle
		else
			gotBored.TransitionState = search
		end

		return true
	end

	gotBored.TransitionState = idle

	local lostTarget = v3.NewCondition()
	lostTarget.Name = "LostTarget"
	function lostTarget.Evaluate(): boolean
		return false
	end

	lostTarget.TransitionState = hunt

	local withinRange = v3.NewCondition()
	withinRange.Name = "WithinRange"
	function withinRange.Evaluate(): boolean
		if v5 and (instance.HumanoidRootPart.Position - v5.HumanoidRootPart.Position).magnitude < v2.AttackRange then
			return true
		end

		return false
	end

	withinRange.TransitionState = attack

	local outsideRange = v3.NewCondition()
	outsideRange.Name = "OutsideRange"
	function outsideRange.Evaluate(): boolean
		if v5 and (instance.HumanoidRootPart.Position - v5.HumanoidRootPart.Position).magnitude > v2.AttackRange then
			return true
		end

		return false
	end

	outsideRange.TransitionState = pursue

	table.insert(idle.Conditions, canSeeTarget)
	table.insert(idle.Conditions, gotDamaged)
	table.insert(idle.Conditions, gotBored)

	table.insert(search.Conditions, gotBored)
	table.insert(search.Conditions, canSeeTarget)

	table.insert(pursue.Conditions, lostTarget)
	table.insert(pursue.Conditions, withinRange)
	table.insert(pursue.Conditions, targetDead)

	table.insert(attack.Conditions, outsideRange)
	table.insert(attack.Conditions, targetDead)

	table.insert(hunt.Conditions, gotBored)
	table.insert(hunt.Conditions, canSeeTarget)

	local flag = true
	local v11 = os.time()
	local function handleHit(p)
		if flag then
			if p and p.Parent and p.Parent.Name ~= "Zombie" and p.Parent:FindFirstChild("Humanoid") then
				local parent = p.Parent

				if parent.Humanoid.WalkSpeed > 0 then
					parent.Humanoid.Health = parent.Humanoid.Health - v2.Damage
					flag = false
				end
			end
		else
			local now = os.time()

			if now - v11 > v2.DamageCooldown then
				v11 = now
				flag = true
			end
		end
	end

	instance:FindFirstChild("Left Arm").Touched:connect(handleHit)
	instance:FindFirstChild("Right Arm").Touched:connect(handleHit)

	local thread = coroutine.create(function()
		while true do
			wait()

			local current = ROBLOX_HumanoidList:GetCurrent()
			local positions = {}

			for _, v12 in pairs(current) do
				if not (v12 and v12 ~= instance.Humanoid and v12.Parent and v12.Parent:FindFirstChild("HumanoidRootPart")) then
					continue
				end

				local humanoidRootPart = v12.Parent:FindFirstChild("HumanoidRootPart")

				if (instance.HumanoidRootPart.Position - humanoidRootPart.Position).magnitude <= 2.5 then
					table.insert(positions, humanoidRootPart.Position)
				end
			end

			local repulsionVector = ROBLOX_AIUtilities:GetRepulsionVector(instance.HumanoidRootPart.Position, positions)
			local _ = repulsionVector.magnitude > 0

			instance.HumanoidRootPart.RepulsionForce.force = repulsionVector

			if v3.CurrentState and instance.Configurations.Debug.Value then
				instance.BillboardGui.TextLabel.Visible = true
				instance.BillboardGui.TextLabel.Text = v3.CurrentState.Name
			end

			if not instance.Configurations.Debug.Value then
				instance.BillboardGui.TextLabel.Visible = false
			end
		end
	end)
	coroutine.resume(thread)

	v3.SwitchState(idle)

	function v.Stop()
		v3.SwitchState(nil)
	end

	return v
end

return ROBLOXZombieAI