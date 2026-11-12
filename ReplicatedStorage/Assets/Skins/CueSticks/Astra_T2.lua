local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Astra Cue T2",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Astra set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Astra_Cue_Tier_2",
	cue = "Astra_Cue_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Astra Cue T2",
	labelBottom = "",
	image = ""
}