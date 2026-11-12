game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Defaults = require(ReplicatedStorage.Libraries.Modules.Defaults)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Types.DataTypes)

local isServer = RunService:IsServer()
local isStudio = RunService:IsStudio()
local bindableEvent = Instance.new("BindableEvent")

local v = { profiles = {}, replicas = {} }

local v2 = {}

local Profiles = {}
local classToken, v3

if isServer then
	local ProfileService = require(ServerScriptService.Libraries.Classes.ProfileService)
	local ReplicaService = require(ServerScriptService.Libraries.Classes.ReplicaService)

	local v4 = game.PlaceId == 116921506811323 and "Release" or "Testing" .. (isStudio and "V38" or "V3")

	classToken = ReplicaService.NewClassToken("PlayerProfile")
	v3 = ProfileService.GetProfileStore(v4, Defaults:Get())
else
	v3 = nil
	classToken = nil
end

function Profiles.GetReplica(value: string)
	assert(typeof(value) == "string")

	while not v2[value] do
		task.wait()
	end

	return v2[value]
end

function Profiles.SetReplica(p, p2)
	v2[p] = p2
end

function Profiles.GetPlayerReplica(value: string)
	assert(typeof(value) == "string", "userId isn't a string type")
	assert(tonumber(value), "userId can't be converted to a number")

	if isServer then
	end

	local replica = v.replicas[value]

	return if replica and replica:IsActive() then replica else nil
end

function Profiles.WaitForPlayerReplica(value: string)
	assert(typeof(value) == "string", "userId isn't a string type")
	assert(tonumber(value), "userId can't be converted to a number")

	local bindableEvent2 = Instance.new("BindableEvent")

	bindableEvent.Event:Connect(function(p)
		if value == p then
			bindableEvent2:Fire()
		end
	end)

	bindableEvent2.Event:Wait()
	return v.replicas[value]
end

function Profiles.GetPlayerProfile(p)
	if not isServer then
		return
	end

	local profile = v.profiles[p]

	if profile and profile:IsActive() then
		return profile
	end
end

function Profiles.SetServerPlayerData(p, p2, p3)
	if p2 == nil then
		local playerReplica = Profiles.GetPlayerReplica(p)

		if playerReplica and playerReplica:IsActive() then
			playerReplica:Destroy()
		end
	end

	v.profiles[p] = p2
	v.replicas[p] = p3
	bindableEvent:Fire(p)
end

function Profiles.SetClientPlayerData(p, p2)
	v.replicas[p] = p2

	bindableEvent:Fire(p)
end

function Profiles.AddPlayer(p: string)
	if not isServer then
		return
	end

	local ReplicaService = require(ServerScriptService.Libraries.Classes.ReplicaService)

	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))

	if not playerByUserId then
		warn("The player could not be found")
		return
	end

	local success, result = pcall(function()
		return (v3:LoadProfileAsync("Player_" .. p))
	end)

	if success and result == nil then
		warn("[Profiles] LoadProfileAsync returned no profile for " .. p)
		success = false
	end

	if not success then
		playerByUserId:Kick("Error loading your data. Please rejoin")

		return
	end

	result:AddUserId((tonumber(p)))
	result:Reconcile()

	result:ListenToRelease(function()
		Profiles.SetServerPlayerData(p, nil, nil)

		playerByUserId:Kick("Error loading your data. Please rejoin")
	end)

	if not playerByUserId:IsDescendantOf(Players) then
		result:Release()
		return
	end

	local replica = ReplicaService.NewReplica({
		ClassToken = classToken,
		Tags = { Player = playerByUserId },
		Data = result.Data,
		Replication = "All",
		WriteLib = ReplicatedStorage.Libraries.WriteLibraries.Player
	})

	Profiles.SetServerPlayerData(p, result, replica)
end

function Profiles:Release()
	if not isServer then
		warn("Tried to call Release on the client")
		return
	end

	local playerProfile = Profiles.GetPlayerProfile(self)

	if playerProfile then
		playerProfile:Release()
	end
end

return Profiles