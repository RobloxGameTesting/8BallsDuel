local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Briarwood",
	description = "Turned briar with a brass collar. Steadier line than anything in the rack.",
	info = "Coins",
	infoLink = 500,
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Briarwood",
	cue = "Briar",
	rarity = function(): string
		return "Tier2"
	end,
	chance = 25,
	labelTop = "Briarwood",
	labelBottom = "500",
	image = ""
}