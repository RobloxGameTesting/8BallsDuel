local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Spooky Cue T4",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Spooky set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Spooky_Tier_4_Cue",
	cue = "Spooky_Tier_4_Cue",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Spooky Cue T4",
	labelBottom = "",
	image = ""
}