local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Blue Laminate",
	description = "Inlaid at the butt and balanced an inch forward. Rewards a smooth stroke.",
	info = "Coins",
	infoLink = 5000,
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "IvoryInlay",
	cue = "Ivory",
	rarity = function(): string
		return "Tier2"
	end,
	chance = 15,
	labelTop = "Blue Laminate",
	labelBottom = "5000",
	image = ""
}