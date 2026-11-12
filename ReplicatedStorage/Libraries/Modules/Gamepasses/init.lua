local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local MonetizationHelper = require(ReplicatedStorage.Libraries.Helpers.MonetizationHelper)

local isServer = RunService:IsServer()
local bindableEvent = Instance.new("BindableEvent")

local Gamepasses = {
	gamepasses = { [1856020514] = "NoCooldown", [1982486441] = "WorldPass", [2001404253] = "VIP" },
	Bought = bindableEvent.Event
}

function Gamepasses.Init(_)
	local function init(p)
		local userId = tostring(p.UserId)
		local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)

		for k, gamepass in Gamepasses.gamepasses do
			if not MonetizationHelper.UserOwnsGamepass(userId, k) then
				continue
			end

			Gamepasses:Apply(p, k)

			if isServer then
				v:Write("Gamepasses", gamepass, true)
			end
		end
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
		local userId = tostring(p.UserId)

		if p3 then
			Gamepasses:Apply(p, p2)

			if isServer then
				local idToName = Gamepasses:IdToName(p2)
				local v = idToName and Profiles.GetPlayerReplica(userId)

				if v then
					v:Write("Gamepasses", idToName, true)
				end
			end

			bindableEvent:Fire(p, p2)
		end
	end)

	if isServer then
		Players.PlayerAdded:Connect(function(player)
			init(player)
		end)

		for _, v in Players:GetPlayers(), nil, nil do
			init(v)
		end
	else
		init(Players.LocalPlayer)
	end

	Players.PlayerRemoving:Connect(function(player)
		Gamepasses:Clear(player)
	end)
end

function Gamepasses:IdToName(p)
	return self.gamepasses[p]
end

function Gamepasses:Owns(p, p2)
	local userId = tostring(p.UserId)
	return (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data.gamepasses[self:IdToName(p2)]
end

function Gamepasses:Apply(p, p2)
	local idToName = self:IdToName(p2)

	if not idToName then
		return
	end

	local child = script:FindFirstChild(idToName)

	if child then
		local module = require(child)
		module(p)
	end
end

function Gamepasses:Clear(p)
	tostring(p.UserId)
end

return Gamepasses