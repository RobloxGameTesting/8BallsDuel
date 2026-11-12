local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local LegacyLoader = require(script.LegacyLoader)
local StaticLegacyLoader = require(script.StaticLegacyLoader)
local LoaderUtils = require(script.LoaderUtils)
local v, v2

if RunService:IsRunning() then
	v = LegacyLoader.new(script)
	v2 = {
		__call = function(_, p)
			return v:Require(p)
		end,
		__index = function(_, p)
			return v:Require(p)
		end
	}
else
	v = StaticLegacyLoader.new()
	v2 = {
		__call = function(_, p)
			local v3 = getfenv(2)
			return v:Require(v3.script, p)
		end,
		__index = function(_, p)
			local v3 = getfenv(2)
			return v:Require(v3.script, p)
		end
	}
end

local function bootstrapGame(instance)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(RunService:IsRunning(), "Game must be running")

	v:Lock()

	local wallyFormat, v3, v4 = LoaderUtils.toWallyFormat(instance, false)

	wallyFormat.Parent = ReplicatedStorage
	v4.Parent = ReplicatedStorage
	v3.Parent = ServerScriptService

	return v3, wallyFormat, v4
end

local function bootstrapPlugin(parent)
	assert(typeof(parent) == "Instance", "Bad instance")
	v = LegacyLoader.new(script)
	v:Lock()

	local wallyFormat = LoaderUtils.toWallyFormat(parent, true)
	wallyFormat.Parent = parent

	return function(value)
		if type(value) ~= "string" then
			return require(value)
		end

		if wallyFormat:FindFirstChild(value) then
			return require(wallyFormat:FindFirstChild(value))
		end

		error(("Unknown module %q"):format((tostring(value))))
	end
end

local function handleLoad(instance)
	assert(typeof(instance) == "Instance", "Bad moduleScript")

	return v:GetLoader(instance)
end

return (setmetatable({
	load = handleLoad,
	bootstrapGame = bootstrapGame,
	bootstrapPlugin = bootstrapPlugin
}, v2))