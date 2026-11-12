local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Spider Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from a trickshot star gift box!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Spider_Cue_Tier_1",
	cue = "Spider_Cue_Tier_1",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Spider Cue",
	labelBottom = "",
	image = ""
}