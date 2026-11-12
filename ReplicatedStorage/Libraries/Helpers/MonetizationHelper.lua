local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

RunService:IsServer()
local MonetizationHelper = {}

function MonetizationHelper.GetProductInfo(p: number, p2)
	local _, result = pcall(function()
		return (MarketplaceService:GetProductInfoAsync(p, p2))
	end)

	return result
end

function MonetizationHelper.UserOwnsGamepass(p: string, p2: number)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(tonumber(p), p2)
	end)
	return if success then result else false
end

return MonetizationHelper