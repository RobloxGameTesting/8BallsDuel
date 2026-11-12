local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Head Scale",
	commandType = "Server",
	searchTerms = { "Head" },
	icon = "rbxassetid://97846828969242",
	layoutOrder = 82,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{ optionType = "MultiplePlayerList" },
		{ optionType = "TextBox", header = "Select Head Scale" }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local item = list[1]
		local item2 = list[2]
		local headScale = math.clamp(tonumber((string.gsub(item2, "%D", ""))), 0.5, 20)

		if not headScale then
			return "Error"
		end

		local function apply(playerByUserId)
			local character = playerByUserId and playerByUserId.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			local humanoidDescription = humanoid:FindFirstChildWhichIsA("HumanoidDescription")

			if not (humanoidDescription and humanoid) then
				return
			end

			local clone = humanoidDescription:Clone()
			clone.HeadScale = headScale

			local success, result = pcall(function()
				humanoid:ApplyDescriptionAsync(clone)
			end)

			if not success then
				error(result)
			end
		end

		for _, v in item do
			apply(Players:GetPlayerByUserId(v))
		end

		return `Admin set head scale to {headScale} for some players!`
	end
}