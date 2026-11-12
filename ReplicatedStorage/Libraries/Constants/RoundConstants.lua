local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.Profiles)

return {
	OUTBREAK_DATA = {
		{ requirement = 0, zombieId = "Zombie", zombieChance = 100, mapOffset = 35 },
		{ requirement = 250, zombieId = "Crawler", zombieChance = 30, mapOffset = 42 },
		{ requirement = 1000, zombieId = "Mimic", zombieChance = 30, mapOffset = 50 },
		{ requirement = 3500, zombieId = "Half Skin", zombieChance = 20, mapOffset = 58 },
		{ requirement = 8000, zombieId = "Hypnotize", zombieChance = 5, mapOffset = 65 },
		{ requirement = 18000, zombieId = "Grave Digger", zombieChance = 3, mapOffset = 72 },
		{ requirement = 35000, zombieId = "Two Head", zombieChance = 15, mapOffset = 78 },
		{ requirement = 85000, zombieId = "Charger", zombieChance = 5, mapOffset = 85 },
		{ requirement = 130000, zombieId = "Hazmat", zombieChance = 10, mapOffset = 92 },
		{ requirement = 240000, zombieId = "Tank", zombieChance = 5, mapOffset = 102 }
	},
	MAX_MONEY = 1e999,
	GAME_OVER_TIMER = 25,
	EVENT_CHANCES = { Nothing = 1 }
}