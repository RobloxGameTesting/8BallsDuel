local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Starter Cue",
	description = "The house cue. Chipped tip, honest roll -- every player starts here.",
	info = "Info",
	infoLink = "Every player starts with this cue.",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Starter",
	cue = "Starter",
	rarity = function(): string
		return "Tier1"
	end,
	chance = 40,
	labelTop = "Starter",
	labelBottom = "Cue",
	image = ""
}