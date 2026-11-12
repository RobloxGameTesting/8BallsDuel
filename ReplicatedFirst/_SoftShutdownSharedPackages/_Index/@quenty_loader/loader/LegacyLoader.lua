local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LoaderUtils = require(script.Parent.LoaderUtils)
local BounceTemplateUtils = require(script.Parent.BounceTemplateUtils)
local Loader = require(script.Parent.Loader)

local LegacyLoader = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "LegacyLoader"
}

LegacyLoader.__index = LegacyLoader

function LegacyLoader.new(p)
	return (setmetatable(
		{ _script = assert(p, "No script"), _container = false, _locked = false, _lookupMap = {} },
		LegacyLoader
	))
end

function LegacyLoader:Lock()
	assert(not self._container, "Cannot bootstrap game when legacy loader was already used")
	self._locked = true
end

function LegacyLoader.GetLoader(_, p)
	return Loader.new(p)
end

function LegacyLoader:Require(moduleScript)
	assert(not self._locked, "Cannot use legacy loader after already transformed")

	self:_setupIfNeeded()

	if type(moduleScript) == "number" then
		return require(moduleScript)
	end

	if type(moduleScript) == "string" then
		local lookup = self._lookupMap[moduleScript]

		if lookup then
			return require(lookup)
		end

		error("Error: Library '" .. tostring(moduleScript) .. "' does not exist.", 2)
	else
		if typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript") then
			return require(moduleScript)
		end

		error(("Error: module must be a string or ModuleScript, got '%s' for '%s'"):format(
			typeof(moduleScript),
			(tostring(moduleScript))
		))
	end
end

function LegacyLoader:_buildLookupContainer()
	for _, moduleScript in pairs(self._container:GetDescendants()) do
		if not moduleScript:IsA("ModuleScript") or moduleScript:FindFirstAncestorWhichIsA("ModuleScript") then
			continue
		end

		local v

		if BounceTemplateUtils.isBounceTemplate(moduleScript) then
			v = BounceTemplateUtils.getTarget(moduleScript) or moduleScript
		else
			v = moduleScript
		end

		local lookup = self._lookupMap[moduleScript.Name]

		if lookup then
			if v ~= lookup then
				warn(("[LegacyLoader] - Duplicate module %q found, using first found\n\t(1) %s (used)\n\t(2) %s"):format(
					moduleScript.Name,
					self._lookupMap[moduleScript.Name]:GetFullName(),
					moduleScript:GetFullName()
				))
			end
		else
			self._lookupMap[moduleScript.Name] = v
		end
	end
end

function LegacyLoader:_setupIfNeeded()
	local v = rawget(self, "_container")

	if v then
		return v
	end

	assert(self._script.Name == "Nevermore", "Cannot invoke legacy mode if not at ReplicatedStorage.Nevermore")
	assert(self._script.Parent == ReplicatedStorage, "Cannot invoke legacy mode if not at ReplicatedStorage.Nevermore")

	if not RunService:IsRunning() then
		error("Test mode not supported")
	elseif RunService:IsServer() and RunService:IsClient() or not RunService:IsRunning() then
		if RunService:IsRunning() then
			error("Warning: Loading all modules in PlaySolo. It's recommended you use accurate play solo.")
		end
	elseif RunService:IsServer() then
		local nevermore = ServerScriptService:FindFirstChild("Nevermore")
			or error("No ServerScriptService.Nevermore folder")
		local nevermoreClient, nevermoreServer, nevermoreShared = LoaderUtils.toWallyFormat(nevermore)

		nevermoreClient.Name = "_nevermoreClient"
		nevermoreClient.Parent = ReplicatedStorage

		nevermoreShared.Name = "_nevermoreShared"
		nevermoreShared.Parent = ReplicatedStorage

		nevermoreServer.Name = "_nevermoreServer"
		nevermoreServer.Parent = ServerScriptService

		rawset(self, "_container", nevermoreServer)
		self:_buildLookupContainer()
	elseif RunService:IsClient() then
		local nevermoreClient = ReplicatedStorage:WaitForChild("_nevermoreClient", 2)

		if not nevermoreClient then
			warn("[Nevermore] - Be sure to call require(ServerScriptService.Nevermore) on the server to replicate nevermore")
			nevermoreClient = ReplicatedStorage:WaitForChild("_nevermoreClient")
		end

		rawset(self, "_container", nevermoreClient)
		self:_buildLookupContainer()
	else
		error("Error: Unknown RunService state (Not client/server/test mode)")
	end
end

return LegacyLoader