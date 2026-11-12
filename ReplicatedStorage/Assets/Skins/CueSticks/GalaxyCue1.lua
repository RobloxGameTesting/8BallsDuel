local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Galaxy Cue T1",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Galaxy set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Galaxy_Cue_Tier_1",
	cue = "Galaxy_Cue_Tier_1",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Galaxy Cue",
	labelBottom = "",
	image = ""
}