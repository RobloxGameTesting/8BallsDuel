local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Spooky Cue T5",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Spooky set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Spooky_Tier_5_Cue",
	cue = "Spooky_Tier_5_Cue",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Spooky Cue T5",
	labelBottom = "",
	image = ""
}