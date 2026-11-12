local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

return {
	TakeDamage = Sounds.new({ "Feel", "TakeDamage" }),
	Hover = Sounds.new({ "UserInterface", "Hover" }),
	Click = Sounds.new({ "UserInterface", "Click" }),
	MenuOpen = Sounds.new({ "UserInterface", "MenuOpen" }),
	Serve = Sounds.new({ "UserInterface", "MenuOpen" }),
	Tier1 = Sounds.new({ "Loot", "Tier1" }),
	Tier2 = Sounds.new({ "Loot", "Tier2" }),
	Tier3 = Sounds.new({ "Loot", "Tier3" }),
	Tier4 = Sounds.new({ "Loot", "Tier4" }),
	Tier5 = Sounds.new({ "Loot", "Tier5" }),
	Tier6 = Sounds.new({ "Loot", "Tier6" }),
	Tier7 = Sounds.new({ "Loot", "Tier7" }),
	Tier8 = Sounds.new({ "Loot", "Tier8" }),
	PurchasePrompt = Sounds.new({ "UserInterface", "Transactions", "Starterpack" }),
	ZombieHit = Sounds.new({ "Feel", "Enchant" }, nil),
	Headmarker = Sounds.new({ "Feel", "Headmarker" }, nil),
	Hitmarker = Sounds.new({ "Feel", "Hitmarker" }, nil)
}