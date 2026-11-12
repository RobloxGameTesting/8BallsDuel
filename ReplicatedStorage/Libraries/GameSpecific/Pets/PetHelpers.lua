local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
game:GetService("Players")
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local Probability = require(ReplicatedStorage.Libraries.Modules.Probability)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)

RunService:IsServer()
local Pets = ReplicatedStorage.Assets.Skins.Pets
local PetHelpers = {}

function PetHelpers.GetFunctionsModule(p)
	local child = Pets:FindFirstChild(p.npc)
	local functions = child and child:FindFirstChild("Functions")

	assert(child, "Module not found for " .. p.npc)
	assert(functions, "Function module not found for " .. p.npc)

	local module = require(functions)

	return module
end

function PetHelpers.GetModule(p)
	local child = Pets:FindFirstChild(p.npc)

	assert(child, "Module not found for " .. p.npc)

	local module = require(child)

	return module
end

function PetHelpers.GeneratePet(nickname)
	local itemData = InventoryHelpers.GetItemData("Pets", nickname)
	local integer = Random.new():NextInteger(itemData.age.min, itemData.age.max)
	local v = integer / itemData.age.max
	Random.new():NextNumber(itemData.weight.min, itemData.weight.max)
	local v2 = math.clamp(v * itemData.weight.max, itemData.weight.min, itemData.weight.max)
	local weight = v2 + Random.new():NextNumber(-v2 / 10, v2 / 10)

	return {
		item = nickname,
		nickname = nickname,
		gender = Probability.GetItem(itemData.genderChance),
		style = Probability.GetItem(itemData.styleChance),
		weight = weight,
		age = integer,
		experience = 0,
		locked = false,
		created = os.time()
	}
end

return PetHelpers