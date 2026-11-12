local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)

local userId = tostring(Players.LocalPlayer.UserId)

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local v = {
	piercing = {
		display = "Piercing",
		icon = { "rbxassetid://17335132320", 1 }
	},
	ricochet = {
		display = "Ricochet",
		icon = { "rbxassetid://17335132231", 1 }
	},
	accuracy = {
		display = "Accuracy",
		icon = { "rbxassetid://17334932030", 1 }
	},
	spread = {
		display = "Accuracy",
		icon = { "rbxassetid://17334932030", 1 }
	},
	cooldown = {
		display = "Cooldown",
		icon = { "rbxassetid://17334949122", 1 }
	},
	cooldownfinal = {
		display = "Cooldown",
		icon = { "rbxassetid://17334949122", 1 }
	},
	damage = {
		display = "Damage",
		icon = { "rbxassetid://17334882970", 1 }
	},
	damagetotal = {
		display = "Damage",
		icon = { "rbxassetid://17334882970", 1 }
	},
	damagebullets = {
		display = "Damage",
		icon = { "rbxassetid://17334882970", 1 }
	},
	damagesequence = {
		display = "Damage",
		icon = { "rbxassetid://17335167183", 1 }
	},
	firerate = {
		display = "Firerate",
		icon = { "rbxassetid://17334949122", 1 }
	},
	fireratebullets = {
		display = "Firerate",
		icon = { "rbxassetid://17334949122", 1 }
	},
	knockback = {
		display = "Knockback",
		icon = { "rbxassetid://17335136915", 1 }
	},
	pellets = {
		display = "Pellets",
		icon = { "rbxassetid://17334882843", 1 }
	},
	explosionknockback = {
		display = "Explosion Knockback",
		icon = { "rbxassetid://17335167064", 1 }
	},
	explosiondamage = {
		display = "Explosion Damage",
		icon = { "rbxassetid://17335167129", 1 }
	},
	explosionradius = {
		display = "Explosion Radius",
		icon = { "rbxassetid://17335166984", 1 }
	},
	firedamage = {
		display = "Fire Damage",
		icon = { "rbxassetid://17335176487", 1 }
	},
	firetime = {
		display = "Fire Time",
		icon = { "rbxassetid://17335176402", 1 }
	},
	recoil = {
		display = "Recoil",
		icon = { "rbxassetid://17335195113", 1 }
	},
	health = {
		display = "Health",
		icon = { "rbxassetid://17335206398", 1 }
	},
	walkspeed = {
		display = "Walk",
		icon = { "rbxassetid://17335206250", 1 }
	},
	jump = {
		display = "Jump",
		icon = { "rbxassetid://17335206315", 1 }
	},
	cost = {
		display = "Cost",
		icon = { "rbxassetid://17334943754", 1 }
	}
}
local Display = {}

function Display.Accuracy(_, p)
	local spray = p.spray
	local total = 0

	for _, v2 in spray do
		for _, v3 in v2.spread do
			total += math.abs(v3)
		end

		for _, v3 in v2.spreadY do
			total += math.abs(v3)
		end
	end

	return NumberHelper:Round(100 - total / #spray * 2, 1, false) .. "%"
end

function Display.Damage(_, p)
	local spray = p.spray
	local total = 0

	for _, v2 in spray do
		local count = #v2.pattern

		for _, v3 in v2.pattern do
			if v3.class == "Bullets" then
				total += InventoryHelpers.GetItemData("Bullets", v3.attackId).damage[0] / count
			elseif v3.class == "Swings" then
				total += InventoryHelpers.GetItemData("Swings", v3.attackId).damage[0] / count
			elseif v3.class == "Areas" then
				total += InventoryHelpers.GetItemData("Areas", v3.attackId).damage[0] / count
			end
		end
	end

	return (NumberHelper:Round(total / #spray, 1, false))
end

function Display.DamageSequence(_, p)
	local spray = p.spray
	local v2 = ""

	for k, v3 in spray do
		for _, v4 in v3.pattern do
			if v4.class == "Bullets" then
				v2 ..= InventoryHelpers.GetItemData("Bullets", v4.attackId).damage[0] + (p.damage or 0)
			elseif v4.class == "Swings" then
				v2 ..= InventoryHelpers.GetItemData("Swings", v4.attackId).damage[0] + (p.damage or 0)
			elseif v4.class == "Areas" then
				v2 ..= InventoryHelpers.GetItemData("Areas", v4.attackId).damage[0] + (p.damage or 0)
			end
		end

		if k ~= #spray then
			v2 ..= "/"
		end
	end

	return v2
end

function Display:Cooldown(p)
	local spray = p.spray
	local total = 0

	for _, v2 in spray do
		local v3 = #v2.pattern
		total += v2.cooldown / v3
	end

	return NumberHelper:Round(total / #spray, 3, false)
end

function Display:CooldownBullets(p)
	local spray = p.spray
	local total = 0

	for _, v2 in spray do
		total += v2.cooldown
	end

	return NumberHelper:Round(total / #spray, 3, false)
end

function Display:Firerate(p)
	return math.floor(60 / self:Cooldown(p) + 0.5) .. "/min"
end

function Display:FirerateBullets(p)
	local spray = p.spray
	return math.floor(60 / self:CooldownBullets(p) / #spray + 0.5) .. "/min"
end

function Display.Knockback(_, p)
	local spray = p.spray
	local total = 0

	for _, v2 in spray do
		local count = #v2.pattern

		for _, v3 in v2.pattern do
			if v3.class == "Bullets" then
				total += InventoryHelpers.GetItemData("Bullets", v3.attackId).knockback.distance[0] / count
			elseif v3.class == "Swings" then
				total += InventoryHelpers.GetItemData("Swings", v3.attackId).knockback.distance[0] / count
			elseif v3.class == "Areas" then
				total += InventoryHelpers.GetItemData("Areas", v3.attackId).knockback.distance[0] / count
			end
		end
	end

	return (NumberHelper:Round(total / #spray, 1, false))
end

function Display.Pellets(_, p)
	return #p.spray[1].pattern
end

function Display.Recoil(_, p)
	local spray = p.spray
	local v2 = 0

	for _, v3 in spray do
		local count = #v3.pattern
		v2 = v2 + v3.recoil.distance / count - (p.recoil or 0) / count
	end

	return NumberHelper:Round(v2 / #spray, 0, false)
end

function Display.ExplosionKnockback(_, p): number
	local _spray = p.spray

	return 0
end

function Display.ExplosionDamage(_, p): number
	local _spray = p.spray

	return 0
end

function Display.ExplosionRadius(_, p): number
	local _spray = p.spray

	return 0
end

function Display.FireDamage(_, p): number
	local _spray = p.spray

	return 0
end

function Display.FireTime(_, p): number
	local _spray = p.spray

	return 0
end

function Display.Piercing(_, p)
	for _, v2 in p.spray do
		for _, v3 in v2.pattern do
			if v3.class == "Bullets" then
				return InventoryHelpers.GetItemData("Bullets", v3.attackId).pierce
			end
		end
	end

	return false
end

function Display.Ricochet(_, p)
	for _, v2 in p.spray do
		for _, v3 in v2.pattern do
			if v3.class == "Bullets" then
				return InventoryHelpers.GetItemData("Bullets", v3.attackId).ricochet
			end
		end
	end

	return false
end

function Display.Cost(_, p)
	return p.cost
end

function Display.GetName(_, value)
	return v[string.lower(value)].display
end

function Display.GetIcon(_, value)
	local v2 = string.lower(value)
	return v[v2].icon[1], v[v2].icon[2]
end

return Display