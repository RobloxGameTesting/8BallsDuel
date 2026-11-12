local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Emerald Fracture",
	description = "",
	info = "Info",
	infoLink = "Exclusive item for hitting 25,000 likes!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Emerald_Fracture_Tier_2",
	cue = "Emerald_Fracture_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Emerald Fracture",
	labelBottom = "",
	image = ""
}