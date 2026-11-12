local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyConstants)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables.ThrowableTypes)
local RunService = game:GetService("RunService")
local parentModule = require(script.Parent)
local ServerScriptService = game:GetService("ServerScriptService")
local Explosions = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions)
local WeaponAttacks = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponAttacks)
local WeaponHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionTypes)

local isServer = RunService:IsServer()

return {
	onDestroy = function(data)
		local module = parentModule.GetModule(data)

		if isServer then
			local Verification = require(ServerScriptService.Libraries.Modules.Verification)

			if data.ownerId then
				if module.explosive then
					local v = "Explosion" .. module.explosive

					Verification.Add(data.ownerId, v)
				end

				if module.fragment then
					for _, v in module.fragment.pattern do
						local v2 = "Bullet" .. v.bullet

						Verification.Add(data.ownerId, v2)
					end
				end
			end
		else
			local position = data.position

			if data.isOwner then
				if module.fragment then
					local position2 = data.position

					for _, v in module.fragment.pattern do
						local spread = module.fragment.spread
						local spreadY = module.fragment.spreadY
						local number = Random.new():NextNumber(spread.min, spread.max)
						local v2 = spreadY and Random.new():NextNumber(spreadY.min, spreadY.max) or 0

						local lookVector = (CFrame.new(position2) * CFrame.Angles(math.rad(v2), math.rad(v.angle + number), 0)).LookVector

						WeaponAttacks.CreateBullet(position2, lookVector, data.ownerId, v.bullet, data.weaponType)
					end
				end

				if module.explosive then
					local ownerId = data.ownerId
					local playerByUserId = Players:GetPlayerByUserId((tonumber(ownerId)))
					local masteryType = WeaponHelpers.GetModule({ weaponType = data.weaponType }).masteryType

					local v = {
						id = tostring(Random.new():NextInteger(1, 1000000)),
						loadId = "",
						maid = nil,
						masteryType = masteryType,
						hitList = {},
						explosionType = module.explosive,
						owner = playerByUserId,
						ownerId = tostring(playerByUserId.UserId),
						position = position,
						isOwner = true
					}

					print("Destroyed on the client sent to create explosion")
					Explosions.newClient(v)
				end
			end
		end
	end
}