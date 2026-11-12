local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Solstice Summer",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Solstice_Summer_T3",
	cue = "Solstice_Summer_T3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Solstice Summer",
	labelBottom = "",
	image = ""
}