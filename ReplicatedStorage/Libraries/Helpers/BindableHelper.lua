local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()

local BindableHelper = {}

local function getFolder() -- 2 equivalent calls inferred from this helper
	local bindables = ReplicatedStorage:FindFirstChild("Bindables")

	if bindables then
		return bindables
	end

	assert(RunService:IsServer(), "Bindable folder must be created on the server")

	bindables = Instance.new("Folder")
	bindables.Name = "Bindables"
	bindables.Parent = ReplicatedStorage

	return bindables
end

function BindableHelper.Init()
	if not isServer then
		RemoteSignals.OnClientEvent(RemoteEnums.GeneralBindableEvent, function(p, ...)
			BindableHelper.WaitForBindable(p):Fire(...)
		end)
	end
end

function BindableHelper.CreateBindable(name: string)
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = name
	bindableEvent.Parent = getFolder() -- inferred equivalent call

	bindableEvent.Event:Connect(function(...)
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

		Loaded.FireAllClientsGuaranteed(RemoteEnums.GeneralBindableEvent, name, ...)
	end)

	return bindableEvent
end

function BindableHelper.WaitForBindable(childName: string)
	return (getFolder():WaitForChild(childName)) -- inferred equivalent call
end

function BindableHelper.Callback(p: string, onEvent)
	BindableHelper.WaitForBindable(p).Event:Connect(onEvent)
end

return BindableHelper