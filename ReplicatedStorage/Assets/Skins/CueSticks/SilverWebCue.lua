local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Silver Web Cue",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Silver_Web_Cue_T2",
	cue = "Silver_Web_Cue_T2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Silver Web Cue",
	labelBottom = "",
	image = ""
}