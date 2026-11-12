local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Galaxy Cue T4",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Galaxy set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Galaxy_Cue_Tier_4",
	cue = "Galaxy_Cue_Tier_4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Galaxy Cue T4",
	labelBottom = "",
	image = ""
}