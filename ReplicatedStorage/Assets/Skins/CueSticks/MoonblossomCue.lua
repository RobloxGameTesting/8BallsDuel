local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Moonblossom Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from a trickshot star gift box!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Moonblossom_Cue_Tier_2",
	cue = "Moonblossom_Cue_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Moonblossom Cue",
	labelBottom = "",
	image = ""
}