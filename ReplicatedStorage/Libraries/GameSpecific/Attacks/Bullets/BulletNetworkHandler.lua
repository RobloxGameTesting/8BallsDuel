local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local parentModule = require(script.Parent)
local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

local isServer = RunService:IsServer()
local command = parentModule._getCommand()

local function validCommand(value): boolean -- 1 equivalent call inferred from this helper
	return if string.find(value, command) then true else false
end

local function callConstructor(p, ...)
	if p == command then
		local v = { ... }

		if isServer then
			local Verification = require(ServerScriptService.Libraries.Modules.Verification)

			local _ = v[1]
			local v2 = v[2]

			if v2.ownerId then
				if not Tools._getEquippedFromOwnerId(v2.ownerId) then
					return
				end

				local playerByUserId = Players:GetPlayerByUserId((tonumber(v2.ownerId)))
				local character = playerByUserId and playerByUserId.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart or (humanoidRootPart.Position - v2.origin).Magnitude > 30 then
					return
				end

				local v3 = "Bullet" .. v2.bulletType
				local v4 = Verification.Check(v2.ownerId, v3)

				if not v4 then
					return
				end

				Verification.Remove(v2.ownerId, v4)

				parentModule.newServer(v2)
			end
		else
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
	local bulletById = parentModule._getBulletById(p2)

	if not (string.len(v) ~= 0 and bulletById) then
		return
	end

	if parentModule[v] then
		parentModule[v](bulletById, ...)
	else
		warn("Method : " .. v .. " not found")
	end
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