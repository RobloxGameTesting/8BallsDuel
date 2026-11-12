local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Longblade",
	description = "",
	info = "Info",
	infoLink = "Unlocked from a trickshot star gift box!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Longblade_Tier_2",
	cue = "Longblade_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Longblade",
	labelBottom = "",
	image = ""
}