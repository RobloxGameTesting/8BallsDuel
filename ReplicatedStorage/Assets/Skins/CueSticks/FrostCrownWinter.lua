local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Frost Crown Winter",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Frost_Crown_Winter_T3",
	cue = "Frost_Crown_Winter_T3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Frost Crown Winter",
	labelBottom = "",
	image = ""
}