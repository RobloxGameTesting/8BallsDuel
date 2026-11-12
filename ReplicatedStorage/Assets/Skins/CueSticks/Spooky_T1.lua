local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Spooky Cue T1",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Spooky_Tier_1_Cue",
	cue = "Spooky_Tier_1_Cue",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Spooky Cue T1",
	labelBottom = "",
	image = ""
}