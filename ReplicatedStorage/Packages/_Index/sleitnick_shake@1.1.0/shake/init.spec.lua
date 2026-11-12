local RunService = game:GetService("RunService")

local function AwaitStop(object)
	local lastTime = os.clock()
	object:Update()

	while object:IsShaking() do
		task.wait()
		object:Update()
	end

	return os.clock() - lastTime
end

return function()
	local parentModule = require(script.Parent)

	describe("Construct", function()
		it("should construct a new shake instance", function()
			expect(function()
				parentModule.new()
			end).to.never.throw()
		end)
	end)

	describe("Static Functions", function()
		it("should get next render name", function()
			local renderName = parentModule.NextRenderName()
			local renderName2 = parentModule.NextRenderName()
			local renderName3 = parentModule.NextRenderName()
			expect(renderName).to.be.a("string")
			expect(renderName2).to.be.a("string")
			expect(renderName3).to.be.a("string")
			expect(renderName).to.never.equal(renderName2)
			expect(renderName2).to.never.equal(renderName3)
			expect(renderName3).to.never.equal(renderName)
		end)

		it("should perform inverse square", function()
			local inverseSquare = parentModule.InverseSquare(Vector3.new(10, 10, 10), 10)
			expect((typeof(inverseSquare))).to.equal("Vector3")
			expect(inverseSquare).to.equal(Vector3.new(0.099999994, 0.099999994, 0.099999994))
		end)
	end)

	describe("Cloning", function()
		it("should clone a shake instance", function()
			local v = parentModule.new()
			v.Amplitude = 5
			v.Frequency = 2
			v.FadeInTime = 3
			v.FadeOutTime = 4
			v.SustainTime = 6
			v.Sustain = true
			v.PositionInfluence = Vector3.new(1, 2, 3)
			v.RotationInfluence = Vector3.new(3, 2, 1)
			function v.TimeFunction()
				return os.clock()
			end

			local clone = v:Clone()
			expect(clone).to.be.a("table")
			expect((getmetatable(clone))).to.equal(parentModule)
			expect(clone).to.never.equal(v)

			for _, v2 in ipairs({
				"Amplitude",
				"Frequency",
				"FadeInTime",
				"FadeOutTime",
				"SustainTime",
				"Sustain",
				"PositionInfluence",
				"RotationInfluence",
				"TimeFunction"
			}) do
				expect(v[v2]).to.equal(clone[v2])
			end
		end)

		it("should clone a shake instance but ignore running state", function()
			local v = parentModule.new()
			v:Start()
			local clone = v:Clone()
			expect(v:IsShaking()).to.equal(true)
			expect(clone:IsShaking()).to.equal(false)
		end)
	end)

	describe("Shaking", function()
		it("should start", function()
			local v = parentModule.new()
			expect(v:IsShaking()).to.equal(false)
			v:Start()
			expect(v:IsShaking()).to.equal(true)
		end)

		it("should stop", function()
			local v = parentModule.new()
			v:Start()
			expect(v:IsShaking()).to.equal(true)
			v:Stop()
			expect(v:IsShaking()).to.equal(false)
		end)

		it("should shake for nearly no time", function()
			local v = parentModule.new()
			v.FadeInTime = 0
			v.FadeOutTime = 0
			v.SustainTime = 0
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0, 0.05)
		end)

		it("should shake for fade in time", function()
			local v = parentModule.new()
			v.FadeInTime = 0.1
			v.FadeOutTime = 0
			v.SustainTime = 0
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.1, 0.05)
		end)

		it("should shake for fade out time", function()
			local v = parentModule.new()
			v.FadeInTime = 0
			v.FadeOutTime = 0.1
			v.SustainTime = 0
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.1, 0.05)
		end)

		it("should shake for sustain time", function()
			local v = parentModule.new()
			v.FadeInTime = 0
			v.FadeOutTime = 0
			v.SustainTime = 0.1
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.1, 0.05)
		end)

		it("should shake for fade in and sustain time", function()
			local v = parentModule.new()
			v.FadeInTime = 0.1
			v.FadeOutTime = 0
			v.SustainTime = 0.1
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.2, 0.05)
		end)

		it("should shake for fade out and sustain time", function()
			local v = parentModule.new()
			v.FadeInTime = 0
			v.FadeOutTime = 0.1
			v.SustainTime = 0.1
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.2, 0.05)
		end)

		it("should shake for fade in and fade out time", function()
			local v = parentModule.new()
			v.FadeInTime = 0.1
			v.FadeOutTime = 0.1
			v.SustainTime = 0
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.2, 0.05)
		end)

		it("should shake for fading and sustain time", function()
			local v = parentModule.new()
			v.FadeInTime = 0.1
			v.FadeOutTime = 0.1
			v.SustainTime = 0.1
			v:Start()
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.3, 0.05)
		end)

		it("should shake indefinitely", function()
			local v = parentModule.new()
			v.FadeInTime = 0
			v.FadeOutTime = 0
			v.SustainTime = 0
			v.Sustain = true
			v:Start()

			task.delay(0.1, function()
				v:StopSustain()
			end)
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.1, 0.05)
		end)

		it("should shake indefinitely and fade out", function()
			local v = parentModule.new()
			v.FadeInTime = 0
			v.FadeOutTime = 0.1
			v.SustainTime = 0
			v.Sustain = true
			v:Start()

			task.delay(0.1, function()
				v:StopSustain()
			end)
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.2, 0.05)
		end)

		it("should shake indefinitely and fade out with fade in time", function()
			local v = parentModule.new()
			v.FadeInTime = 0.1
			v.FadeOutTime = 0.1
			v.SustainTime = 0
			v.Sustain = true
			v:Start()

			task.delay(0.3, function()
				v:StopSustain()
			end)
			local awaitStop = AwaitStop(v)
			expect(awaitStop).to.be.near(0.4, 0.05)
		end)

		it("should connect to signal", function()
			local v = parentModule.new()
			v.SustainTime = 0.1
			v:Start()
			local v2 = false
			local v3 = v:OnSignal(RunService.Heartbeat, function()
				v2 = true
			end)
			expect((typeof(v3))).to.equal("RBXScriptConnection")
			expect(v3.Connected).to.equal(true)
			AwaitStop(v)
			expect(v2).to.equal(true)
			expect(v3.Connected).to.equal(false)
		end)

		it("should bind to render step", function()
			local v = parentModule.new()
			v.SustainTime = 0.1
			v:Start()
			local v2 = false
			v:BindToRenderStep("ShakeTest", Enum.RenderPriority.Last.Value, function()
				v2 = true
			end)
			AwaitStop(v)
			expect(v2).to.equal(true)
		end)
	end)
end