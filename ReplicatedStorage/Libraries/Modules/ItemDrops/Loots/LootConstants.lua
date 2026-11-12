local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.ItemDrops.Loots.LootTypes)

return {
	DESPAWN_TIME = 10,
	DISPLAY_DURATION = 5,
	DISPLAY_ICONS = {
		Coin = "rbxassetid://9243773983",
		Diamond = "rbxassetid://9243774632",
		BoostCapacity = "rbxassetid://73835362698588",
		BoostDamage = "rbxassetid://102895576910400",
		BoostLuck = "rbxassetid://139821319787819",
		BoostPickaxe = "rbxassetid://126359252839456",
		BoostWalkspeed = "rbxassetid://119024875197323"
	},
	DROP_ICONS = {
		Coin = "rbxassetid://9243773341",
		Diamond = "rbxassetid://9243772178",
		BoostCapacity = "rbxassetid://73835362698588",
		BoostDamage = "rbxassetid://102895576910400",
		BoostLuck = "rbxassetid://139821319787819",
		BoostPickaxe = "rbxassetid://126359252839456",
		BoostWalkspeed = "rbxassetid://119024875197323"
	},
	OFFSETS = {
		Coin = Vector3.new(0, 0, 0),
		Diamond = Vector3.new(0, 2, 0),
		BoostCapacity = Vector3.new(0, 2, 0),
		BoostDamage = Vector3.new(0, 2, 0),
		BoostLuck = Vector3.new(0, 2, 0),
		BoostPickaxe = Vector3.new(0, 2, 0),
		BoostWalkspeed = Vector3.new(0, 2, 0)
	}
}