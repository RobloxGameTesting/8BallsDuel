local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Bloomcrown Spring",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Bloomcrown_Spring_T2",
	cue = "Bloomcrown_Spring_T2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Bloomcrown Spring",
	labelBottom = "",
	image = ""
}