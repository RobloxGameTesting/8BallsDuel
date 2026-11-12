local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

return {
	morning = Sounds.new({ "Gameplay", "Morning" }, nil),
	night = Sounds.new({ "Gameplay", "NightStartCustom" }, nil),
	armouryRestock = Sounds.new({ "Restock" }, nil),
	purchase = Sounds.new({ "Cash Register Sound" }, nil),
	tick = Sounds.new({ "UserInterface", "Tick" }, nil)
}