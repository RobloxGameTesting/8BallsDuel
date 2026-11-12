local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.StateMachineTypes)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local StateMachine = {}

function StateMachine.new(npcId: string, brain2, homeLocation: Vector3)
	local v = {
		brain = brain2,
		currentState = nil,
		states = {},
		homeLocation = homeLocation,
		newStateEvent = Instance.new("BindableEvent"),
		maid = Maid.new(),
		stateContext = { homeLocation = homeLocation, npcId = npcId, status = {} }
	}

	local brain = StateMachine.GetBrain(v)
	brain.new(v)
	brain.Init(v)

	return v
end

function StateMachine.GetBrain(p)
	local child = script.Brains:FindFirstChild(p.brain)
	assert(child, "Brain  module not found for " .. p.brain)
	local module = require(child)

	return module
end

function StateMachine.AddState(p, p2: string, p3)
	p.states[p2] = p3
end

function StateMachine:SetState(p: string)
	local state = self.states[p]

	if not state then
		return
	end

	if self.currentState then
		self.currentState.Exit(self)
	end

	self.currentState = state

	if self.currentState then
		self.currentState.Enter(self)
		self.newStateEvent:Fire(p)
	end
end

function StateMachine.Update(p, p2: number)
	if not p.currentState then
		return
	end

	local v = p.currentState.Update(p, p2)

	if v and v ~= p.currentState.name then
		StateMachine.SetState(p, v)
	end
end

function StateMachine:Destroy()
	local brain = StateMachine.GetBrain(self)
	self.newStateEvent:Destroy()
	brain.Clear(self)
end

return StateMachine