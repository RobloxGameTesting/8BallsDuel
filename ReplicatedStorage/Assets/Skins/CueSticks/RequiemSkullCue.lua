local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Requiem Skull Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Requiem_Skull_Cue_T3",
	cue = "Requiem_Skull_Cue_T3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Requiem Skull Cue",
	labelBottom = "",
	image = ""
}