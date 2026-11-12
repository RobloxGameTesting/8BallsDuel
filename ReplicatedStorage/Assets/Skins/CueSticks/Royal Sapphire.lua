local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Royal Sapphire",
	description = "",
	info = "Info",
	infoLink = "Exclusive item for inviting a friend to 8 Ball Duels!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Gold_Sapphire_Tier_4",
	cue = "Gold_Sapphire_Tier_4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Royal Sapphire",
	labelBottom = "",
	image = ""
}