local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)

return {
	regions = { "Grass" },
	rarity = "Common",
	id = script.Name,
	instance = script.Pet,
	types = "Normal",
	configuration = {
		walkSpeed = 10,
		radius = { min = 20, max = 50 },
		wander = { behavior = "Random" },
		idle = {
			animations = { Backflip = 0, Roll = 0, None = 100 }
		}
	},
	maxHealth = 50,
	criticalChance = 10,
	moveset = {},
	catchChance = 50,
	genderChance = { Female = 50, Male = 50 },
	styleChance = { Normal = 99, Shiny = 1 },
	class = "Normal",
	weight = { min = 8, max = 15 },
	age = { min = 1, max = 18 },
	states = { "Spawn", "Idle", "Follow", "Wander" },
	initialState = "Spawn",
	animations = { idle = 132397312790661, walk = 129405210193591 },
	overlapAnimations = { attack = 70577658181580 },
	sounds = {
		attack = {
			id = { "Enemies", "Attack" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 10,
	currency1 = 2,
	currency2 = 0,
	experience = 4
}