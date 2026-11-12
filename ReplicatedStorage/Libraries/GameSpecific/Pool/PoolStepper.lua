local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolPhysics = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolPhysics)

local PoolStepper = {}
PoolStepper.FixedDelta = 1 / 120
PoolStepper.MaxStepsPerFrame = 24
PoolStepper.MaxSettleSeconds = 30
PoolStepper.MaxShotDelaySteps = math.ceil(30 / PoolStepper.FixedDelta)

function PoolStepper.new()
	return { Residual = 0 }
end

function PoolStepper:Reset()
	self.Residual = 0
end

function PoolStepper:Advance(p, p2: number, p3: number?)
	if p3 and p3 <= 0 then
		self.Residual = 0

		return 0
	end

	if p.Settled and not PoolPhysics.HasPatrol(p) then
		self.Residual = 0

		return 0
	end

	self.Residual += math.max(p2, 0)
	local count = 0

	while self.Residual >= PoolStepper.FixedDelta do
		self.Residual -= PoolStepper.FixedDelta
		count += 1

		PoolPhysics.Step(p, PoolStepper.FixedDelta)

		if p.Settled and not PoolPhysics.HasPatrol(p) then
			self.Residual = 0
			return count
		end

		if p3 and p3 <= count then
			self.Residual = 0
			return count
		elseif PoolStepper.MaxStepsPerFrame <= count then
			break
		end
	end

	return count
end

function PoolStepper.RunToSettle(p)
	local count = 0

	for _ = 1, math.ceil(PoolStepper.MaxSettleSeconds / PoolStepper.FixedDelta) do
		if p.Settled then
			return true, count
		end

		PoolPhysics.Step(p, PoolStepper.FixedDelta)
		count += 1
	end

	return p.Settled, count
end

return PoolStepper