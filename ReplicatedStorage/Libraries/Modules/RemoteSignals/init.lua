local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local RemoteEnums = require(script.RemoteEnums)
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local RemoteSignals = {}

local function getFolder()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")

	if remotes then
		return remotes
	end

	if not RunService:IsServer() then
		return (ReplicatedStorage:WaitForChild("Remotes"))
	end

	local remotes2 = Instance.new("Folder")
	remotes2.Name = "Remotes"
	remotes2.Parent = ReplicatedStorage

	return remotes2
end

function RemoteSignals.Init()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")

	if not remotes then
		if RunService:IsServer() then
			remotes = Instance.new("Folder")
			remotes.Name = "Remotes"
			remotes.Parent = ReplicatedStorage
		else
			remotes = ReplicatedStorage:WaitForChild("Remotes")
		end
	end

	if isServer then
		for _, remoteEnum in RemoteEnums do
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = remoteEnum
			remoteEvent.Parent = remotes
		end
	end
end

function RemoteSignals.GetRemote(childName)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")

	if not remotes then
		if RunService:IsServer() then
			remotes = Instance.new("Folder")
			remotes.Name = "Remotes"
			remotes.Parent = ReplicatedStorage
		else
			remotes = ReplicatedStorage:WaitForChild("Remotes")
		end
	end

	return (remotes:WaitForChild(childName))
end

function RemoteSignals:FireClient(p, ...)
	assert(RunService:IsServer(), "FireClient can only be called from the server")

	RemoteSignals.GetRemote(p):FireClient(self, ...)
end

function RemoteSignals:FireAllClients(...)
	assert(RunService:IsServer(), "FireAllClients can only be called from the server")

	RemoteSignals.GetRemote(self):FireAllClients(...)
end

function RemoteSignals:FireServer(...)
	assert(RunService:IsClient(), "FireServer can only be called from the client")

	RemoteSignals.GetRemote(self):FireServer(...)
end

function RemoteSignals.OnServerEvent(p, callback)
	assert(RunService:IsServer(), "OnServerEvent can only be called from the server")

	return RemoteSignals.GetRemote(p).OnServerEvent:Connect(function(p2, ...)
		callback(p2, ...)
	end)
end

function RemoteSignals.OnClientEvent(p, callback)
	assert(RunService:IsClient(), "OnClientEvent can only be called from the client")

	return RemoteSignals.GetRemote(p).OnClientEvent:Connect(function(...)
		callback(...)
	end)
end

script:SetAttribute("Loaded", true)

return RemoteSignals