local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()
local v = {
	["Very Light"] = Color3.fromRGB(255, 224, 189),
	Light = Color3.fromRGB(241, 194, 125),
	["Light Medium"] = Color3.fromRGB(224, 172, 105),
	Medium = Color3.fromRGB(198, 134, 66),
	["Medium Tan"] = Color3.fromRGB(173, 112, 64),
	Tan = Color3.fromRGB(141, 85, 36),
	["Medium Dark"] = Color3.fromRGB(120, 72, 42),
	Dark = Color3.fromRGB(92, 51, 23),
	["Very Dark"] = Color3.fromRGB(58, 34, 17),
	Red = Color3.fromRGB(255, 0, 0),
	Blue = Color3.fromRGB(0, 85, 255),
	Green = Color3.fromRGB(0, 170, 0),
	Yellow = Color3.fromRGB(255, 221, 0),
	Orange = Color3.fromRGB(255, 140, 0),
	Purple = Color3.fromRGB(128, 0, 128),
	Pink = Color3.fromRGB(255, 105, 180),
	Brown = Color3.fromRGB(101, 67, 33),
	Black = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Gray = Color3.fromRGB(128, 128, 128)
}

local Skin = {
	command = "Skin Colour",
	commandType = "Server",
	searchTerms = { "Skin" },
	icon = "rbxassetid://88146064142990",
	layoutOrder = 210,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "List", extra = {} },
		{ optionType = "PlayerList", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]
		local item2 = list[2]

		local function apply(player) -- 1 equivalent call inferred from this helper
			local character = player.Character
			local bodyColors = character and character:FindFirstChildWhichIsA("BodyColors")

			if not bodyColors then
				return
			end

			local v2 = v[item]

			if not v2 then
				return
			end

			bodyColors.HeadColor3 = v2
			bodyColors.TorsoColor3 = v2
			bodyColors.LeftArmColor3 = v2
			bodyColors.RightArmColor3 = v2
			bodyColors.LeftLegColor3 = v2
			bodyColors.RightLegColor3 = v2
		end

		if item2 == "Everyone" then
			for _, v2 in Players:GetPlayers(), nil, nil do
				if tostring(v2.UserId) ~= p then
					apply(v2) -- inferred equivalent call
				end
			end

			return `Admin set walkspeed to {item} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			local character = playerByUserId.Character
			local bodyColors = character and character:FindFirstChildWhichIsA("BodyColors")

			local v2 = bodyColors and v[item]

			if v2 then
				bodyColors.HeadColor3 = v2
				bodyColors.TorsoColor3 = v2
				bodyColors.LeftArmColor3 = v2
				bodyColors.RightArmColor3 = v2
				bodyColors.LeftLegColor3 = v2
				bodyColors.RightLegColor3 = v2
			end

			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s walkspeed to {item}!`
		end
	end
}

for k, _ in v do
	table.insert(Skin.options[1].extra, k)
end

return Skin