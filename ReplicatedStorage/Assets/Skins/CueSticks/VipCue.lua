local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "VIP Cue",
	description = "",
	info = "Info",
	infoLink = "Exclusive to the VIP gamepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "VIP_Cue",
	cue = "VIP_Cue",
	rarity = function(): string
		return "TierRobux"
	end,
	chance = 1,
	labelTop = "VIP Cue",
	labelBottom = "",
	image = ""
}