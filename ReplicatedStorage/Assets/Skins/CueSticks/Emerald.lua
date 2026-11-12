local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Emerald",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Galaxy battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Emerald_Tier_2",
	cue = "Emerald_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Emerald",
	labelBottom = "",
	image = ""
}