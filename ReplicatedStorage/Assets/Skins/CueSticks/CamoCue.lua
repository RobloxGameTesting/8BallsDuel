local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Camo Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass, or win it from a country lootbox!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Camo_Cue_T1",
	cue = "Camo_Cue_T1",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Camo Cue",
	labelBottom = "",
	image = ""
}