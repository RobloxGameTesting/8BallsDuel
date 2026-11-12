local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Golden Core Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass, or win it from a country lootbox!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Golden_Core_Cue_T3",
	cue = "Golden_Core_Cue_T3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Golden Core Cue",
	labelBottom = "",
	image = ""
}