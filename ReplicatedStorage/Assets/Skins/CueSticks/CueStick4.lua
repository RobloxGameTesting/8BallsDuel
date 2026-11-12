local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Green Charm",
	description = "Dark-stained ash. Long sight line and enough weight to open a rack.",
	info = "Info",
	infoLink = "Unlocked from the starter pack!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "ShadedAsh",
	cue = "Shaded",
	rarity = function(): string
		return "Tier3"
	end,
	chance = 10,
	labelTop = "Green Charm",
	labelBottom = "15000",
	image = ""
}