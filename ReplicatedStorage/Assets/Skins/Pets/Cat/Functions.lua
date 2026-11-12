local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(_)
	if isServer then
	end
end

function Functions.onDestroy(_) end

return Functions