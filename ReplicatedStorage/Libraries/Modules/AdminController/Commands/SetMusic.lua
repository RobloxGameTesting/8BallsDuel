local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")

local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Set Music",
	commandType = "Global",
	searchTerms = { "Music" },
	icon = "rbxassetid://139749037245348",
	layoutOrder = 110,
	maxActivationDistance = 1e999,
	cooldown = 10,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = {
				"None",
				"Halloween Horrors Waltz",
				"Bad Computer - Clarity",
				"Bad Computer - Destroy Me",
				"Dexter King - Only You (feat. Alexis Donn)",
				"Dexter King feat. Aviella - Get to Know You",
				"Dion Timmer - Shiawase",
				"Dion Timmer feat. Micah Martin - Internet Boy",
				"F.O.O.L & Midranger - Neon",
				"FWLR - Hot",
				"Noisestorm - Crab Rave",
				"Parry Gripp - Raining Tacos",
				"Pegboard Nerds & Tokyo Machine - Moshi",
				"Pegboard Nerds - Shaku",
				"Pixel Terror & EMELINE - Chroma",
				"Stonebank - What Are You Waiting For",
				"Tails & Juelz - Cobra",
				"Tokyo Machine - PLAY",
				"Vindata - Good 4 Me",
				"WRLD & Keepsake - Wishful Thinking"
			}
		}
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local item = list[1]

		workspace.Regions.Map:SetAttribute("Music", item)

		return `Admin set the song to {item}`
	end
}