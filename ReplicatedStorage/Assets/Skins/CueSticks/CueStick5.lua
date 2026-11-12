local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Summer",
	description = "Matte black through the whole shaft. Vanishes against the cloth mid-stroke.",
	info = "Coins",
	infoLink = 10000,
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Summer",
	cue = "Summer",
	rarity = function(): string
		return "Tier3"
	end,
	chance = 6,
	labelTop = "Summer",
	labelBottom = "10000",
	image = ""
}