local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local PlaceHelper = require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)

local PoolJoinSource = { ["Attribute"] = nil, ["Attribute"] = nil, Attribute = "PoolJoinSource" }

function PoolJoinSource.Record(instance)
	if not RunService:IsServer() then
		return
	end

	local v = "Teleport"

	if PlaceHelper.GetServerType() ~= "ReservedServer" then
		local success, result = pcall(function()
			return instance:GetJoinData()
		end)

		v = success
			and typeof(result) == "table"
			and ((result.SourcePlaceId ~= nil or result.TeleportData ~= nil) and "Teleport" or "Home")
			or v
	end

	instance:SetAttribute(PoolJoinSource.Attribute, v)
end

function PoolJoinSource.IsFromHome(): boolean
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local success, result = pcall(function()
		return TeleportService:GetLocalPlayerTeleportData()
	end)

	if success and result ~= nil then
		return false
	end

	local v = os.clock() + 15
	local attribute = localPlayer:GetAttribute(PoolJoinSource.Attribute)

	while attribute == nil and os.clock() < v do
		task.wait(0.1)
		attribute = localPlayer:GetAttribute(PoolJoinSource.Attribute)
	end

	return attribute == "Home"
end

return PoolJoinSource