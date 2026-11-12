local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local SkillTreeConstants = require(ReplicatedStorage.Libraries.Constants.SkillTreeConstants)

local SkillTreeHelper = {}

function SkillTreeHelper.HasRequirements(p: string, p2): boolean
	local playerReplica = Profiles.GetPlayerReplica(p)

	if not playerReplica then
		return false
	end

	assert(p2.requires, "SkillData doesn't have requires table")

	for _, Require in p2.requires do
		if not table.find(playerReplica.Data.skillTree, Require) then
			return false
		end
	end

	return true
end

function SkillTreeHelper.FindSkillById(p: string)
	for _, v in SkillTreeConstants.SKILL_TREES do
		local v2 = v[p]

		if v2 then
			return v2
		end
	end

	return nil
end

function SkillTreeHelper.SkillTrace(p: string)
	local function recurse(p2: string, list)
		local skill = SkillTreeHelper.FindSkillById(p2)

		table.insert(list, p2)

		if #skill.requires > 0 then
			return recurse(skill.requires[1], list)
		end

		return list
	end

	return recurse(p, {})
end

function SkillTreeHelper.IsUpNext(p: string, p2: string): boolean
	local playerReplica = Profiles.GetPlayerReplica(p)

	if not playerReplica then
		return false
	end

	local copy = TableHelper:DeepCopy(SkillTreeHelper.FindSkillById(p2).requires)

	for _, v in copy do
		local index = table.find(playerReplica.Data.skillTree, v)

		if index then
			table.remove(copy, index)
		end
	end

	return #copy == 0
end

function SkillTreeHelper.ParseLevel(p: string, p2: string)
	local playerReplica = Profiles.GetPlayerReplica(p)

	if not playerReplica then
		return 0
	end

	local v = 0

	for _, v2 in playerReplica.Data.skillTree do
		if not string.find(v2, p2) then
			continue
		end

		local v3 = tonumber((string.gsub(v2, p2, "")))

		if v3 and v < v3 then
			v = v3
		end
	end

	return v
end

function SkillTreeHelper.HasSkill(p: string, p2: string): boolean
	local playerReplica = Profiles.GetPlayerReplica(p)

	if not playerReplica then
		return false
	end

	if table.find(playerReplica.Data.skillTree, p2) then
		return true
	end

	return false
end

function SkillTreeHelper.GetMultiMine(p)
	return 1 + SkillTreeHelper.ParseLevel(p, "MultiMine")
end

function SkillTreeHelper.GetGemDuplicator(p)
	return 1 + (SkillTreeHelper.HasSkill(p, "GemDuplicator") and 1 or 0)
end

function SkillTreeHelper.GetFriendMoney(p: string)
	return 0 + SkillTreeHelper.ParseLevel(p, "MineDistance")
end

return SkillTreeHelper