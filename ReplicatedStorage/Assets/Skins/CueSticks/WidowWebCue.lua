local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Widow Web Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Widow_Web_Cue_T4",
	cue = "Widow_Web_Cue_T4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Widow Web Cue",
	labelBottom = "",
	image = ""
}