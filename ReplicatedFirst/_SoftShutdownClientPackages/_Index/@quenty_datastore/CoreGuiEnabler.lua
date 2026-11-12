local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local v = loaded("CharacterUtils")
local v2 = loaded("Maid")
local v3 = loaded("ObservableSubscriptionTable")
local v4 = loaded("Rx")
local named = loaded("Symbol").named("allToken")

local class = {}
class.__index = class
class.ClassName = "CoreGuiEnabler"

function class.new()
	local object = setmetatable({}, class)

	object._maid = v2.new()

	object._states = {}

	object._stateSubs = v3.new()
	object._maid:GiveTask(object._stateSubs)

	object:AddState(Enum.CoreGuiType.Backpack, function(p)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, p)
		v.unequipTools(Players.LocalPlayer)
	end)

	object:AddState(Enum.CoreGuiType.SelfView, function(_) end)

	object:AddState(Enum.CoreGuiType.All, function(p)
		if p then
			for _, v5 in pairs(Enum.CoreGuiType:GetEnumItems()) do
				if v5 ~= Enum.CoreGuiType.All then
					object:Enable(named, v5)
				end
			end
		else
			for _, v5 in pairs(Enum.CoreGuiType:GetEnumItems()) do
				if v5 ~= Enum.CoreGuiType.All then
					object:Disable(named, v5)
				end
			end
		end
	end)

	for _, v5 in pairs(Enum.CoreGuiType:GetEnumItems()) do
		if not object._states[v5] then
			object:AddState(v5, function(p)
				StarterGui:SetCoreGuiEnabled(v5, p)
			end)
		end
	end

	object:_addStarterGuiState("TopbarEnabled")
	object:_addStarterGuiState("BadgesNotificationsActive")
	object:_addStarterGuiState("PointsNotificationsActive")

	object:AddState("ModalEnabled", function(p)
		UserInputService.ModalEnabled = not p
	end)

	object:AddState("MouseIconEnabled", function(mouseIconEnabled)
		UserInputService.MouseIconEnabled = mouseIconEnabled
	end)

	return object
end

function class:_addStarterGuiState(p)
	self:AddState(p, function(p2)
		local success, result = pcall(function()
			StarterGui:SetCore(p, p2)
		end)

		if not success then
			warn("[CoreGuiEnabler] - Failed to set core", result)
		end
	end)
end

function class:IsEnabled(p): boolean
	local state = self._states[p]

	if not state then
		error(string.format("[CoreGuiEnabler] - State '%s' does not exist.", (tostring(p))))
	end

	return next(state.disabledBy) == nil
end

function class:ObserveIsEnabled(p)
	if not self._states[p] then
		error(string.format("[CoreGuiEnabler] - State '%s' does not exist.", (tostring(p))))
	end

	return self._stateSubs:Observe(p):Pipe({ v4.startFrom(function()
			return { self:IsEnabled(p) }
		end) })
end

function class:AddState(p, onChangeCallback)
	assert(type(onChangeCallback) == "function", "must have onChangeCallback as function")
	assert(self._states[p] == nil, "state already exists")

	self._states[p] = { lastState = true, onChangeCallback = onChangeCallback, disabledBy = {} }
end

function class:_setDisabledByKey(p, p2, p3)
	assert(p2 ~= nil, "Bad key")

	local state = self._states[p]

	if not state then
		error(string.format("[CoreGuiEnabler] - State '%s' does not exist.", (tostring(p))))
	end

	state.disabledBy[p2] = p3

	local lastState = next(state.disabledBy) == nil

	if state.lastState ~= lastState then
		state.lastState = lastState
		state.onChangeCallback(lastState)
		self._stateSubs:Fire(p, lastState)
	end
end

function class:Disable(p, p2)
	assert(p ~= nil, "Bad key")

	if not self._states[p2] then
		error(string.format("[CoreGuiEnabler] - State '%s' does not exist.", (tostring(p2))))
	end

	self:_setDisabledByKey(p2, p, true)

	return function()
		self:Enable(p, p2)
	end
end

function class:Enable(p, p2)
	assert(p ~= nil, "Bad key")

	if not self._states[p2] then
		error(string.format("[CoreGuiEnabler] - State '%s' does not exist.", (tostring(p2))))
	end

	self:_setDisabledByKey(p2, p, nil)
end

return class.new()