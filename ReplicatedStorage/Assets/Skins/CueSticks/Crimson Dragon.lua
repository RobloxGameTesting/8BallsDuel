local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Crimson Dragon",
	description = "Obsidian with a purple matter core.",
	info = "Info",
	infoLink = "Unlock by getting lucky from a card flip!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Crimson_Dragon_Tier_2",
	cue = "Crimson_Dragon_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Crimson Dragon",
	labelBottom = "120000",
	image = ""
}