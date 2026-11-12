local parent = script.Parent
local BounceTemplateUtils = require(script.Parent.BounceTemplateUtils)
local GroupInfoUtils = require(script.Parent.GroupInfoUtils)
local PackageInfoUtils = require(script.Parent.PackageInfoUtils)
local ScriptInfoUtils = require(script.Parent.ScriptInfoUtils)
local Utils = require(script.Parent.Utils)

local LoaderUtils = {}
LoaderUtils.Utils = Utils
LoaderUtils.ContextTypes = Utils.readonly({ CLIENT = "client", SERVER = "server" })

LoaderUtils.IncludeBehavior = Utils.readonly({
	NO_INCLUDE = "noInclude",
	INCLUDE_ONLY = "includeOnly",
	INCLUDE_SHARED = "includeShared"
})

function LoaderUtils.toWallyFormat(instance, p)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(p) == "boolean", "Bad isPlugin")

	local v = {}
	LoaderUtils.discoverTopLevelPackages(v, instance)
	LoaderUtils.injectLoader(v)

	local Plugin = p and ScriptInfoUtils.ModuleReplicationTypes.PLUGIN or ScriptInfoUtils.ModuleReplicationTypes.SHARED
	local v2 = {}
	local v3 = {}

	for _, v4 in pairs(v) do
		table.insert(v3, (PackageInfoUtils.getOrCreatePackageInfo(v4, v2, "", Plugin)))
	end

	PackageInfoUtils.fillDependencySet(v3)

	if p then
		local groupPackageInfos = GroupInfoUtils.groupPackageInfos(v3, ScriptInfoUtils.ModuleReplicationTypes.PLUGIN)

		local publishPackageInfoSet = LoaderUtils.getPublishPackageInfoSet(v3)

		local pluginPackages = Instance.new("Folder")
		pluginPackages.Name = "PluginPackages"

		LoaderUtils.reifyGroupList(
			groupPackageInfos,
			publishPackageInfoSet,
			pluginPackages,
			ScriptInfoUtils.ModuleReplicationTypes.PLUGIN
		)

		return pluginPackages
	else
		local groupPackageInfos = GroupInfoUtils.groupPackageInfos(v3, ScriptInfoUtils.ModuleReplicationTypes.CLIENT)
		local groupPackageInfos2 = GroupInfoUtils.groupPackageInfos(v3, ScriptInfoUtils.ModuleReplicationTypes.SERVER)
		local groupPackageInfos3 = GroupInfoUtils.groupPackageInfos(v3, ScriptInfoUtils.ModuleReplicationTypes.SHARED)

		local publishPackageInfoSet = LoaderUtils.getPublishPackageInfoSet(v3)

		local packages = Instance.new("Folder")
		packages.Name = "Packages"

		local sharedPackages = Instance.new("Folder")
		sharedPackages.Name = "SharedPackages"

		local packages2 = Instance.new("Folder")
		packages2.Name = "Packages"

		LoaderUtils.reifyGroupList(
			groupPackageInfos,
			publishPackageInfoSet,
			packages,
			ScriptInfoUtils.ModuleReplicationTypes.CLIENT
		)
		LoaderUtils.reifyGroupList(
			groupPackageInfos2,
			publishPackageInfoSet,
			packages2,
			ScriptInfoUtils.ModuleReplicationTypes.SERVER
		)
		LoaderUtils.reifyGroupList(
			groupPackageInfos3,
			publishPackageInfoSet,
			sharedPackages,
			ScriptInfoUtils.ModuleReplicationTypes.SHARED
		)

		return packages, packages2, sharedPackages
	end
end

function LoaderUtils.isPackage(instance): boolean
	assert(typeof(instance) == "Instance", "Bad instance")

	for _, child in pairs(instance:GetChildren()) do
		if
			(child:IsA("Folder") or child:IsA("Camera"))
			and (child.Name == "Server" or child.Name == "Client" or child.Name == "Shared" or child.Name == ScriptInfoUtils.DEPENDENCY_FOLDER_NAME)
		then
			return true
		end
	end

	return false
end

function LoaderUtils.injectLoader(parents)
	for _, ancestor in pairs(parents) do
		if ancestor == parent or parent:IsDescendantOf(ancestor) then
			return
		end
	end

	table.insert(parents, parent)
end

function LoaderUtils.discoverTopLevelPackages(list, objectValue)
	assert(type(list) == "table", "Bad packages")
	assert(typeof(objectValue) == "Instance", "Bad instance")

	if LoaderUtils.isPackage(objectValue) then
		table.insert(list, objectValue)
	elseif objectValue:IsA("ObjectValue") then
		local value = objectValue.Value

		if value and LoaderUtils.isPackage(value) then
			table.insert(list, value)
		end
	else
		for _, child in pairs(objectValue:GetChildren()) do
			if child:IsA("Folder") or child:IsA("Camera") then
				LoaderUtils.discoverTopLevelPackages(list, child)
			elseif child:IsA("ObjectValue") then
				local value = child.Value

				if value and LoaderUtils.isPackage(value) then
					table.insert(list, value)
				end
			elseif child:IsA("ModuleScript") then
				table.insert(list, child)
			end
		end
	end
end

function LoaderUtils.reifyGroupList(items, items2, parent2, value)
	assert(type(items) == "table", "Bad groupInfoList")
	assert(type(items2) == "table", "Bad publishSet")
	assert(typeof(parent2) == "Instance", "Bad parent")
	assert(type(value) == "string", "Bad replicationMode")

	local index = Instance.new("Folder")
	index.Name = "_Index"

	for _, item in pairs(items) do
		if LoaderUtils.needToReify(item, value) then
			LoaderUtils.reifyGroup(item, index, value)
		end
	end

	for k, _ in pairs(items2) do
		for k2, v in pairs(k.scriptInfoLookup[value]) do
			local create = BounceTemplateUtils.create(v.instance, k2)
			create.Parent = parent2
		end
	end

	index.Parent = parent2
end

function LoaderUtils.getPublishPackageInfoSet(items)
	local publishPackageInfoSet = {}

	for _, item in pairs(items) do
		publishPackageInfoSet[item] = true

		for k, _ in pairs(item.explicitDependencySet) do
			publishPackageInfoSet[k] = true
		end
	end

	return publishPackageInfoSet
end

function LoaderUtils.needToReify(p, p2): boolean
	for _, packageScriptInfo in pairs(p.packageScriptInfoMap) do
		if packageScriptInfo.replicationMode == p2 then
			return true
		end
	end

	return false
end

function LoaderUtils.reifyGroup(data, parent2, value)
	assert(type(data) == "table", "Bad groupInfo")
	assert(typeof(parent2) == "Instance", "Bad parent")
	assert(type(value) == "string", "Bad replicationMode")

	local folder = Instance.new("Folder")
	folder.Name = assert(next(data.packageSet).fullName, "Bad package fullName")

	for k, packageScriptInfo in pairs(data.packageScriptInfoMap) do
		assert(packageScriptInfo.name == k, "Bad scriptInfo.name")

		if packageScriptInfo.replicationMode == value then
			if packageScriptInfo.instance == parent then
				local parent3 = parent.Parent
				local ReplicatedStorage = game:GetService("ReplicatedStorage")

				if parent3 == ReplicatedStorage then
					local create = BounceTemplateUtils.create(packageScriptInfo.instance, k)
					create.Parent = folder
					continue
				end
			end

			packageScriptInfo.instance.Name = k
			packageScriptInfo.instance.Parent = folder
		elseif packageScriptInfo.instance == parent then
			local create = BounceTemplateUtils.create(packageScriptInfo.instance, k)
			create.Parent = folder
		else
			local link = BounceTemplateUtils.createLink(packageScriptInfo.instance, k)
			link.Parent = folder
		end
	end

	for k, scriptInfo in pairs(data.scriptInfoMap) do
		assert(scriptInfo.name == k, "Bad scriptInfo.name")

		if data.packageScriptInfoMap[k] then
			continue
		end

		if scriptInfo.instance == parent then
			local create = BounceTemplateUtils.create(scriptInfo.instance, k)
			create.Parent = folder
		else
			local link = BounceTemplateUtils.createLink(scriptInfo.instance, k)
			link.Parent = folder
		end
	end

	folder.Parent = parent2
end

return LoaderUtils