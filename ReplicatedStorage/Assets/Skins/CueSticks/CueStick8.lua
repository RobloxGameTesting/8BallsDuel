local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Obsidian",
	description = "Obsidian with a purple matter core.",
	info = "Coins",
	infoLink = 150000,
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Obsidian",
	cue = "Obsidian",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Obsidian",
	labelBottom = "150000",
	image = ""
}