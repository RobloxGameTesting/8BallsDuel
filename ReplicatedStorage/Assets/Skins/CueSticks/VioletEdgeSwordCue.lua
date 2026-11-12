local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Violet Edge Sword Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Violet_Edge_Sword_Cue_T3",
	cue = "Violet_Edge_Sword_Cue_T3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Violet Edge Sword Cue",
	labelBottom = "",
	image = ""
}