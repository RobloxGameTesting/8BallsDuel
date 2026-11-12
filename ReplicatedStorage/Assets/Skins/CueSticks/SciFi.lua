local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Sci-Fi",
	description = "",
	info = "Info",
	infoLink = "Exclusive item for hitting 500 likes!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Ion_Rift_Tier_3",
	cue = "Ion_Rift_Tier_3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Sci-Fi",
	labelBottom = "",
	image = ""
}