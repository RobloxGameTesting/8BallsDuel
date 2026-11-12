local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Neon",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Galaxy battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Gamer_Tier_1",
	cue = "Gamer_Tier_1",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Neon",
	labelBottom = "",
	image = ""
}