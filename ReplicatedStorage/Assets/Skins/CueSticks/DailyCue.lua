local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Daily Cue",
	description = "Seven days straight earns this one.",
	info = "Info",
	infoLink = "No longer obtainable",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Daily_Cue",
	cue = "Daily_Cue",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Daily Cue",
	labelBottom = "0",
	image = ""
}