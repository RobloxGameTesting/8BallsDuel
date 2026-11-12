local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local PoolVip = {}

local POOL_VIP_PASS_INFO = MonetizationConstants.POOL_VIP_PASS_INFO

PoolVip.Id = POOL_VIP_PASS_INFO.gamepassId
PoolVip.Name = POOL_VIP_PASS_INFO.name
PoolVip.Blurb = POOL_VIP_PASS_INFO.blurb

PoolVip.TagText = "[ VIP ]"
PoolVip.TagColour = Color3.fromRGB(255, 213, 0)

local v = string.format("<font color=\"#%s\"><b>%s</b></font>", PoolVip.TagColour:ToHex(), PoolVip.TagText)

function PoolVip.Owns(value: number?): boolean
	if typeof(value) ~= "number" or value <= 0 then
		return false
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(value)))
	local data = playerReplica and playerReplica.Data
	local gamepasses = data and data.gamepasses

	return typeof(gamepasses) == "table" and gamepasses[POOL_VIP_PASS_INFO.gamepassName] == true
end

local v2 = {}

function PoolVip.OwnsAnyAsync(value: number?)
	if typeof(value) ~= "number" or value <= 0 then
		return false
	end

	if Players:GetPlayerByUserId(value) and Profiles.GetPlayerReplica((tostring(value))) then
		return PoolVip.Owns(value)
	end

	local v3 = v2[value]

	if v3 and os.clock() - v3.At < 600 then
		return v3.Owns
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(value, POOL_VIP_PASS_INFO.gamepassId)
	end)

	if not success then
		return false
	end

	local owns = result == true
	v2[value] = { Owns = owns, At = os.clock() }

	return owns
end

function PoolVip.ForSeat(p): boolean
	return typeof(p) == "table" and p.Vip == true
end

local function escape(value: string) -- 1 equivalent call inferred from this helper
	return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"))
end

function PoolVip.Format(p: string, flag: boolean?)
	local v3 = escape(tostring(p)) -- inferred equivalent call

	if flag == true then
		return v .. " " .. v3
	end

	return v3
end

function PoolVip:Apply(p: string, flag: boolean?)
	if not self then
		return
	end

	self.RichText = true
	self.Text = PoolVip.Format(p, flag)
end

return PoolVip