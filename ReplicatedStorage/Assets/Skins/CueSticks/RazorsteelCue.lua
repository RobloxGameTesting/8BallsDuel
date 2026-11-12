local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Razorsteel Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass, 3 daily rewards in a row, or a country lootbox!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Razorsteel_Cue_T2",
	cue = "Razorsteel_Cue_T2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Razorsteel Cue",
	labelBottom = "",
	image = ""
}