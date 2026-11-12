local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Dreadlight Pumpkin",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Dreadlight_Pumpkin_T4",
	cue = "Dreadlight_Pumpkin_T4",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Dreadlight Pumpkin",
	labelBottom = "",
	image = ""
}