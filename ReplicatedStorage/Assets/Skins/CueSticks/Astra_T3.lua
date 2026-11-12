local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Astra Cue T3",
	description = "",
	info = "Info",
	infoLink = "Limited edition cue stick from the Astra set",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Astra_Cue_Tier_3",
	cue = "Astra_Cue_Tier_3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Astra Cue T3",
	labelBottom = "",
	image = ""
}