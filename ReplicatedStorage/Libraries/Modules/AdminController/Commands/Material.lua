local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Material",
	commandType = "Server",
	searchTerms = { "Material" },
	icon = "rbxassetid://135265595103613",
	layoutOrder = 271,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = {
				"Plastic",
				"SmoothPlastic",
				"Neon",
				"Wood",
				"WoodPlanks",
				"Marble",
				"Basalt",
				"Slate",
				"CrackedLava",
				"Concrete",
				"Limestone",
				"Granite",
				"Pavement",
				"Brick",
				"Pebble",
				"Cobblestone",
				"Rock",
				"Sandstone",
				"CorrodedMetal",
				"DiamondPlate",
				"Foil",
				"Metal",
				"Grass",
				"LeafyGrass",
				"Sand",
				"Fabric",
				"Snow",
				"Mud",
				"Ground",
				"Asphalt",
				"Salt",
				"Ice",
				"Glacier",
				"Glass",
				"ForceField",
				"Water",
				"Cardboard",
				"Carpet",
				"CeramicTiles",
				"ClayRoofTiles",
				"RoofShingles",
				"Leather",
				"Plaster",
				"Rubber"
			}
		},
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]
		local item2 = list[2]

		local function apply(player)
			local character = player.Character

			if not (character and character:FindFirstChildWhichIsA("Humanoid")) then
				return
			end

			if item then
				for _, part in character:QueryDescendants("BasePart"), nil, nil do
					if part.Name ~= "HumanoidRootPart" and part:IsA("BasePart") then
						part.Material = item
					end
				end
			end
		end

		if item2 == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v)
				end
			end

			return `Admin set material to {item} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			apply(playerByUserId)
			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s material to {item}!`
		end
	end
}