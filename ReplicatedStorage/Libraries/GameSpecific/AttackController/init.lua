local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
game:GetService("HttpService")
require(script.AttackControllerTypes)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local AttackControllerHelpers = require(script.AttackControllerHelpers)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)

local AttackController = {}

function AttackController.new(enemyId: string, spray)
	local v = {
		enemyId = enemyId,
		spray = spray,
		cooldown = 0,
		timeElapsed = 0,
		shootIndex = 1,
		prevStatus = nil,
		curStatus = nil
	}

	AttackController.Init(v)

	return v
end

function AttackController:Init()
	local spray = self.spray
	local spray2 = {}

	for i = 1, #spray do
		for _ = 1, spray[i].count do
			table.insert(spray2, TableHelper:DeepCopy(spray[i]))
		end
	end

	self.spray = spray2
end

function AttackController:Update(p, p2: number)
	local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)

	if not p.alerted then
		return
	end

	local v = self.spray[self.shootIndex]
	self.cooldown = v.cooldown
	self.timeElapsed += p2

	if self.timeElapsed >= self.cooldown then
		local v2 = p.model
			and p.model.PrimaryPart
			and CharacterHelper.GetClosestCharacter(p.model.PrimaryPart.Position, true)
		local v3 = v2 and v2[1]
		local character = v3 and v3.character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (v3 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		self.timeElapsed = 0

		local status = v.status

		self.prevStatus = self.newStatus
		self.newStatus = status

		local module = EnemyHelpers.GetModule(p)

		for _, v4 in v.pattern do
			local class = v4.class

			if class == "Bullet" then
				AttackControllerHelpers.CreateBullet(self, v4, module, v3)
			elseif class == "Ability" then
				AttackControllerHelpers.CreateAbility(self, v4, module, v3)
			end
		end

		local enemyById = Enemies._getEnemyById(self.enemyId)
		local functionsModule = EnemyHelpers.GetFunctionsModule(enemyById)

		if functionsModule.onShoot then
			functionsModule.onShoot(enemyById)
		end

		self.shootIndex += 1

		if self.shootIndex > #self.spray then
			self.shootIndex = 1
		end
	end
end

return AttackController