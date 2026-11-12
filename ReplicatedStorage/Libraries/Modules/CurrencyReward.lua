local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Modules"):WaitForChild("Profiles"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Gamepasses = require(ReplicatedStorage2:WaitForChild("Libraries"):WaitForChild("Modules"):WaitForChild("Gamepasses"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ServerHelpers = require(ReplicatedStorage3:WaitForChild("Libraries"):WaitForChild("Helpers"):WaitForChild("ServerHelpers"))
local isServer = RunService:IsServer()

local CurrencyReward = {
	Spike = { amount = 5, reason = "Spike", canMultiply = true },
	Receive = { amount = 8, reason = "Receive", canMultiply = true },
	Ace = { amount = 20, reason = "Ace", canMultiply = true },
	Assist = { amount = 20, reason = "Assist", canMultiply = true },
	Block = { amount = 25, reason = "Stuff block", canMultiply = true },
	Scored = { amount = 18, reason = "Scored", canMultiply = true },
	PlayPickupGame = { amount = 25, reason = "Play Pickup Game", canMultiply = true },
	PlayFor1Minute = { amount = 12, reason = "Played game", canMultiply = true }
}

function CurrencyReward.Gain(_, p, p2)
	if not (isServer and ServerHelpers:GetServerType() ~= "PrivateServer") then
		return 0
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(p.UserId)))

	if not playerReplica then
		return 0
	end

	local v = p2.canMultiply and Gamepasses:Owns(p, 1038299020) and 1.5 or 1
	local v2 = p2.canMultiply and playerReplica.Data.boostCurrency > 0 and 1.5 or 1
	local v3 = math.round(p2.amount * v * v2)
	playerReplica:Write("Currency1", v3 * 2)
	return v3
end

return CurrencyReward