local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local parentModule = require(script.Parent)

local isServer = RunService:IsServer()
local command = parentModule._getCommand()

local function validCommand(value): boolean -- 1 equivalent call inferred from this helper
	return if string.find(value, command) then true else false
end

local function callConstructor(p, ...)
	if p == command then
		local v = { ... }

		if not isServer then
			local _ = v[1]
			local v2 = v[2]
			parentModule.newClient(v2)
		end
	end
end

local function callRemote(p, value, p2, ...)
	if not validCommand(value) then -- inferred equivalent call
		return
	end

	tostring(p.UserId)
	local v, _ = string.gsub(value, command, "")
	local enemyById = parentModule._getEnemyById(p2)

	if not (string.len(v) ~= 0 and enemyById and parentModule[v]) then
		return
	end

	parentModule[v](enemyById, ...)
end

if isServer then
	task.spawn(function()
		RemoteSignals.OnServerEvent(command, function(p, p2, p3, ...)
			task.spawn(function(...)
				callConstructor(p2, p3, ...)
				callRemote(p, p2, p3, ...)
			end, ...)
		end)
	end)
else
	task.spawn(function()
		local localPlayer = Players.LocalPlayer

		RemoteSignals.OnClientEvent(command, function(p, p2, ...)
			task.spawn(function(...)
				callConstructor(p, p2, ...)
				callRemote(localPlayer, p, p2, ...)
			end, ...)
		end)
	end)
end

script:SetAttribute("Loaded", true)

return {}