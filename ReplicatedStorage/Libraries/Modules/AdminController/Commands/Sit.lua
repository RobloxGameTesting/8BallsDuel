local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Sit",
	commandType = "Server",
	searchTerms = { "Sit" },
	icon = "rbxassetid://118053631502989",
	layoutOrder = 200,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerList", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				local userId = tostring(v.UserId)
				local character = v.Character
				local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

				if userId ~= p and humanoid then
					humanoid.Sit = true
				end
			end

			return "Admin seated <font color=\"#FF0000\">everyone</font>!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			local character = playerByUserId and playerByUserId.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				humanoid.Sit = true
			end

			return `Admin seated <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
		end
	end
}