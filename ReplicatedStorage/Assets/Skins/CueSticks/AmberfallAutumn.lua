local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Amberfall Autumn",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Amberfall_Autumn_T2",
	cue = "Amberfall_Autumn_T2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Amberfall Autumn",
	labelBottom = "",
	image = ""
}