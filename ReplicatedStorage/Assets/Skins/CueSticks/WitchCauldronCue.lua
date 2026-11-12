local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Witch Cauldron Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Witch_Cauldron_Cue_T2",
	cue = "Witch_Cauldron_Cue_T2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Witch Cauldron Cue",
	labelBottom = "",
	image = ""
}