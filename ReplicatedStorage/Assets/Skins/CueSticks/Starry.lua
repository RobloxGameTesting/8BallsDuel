local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Starry",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Galaxy battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Starry_Eyes_Tier_2",
	cue = "Starry_Eyes_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Starry",
	labelBottom = "",
	image = ""
}