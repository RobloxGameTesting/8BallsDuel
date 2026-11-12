local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Gilded Archer",
	description = "Gold-leafed and absurd. Plays exactly as well as it looks.",
	info = "Coins",
	infoLink = 50000,
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "WornHire",
	cue = "Gilded",
	rarity = function(): string
		return "Tier5"
	end,
	chance = 1,
	labelTop = "Gilded Archer",
	labelBottom = "50000",
	image = ""
}