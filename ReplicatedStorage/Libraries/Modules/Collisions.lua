local PhysicsService = game:GetService("PhysicsService")
game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	PhysicsService:RegisterCollisionGroup("Character")
	PhysicsService:RegisterCollisionGroup("NonCollidableCharacter")
	PhysicsService:RegisterCollisionGroup("Zombie")
	PhysicsService:RegisterCollisionGroup("Ragdoll")
	PhysicsService:RegisterCollisionGroup("CharacterOnlyBorder")
	PhysicsService:RegisterCollisionGroup("Viewmodel")
	PhysicsService:RegisterCollisionGroup("Throwable")

	PhysicsService:CollisionGroupSetCollidable("Character", "Default", true)
	PhysicsService:CollisionGroupSetCollidable("Character", "Zombie", true)
	PhysicsService:CollisionGroupSetCollidable("Character", "Ragdoll", true)
	PhysicsService:CollisionGroupSetCollidable("Character", "NonCollidableCharacter", false)
	PhysicsService:CollisionGroupSetCollidable("Character", "CharacterOnlyBorder", true)
	PhysicsService:CollisionGroupSetCollidable("Character", "Character", true)
	PhysicsService:CollisionGroupSetCollidable("Character", "Viewmodel", false)
	PhysicsService:CollisionGroupSetCollidable("Character", "Throwable", false)

	PhysicsService:CollisionGroupSetCollidable("Zombie", "Default", true)
	PhysicsService:CollisionGroupSetCollidable("Zombie", "CharacterOnlyBorder", false)
	PhysicsService:CollisionGroupSetCollidable("Zombie", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("Zombie", "NonCollidableCharacter", true)
	PhysicsService:CollisionGroupSetCollidable("Zombie", "Zombie", true)
	PhysicsService:CollisionGroupSetCollidable("Zombie", "Viewmodel", false)
	PhysicsService:CollisionGroupSetCollidable("Zombie", "Throwable", false)

	PhysicsService:CollisionGroupSetCollidable("CharacterOnlyBorder", "Default", true)
	PhysicsService:CollisionGroupSetCollidable("CharacterOnlyBorder", "NonCollidableCharacter", true)
	PhysicsService:CollisionGroupSetCollidable("CharacterOnlyBorder", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("CharacterOnlyBorder", "CharacterOnlyBorder", false)
	PhysicsService:CollisionGroupSetCollidable("CharacterOnlyBorder", "Viewmodel", false)
	PhysicsService:CollisionGroupSetCollidable("CharacterOnlyBorder", "Throwable", false)

	PhysicsService:CollisionGroupSetCollidable("NonCollidableCharacter", "Default", true)
	PhysicsService:CollisionGroupSetCollidable("NonCollidableCharacter", "NonCollidableCharacter", true)
	PhysicsService:CollisionGroupSetCollidable("NonCollidableCharacter", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("NonCollidableCharacter", "Viewmodel", false)
	PhysicsService:CollisionGroupSetCollidable("NonCollidableCharacter", "Throwable", false)

	PhysicsService:CollisionGroupSetCollidable("Ragdoll", "Default", true)
	PhysicsService:CollisionGroupSetCollidable("Ragdoll", "Ragdoll", false)
	PhysicsService:CollisionGroupSetCollidable("Ragdoll", "Viewmodel", false)
	PhysicsService:CollisionGroupSetCollidable("Ragdoll", "Throwable", false)

	PhysicsService:CollisionGroupSetCollidable("Viewmodel", "Default", false)
	PhysicsService:CollisionGroupSetCollidable("Viewmodel", "Viewmodel", true)
	PhysicsService:CollisionGroupSetCollidable("Viewmodel", "Throwable", false)

	PhysicsService:CollisionGroupSetCollidable("Throwable", "Default", true)
	PhysicsService:CollisionGroupSetCollidable("Throwable", "Throwable", false)
end

local Collisions = { currentCollision = {} }

function Collisions.AddToGroup(_, part, collisionGroup)
	if not part then
		return
	end

	if part:IsA("BasePart") then
		part.CollisionGroup = collisionGroup
		return
	end

	for _, part2 in part:GetDescendants(), nil, nil do
		if part2:IsA("BasePart") then
			part2.CollisionGroup = collisionGroup
		end
	end
end

return Collisions