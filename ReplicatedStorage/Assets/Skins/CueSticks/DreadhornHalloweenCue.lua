local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Dreadhorn Halloween Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Dreadhorn_Halloween_Cue_T5",
	cue = "Dreadhorn_Halloween_Cue_T5",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Dreadhorn Halloween Cue",
	labelBottom = "",
	image = ""
}