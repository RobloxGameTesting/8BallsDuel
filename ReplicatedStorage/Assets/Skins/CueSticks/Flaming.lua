local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Flaming",
	description = "",
	info = "Info",
	infoLink = "Unlocked from a trickshot star gift box!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Flaming_Tier_2",
	cue = "Flaming_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Flaming",
	labelBottom = "",
	image = ""
}