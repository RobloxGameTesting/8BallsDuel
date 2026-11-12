local Utils = require(script.Parent.Utils)
local Queue = require(script.Parent.Queue)
local LoaderConstants = require(script.Parent.LoaderConstants)

local GroupInfoUtils = {}

function GroupInfoUtils.createGroupInfo()
	return Utils.readonly({ scriptInfoMap = {}, packageScriptInfoMap = {}, packageSet = {} })
end

function GroupInfoUtils.groupPackageInfos(items, value)
	assert(type(items) == "table", "Bad packageInfoList")
	assert(type(value) == "string", "Bad replicationMode")

	local v = Queue.new()
	local set = {}

	for _, item in pairs(items) do
		if set[item] then
			continue
		end

		set[item] = true
		v:PushRight(item)
	end

	local v2 = GroupInfoUtils.createGroupInfo()
	local result = {}

	while not v:IsEmpty() do
		local v3 = v:PopLeft()

		if GroupInfoUtils.hasAnythingToReplicate(v3, value) then
			if GroupInfoUtils.canAddPackageInfoToGroup(v2, v3, value) then
				GroupInfoUtils.addPackageInfoToGroup(v2, v3, value)

				if LoaderConstants.GROUP_EACH_PACKAGE_INDIVIDUALLY then
					table.insert(result, v2)
					v2 = GroupInfoUtils.createGroupInfo()
				end
			elseif LoaderConstants.ALLOW_MULTIPLE_GROUPS then
				table.insert(result, v2)
				v2 = GroupInfoUtils.createGroupInfo()
				GroupInfoUtils.addPackageInfoToGroup(v2, v3, value)
			else
				GroupInfoUtils.addPackageInfoToGroup(v2, v3, value)

				error("Cannot add package to group")
			end
		end

		for k, _ in pairs(v3.dependencySet) do
			if set[k] then
				continue
			end

			set[k] = true
			v:PushRight(k)
		end
	end

	if next(v2.packageSet) then
		table.insert(result, v2)
	end

	return result
end

function GroupInfoUtils.hasAnythingToReplicate(p, p2): boolean
	return next(p.scriptInfoLookup[p2]) ~= nil
end

function GroupInfoUtils.canAddScriptInfoToGroup(p, p2, value, p3): boolean
	assert(type(p) == "table", "Bad groupInfo")
	assert(type(p2) == "table", "Bad scriptInfo")
	assert(type(value) == "string", "Bad scriptName")
	assert(type(p3) == "table", "Bad tempScriptInfoMap")

	local v = p3[value]

	if v and v ~= p2 then
		return false
	end

	local scriptInfo = p.scriptInfoMap[value]
	return not scriptInfo or scriptInfo == p2
end

function GroupInfoUtils.canAddPackageInfoToGroup(p, p2, value): boolean
	assert(type(p) == "table", "Bad groupInfo")
	assert(type(p2) == "table", "Bad packageInfo")
	assert(type(value) == "string", "Bad replicationMode")

	local v = {}

	for k, v2 in pairs(p2.scriptInfoLookup[value]) do
		if not GroupInfoUtils.canAddScriptInfoToGroup(p, v2, k, v) then
			return false
		end

		v[k] = v2
	end

	for k, _ in pairs(p2.dependencySet) do
		if p.packageSet[k] then
			continue
		end

		for k2, v2 in pairs(k.scriptInfoLookup[value]) do
			if not GroupInfoUtils.canAddScriptInfoToGroup(p, v2, k2, v) then
				return false
			end

			v[k2] = v2
		end
	end

	return true
end

function GroupInfoUtils.addScriptToGroup(p, value, p2)
	assert(type(p) == "table", "Bad groupInfo")
	assert(type(p2) == "table", "Bad scriptInfo")
	assert(type(value) == "string", "Bad scriptName")

	local scriptInfo = p.scriptInfoMap[value]

	if scriptInfo and scriptInfo ~= p2 then
		error(("Cannot add to package group, conflicting scriptInfo for %q already there"):format(value))
	end

	p.scriptInfoMap[value] = p2
end

function GroupInfoUtils.addPackageInfoToGroup(p, p2, p3)
	p.packageSet[p2] = true

	for k, v in pairs(p2.scriptInfoLookup[p3]) do
		GroupInfoUtils.addScriptToGroup(p, k, v)
		p.packageScriptInfoMap[k] = v
	end

	for k, _ in pairs(p2.dependencySet) do
		if p.packageSet[k] then
			continue
		end

		for k2, v in pairs(k.scriptInfoLookup[p3]) do
			GroupInfoUtils.addScriptToGroup(p, k2, v)
		end
	end
end

return GroupInfoUtils