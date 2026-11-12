local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local POOL_WORLD_PASS_INFO = MonetizationConstants.POOL_WORLD_PASS_INFO
return {
	["Id"] = POOL_WORLD_PASS_INFO.gamepassId,
	Name = POOL_WORLD_PASS_INFO.name,
	Blurb = POOL_WORLD_PASS_INFO.blurb,
	Owns = function(value: number?): boolean
		if typeof(value) ~= "number" or value <= 0 then
			return false
		end

		local playerReplica = Profiles.GetPlayerReplica((tostring(value)))
		local data = playerReplica and playerReplica.Data
		local gamepasses = data and data.gamepasses

		return typeof(gamepasses) == "table" and gamepasses[POOL_WORLD_PASS_INFO.gamepassName] == true
	end
}