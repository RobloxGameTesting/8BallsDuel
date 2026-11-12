local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local isServer = RunService:IsServer()
local POOL_VIP_PASS_INFO = MonetizationConstants.POOL_VIP_PASS_INFO

return function(p)
	if not isServer then
		return
	end

	local userId = tostring(p.UserId)

	if not (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)) then
		return
	end

	local PoolPlayerData = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolPlayerData)

	for _, skin in POOL_VIP_PASS_INFO.skins do
		PoolPlayerData.GrantSkin(p.UserId, skin.category, skin.item)
	end
end