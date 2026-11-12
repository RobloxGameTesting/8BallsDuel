local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Ironclad Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass, or win it from a country lootbox!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Ironclad_Cue_T4",
	cue = "Ironclad_Cue_T4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Ironclad Cue",
	labelBottom = "",
	image = ""
}