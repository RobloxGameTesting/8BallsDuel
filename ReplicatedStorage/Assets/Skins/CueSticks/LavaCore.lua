local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Lava Core",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Galaxy battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Lava_Core_Tier_4",
	cue = "Lava_Core_Tier_4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Lava Core",
	labelBottom = "",
	image = ""
}