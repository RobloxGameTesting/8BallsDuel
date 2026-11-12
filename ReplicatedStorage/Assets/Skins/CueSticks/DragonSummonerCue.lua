local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Dragon Summoner Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass, 7 daily rewards in a row, or a country lootbox!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Dragon_Summoner_Cue_T4",
	cue = "Dragon_Summoner_Cue_T4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Dragon Summoner Cue",
	labelBottom = "",
	image = ""
}