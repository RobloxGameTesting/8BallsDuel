local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Jungle",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Galaxy battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Jungle_Tier_2",
	cue = "Jungle_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Jungle",
	labelBottom = "",
	image = ""
}