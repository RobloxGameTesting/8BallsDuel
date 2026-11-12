local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Galaxy Cue T5",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Galaxy set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Galaxy_Cue_Tier_5",
	cue = "Galaxy_Cue_Tier_5",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Galaxy Cue T5",
	labelBottom = "",
	image = ""
}