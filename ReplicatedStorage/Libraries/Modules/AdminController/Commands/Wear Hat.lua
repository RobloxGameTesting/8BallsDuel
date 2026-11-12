local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local isServer = RunService:IsServer()
local v = {
	[8] = "HatAccessory",
	[41] = "HairAccessory",
	[42] = "FaceAccessory",
	[43] = "NeckAccessory",
	[44] = "ShouldersAccessory",
	[45] = "FrontAccessory",
	[46] = "BackAccessory",
	[47] = "WaistAccessory"
}

local v2 = {
	AccessoryBlob = function(p)
		return p.AccessoryBlob
	end,
	HatAccessory = function(p)
		return p.HatAccessory
	end,
	HairAccessory = function(p)
		return p.HairAccessory
	end,
	FaceAccessory = function(p)
		return p.FaceAccessory
	end,
	NeckAccessory = function(p)
		return p.NeckAccessory
	end,
	ShouldersAccessory = function(p)
		return p.ShouldersAccessory
	end,
	FrontAccessory = function(p)
		return p.FrontAccessory
	end,
	BackAccessory = function(p)
		return p.BackAccessory
	end,
	WaistAccessory = function(p)
		return p.WaistAccessory
	end
}

local v3 = {
	AccessoryBlob = function(p, accessoryBlob)
		p.AccessoryBlob = accessoryBlob
	end,
	HatAccessory = function(p, hatAccessory)
		p.HatAccessory = hatAccessory
	end,
	HairAccessory = function(p, hairAccessory)
		p.HairAccessory = hairAccessory
	end,
	FaceAccessory = function(p, faceAccessory)
		p.FaceAccessory = faceAccessory
	end,
	NeckAccessory = function(p, neckAccessory)
		p.NeckAccessory = neckAccessory
	end,
	ShouldersAccessory = function(p, shouldersAccessory)
		p.ShouldersAccessory = shouldersAccessory
	end,
	FrontAccessory = function(p, frontAccessory)
		p.FrontAccessory = frontAccessory
	end,
	BackAccessory = function(p, backAccessory)
		p.BackAccessory = backAccessory
	end,
	WaistAccessory = function(p, waistAccessory)
		p.WaistAccessory = waistAccessory
	end
}

return {
	command = "Wear Hat",
	commandType = "Server",
	searchTerms = { "Wear", "Hat", "Accessory", "Clothing" },
	icon = "rbxassetid://86811836942553",
	layoutOrder = 269,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil },
		{ optionType = "TextBox", header = "Input item Id" }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		local item = list[1]
		local item2 = list[2]
		local v4 = tonumber((string.gsub(item2, "%D", "")))

		if not isServer then
			return ""
		end

		if not v4 then
			return "Error"
		end

		local productInfo = MarketplaceService:GetProductInfo(v4)

		if not productInfo then
			return "Error"
		end

		local v5 = v[productInfo.AssetTypeId]

		if not v5 then
			return "No accessory type id found"
		end

		local function apply(player)
			local character = player and player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			local humanoidDescription = humanoid:FindFirstChildWhichIsA("HumanoidDescription")

			if not (humanoidDescription and humanoid) then
				return
			end

			local clone = humanoidDescription:Clone()
			local v6 = v2[v5](clone)
			local v7

			if v6 == "" then
				v7 = v4
			else
				v7 = v6 .. `, {v4}`
			end

			v3[v5](clone, v7)

			local success, result = pcall(function()
				humanoid:ApplyDescriptionAsync(clone)
			end)

			if not success then
				error(result)
			end
		end

		if item == "Everyone" then
			for _, v6 in Players:GetPlayers(), nil, nil do
				tostring(v6.UserId)

				apply(v6)
			end

			return "Admin gave <font color=\"#FF0000\">everyone</font> a hat!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId)
			return `Admin gave <font color="#FF0000">{playerByUserId.DisplayName}</font> a hat!`
		end
	end
}