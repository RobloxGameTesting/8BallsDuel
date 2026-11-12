local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Archer's Rest",
	description = "Tournament taper. The prediction line runs almost to the far cushion.",
	info = "Coins",
	infoLink = 25000,
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "ArchersRest",
	cue = "Archer",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 3,
	labelTop = "Archer's Rest",
	labelBottom = "25000",
	image = ""
}