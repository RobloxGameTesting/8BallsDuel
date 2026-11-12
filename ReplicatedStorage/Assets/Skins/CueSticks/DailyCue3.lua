local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Day 3 Cue",
	description = "Three days in a row earns this one.",
	info = "Info",
	infoLink = "No longer obtainable",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Daily_Cue_3",
	cue = "Daily_Cue_3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Day 3 Cue",
	labelBottom = "0",
	image = ""
}