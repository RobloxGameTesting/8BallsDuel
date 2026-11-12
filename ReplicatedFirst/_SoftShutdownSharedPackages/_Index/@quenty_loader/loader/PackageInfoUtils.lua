local BounceTemplateUtils = require(script.Parent.BounceTemplateUtils)
local LoaderConstants = require(script.Parent.LoaderConstants)
local Queue = require(script.Parent.Queue)
local ScriptInfoUtils = require(script.Parent.ScriptInfoUtils)
local Utils = require(script.Parent.Utils)

local PackageInfoUtils = {}

function PackageInfoUtils.createPackageInfo(instance, explicitDependencySet, scriptInfoLookup, fullName)
	assert(typeof(instance) == "Instance", "Bad packageFolder")
	assert(type(explicitDependencySet) == "table", "Bad explicitDependencySet")
	assert(type(scriptInfoLookup) == "table", "Bad scriptInfoLookup")
	assert(type(fullName) == "string", "Bad fullName")

	return Utils.readonly({
		name = instance.Name,
		fullName = fullName,
		instance = instance,
		explicitDependencySet = explicitDependencySet,
		dependencySet = false,
		scriptInfoLookup = scriptInfoLookup
	})
end

function PackageInfoUtils.createDependencyQueueInfo(packageInfo, implicitDependencySet)
	assert(type(packageInfo) == "table", "Bad packageInfo")
	assert(type(implicitDependencySet) == "table", "Bad implicitDependencySet")

	return Utils.readonly({
		packageInfo = packageInfo,
		implicitDependencySet = implicitDependencySet
	})
end

function PackageInfoUtils.fillDependencySet(items)
	assert(type(items) == "table", "Bad packageInfoList")

	local v = Queue.new()
	local set = {}

	local v2 = {}

	for _, item in pairs(items) do
		if set[item] then
			continue
		end

		v2[item] = item
		set[item] = true
		v:PushRight(PackageInfoUtils.createDependencyQueueInfo(item, v2))
	end

	while not v:IsEmpty() do
		local v3 = v:PopLeft()
		assert(not v3.packageInfo.dependencySet, "Already wrote dependencySet")

		local packageDependencySet = PackageInfoUtils.computePackageDependencySet(
			v3.packageInfo,
			v3.implicitDependencySet
		)
		v3.packageInfo.dependencySet = packageDependencySet

		for k, _ in pairs(v3.packageInfo.explicitDependencySet) do
			if set[k] then
				continue
			end

			set[k] = true
			v:PushRight(PackageInfoUtils.createDependencyQueueInfo(k, packageDependencySet))
		end
	end
end

function PackageInfoUtils.computePackageDependencySet(p, items)
	assert(type(p) == "table", "Bad packageInfo")
	assert(type(items) == "table", "Bad implicitDependencySet")

	local v = {}

	if LoaderConstants.INCLUDE_IMPLICIT_DEPENDENCIES then
		for k, _ in pairs(items) do
			v[k.name] = k
		end
	end

	for k, _ in pairs(p.explicitDependencySet) do
		v[k.name] = k
	end

	v[p.name] = nil

	local packageDependencySet = {}

	for _, v2 in pairs(v) do
		packageDependencySet[v2] = true
	end

	return packageDependencySet
end

function PackageInfoUtils.getOrCreatePackageInfo(instance, packageInfosByInstance, value, p)
	assert(typeof(instance) == "Instance", "Bad packageFolder")
	assert(type(packageInfosByInstance) == "table", "Bad packageInfoMap")
	assert(type(value) == "string", "Bad scope")
	assert(p, "No defaultReplicationType")

	if packageInfosByInstance[instance] then
		return packageInfosByInstance[instance]
	end

	local scriptInfoLookup = ScriptInfoUtils.createScriptInfoLookup()
	ScriptInfoUtils.populateScriptInfoLookup(instance, scriptInfoLookup, p)

	local v = {}
	local v2

	if value == "" then
		v2 = instance.Name
	else
		v2 = value .. "/" .. instance.Name
	end

	local packageInfo = PackageInfoUtils.createPackageInfo(instance, v, scriptInfoLookup, v2)
	packageInfosByInstance[instance] = packageInfo

	PackageInfoUtils.fillExplicitPackageDependencySet(v, instance, packageInfosByInstance, p)

	return packageInfo
end

function PackageInfoUtils.getPackageInfoListFromDependencyFolder(folder, p, p2)
	local v = typeof(folder) == "Instance" and folder:IsA("Folder")
	assert(v, "Bad folder")
	assert(type(p) == "table", "Bad packageInfoMap")
	assert(p2, "No defaultReplicationType")

	local packageInfoList = {}

	for _, folder2 in pairs(folder:GetChildren()) do
		if folder2:IsA("Folder") then
			if folder2.Name:sub(1, 1) == "@" then
				local name = folder2.Name

				for _, child in pairs(folder2:GetChildren()) do
					PackageInfoUtils.tryLoadPackageFromInstance(packageInfoList, p, child, name, p2)
				end
			else
				PackageInfoUtils.tryLoadPackageFromInstance(packageInfoList, p, folder2, "", p2)
			end
		else
			warn(("Unknown instance in dependencyFolder - %q"):format(folder2:GetFullName()))
		end
	end

	return packageInfoList
end

function PackageInfoUtils.tryLoadPackageFromInstance(list, p, instance, value, p2)
	assert(type(list) == "table", "Bad packageInfoList")
	assert(type(p) == "table", "Bad packageInfoMap")
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(value) == "string", "Bad scope")
	assert(p2, "No defaultReplicationType")

	if BounceTemplateUtils.isBounceTemplate(instance) then
		return
	end

	if instance:IsA("Folder") or instance:IsA("ModuleScript") then
		table.insert(list, PackageInfoUtils.getOrCreatePackageInfo(instance, p, value, p2))
	elseif instance:IsA("ObjectValue") then
		local value2 = instance.Value

		if value2 and (value2:IsA("Folder") or value2:IsA("ModuleScript")) then
			table.insert(list, PackageInfoUtils.getOrCreatePackageInfo(value2, p, value, p2))
		else
			local v = string.format(
				"Invalid %q ObjectValue in package linking to nothing cannot be resolved into package dependency\n\t-> %s",
				instance.Name,
				instance:GetFullName()
			) .. "\n\tTIP: This happens when Rojo fails to clean out an object value. Try disconnecting Rojo and reconnecting"

			error(v)
		end
	end
end

function PackageInfoUtils:fillExplicitPackageDependencySet(instance, p, p2)
	assert(type(self) == "table", "Bad explicitDependencySet")
	assert(typeof(instance) == "Instance", "Bad packageFolder")
	assert(type(p) == "table", "Bad packageInfoMap")
	assert(p2, "No defaultReplicationType")

	for _, child in pairs(instance:GetChildren()) do
		if not ((child:IsA("Folder") or child:IsA("Camera")) and child.Name == ScriptInfoUtils.DEPENDENCY_FOLDER_NAME) then
			continue
		end

		local packageInfoListFromDependencyFolder = PackageInfoUtils.getPackageInfoListFromDependencyFolder(
			child,
			p,
			p2
		)

		for _, v in pairs(packageInfoListFromDependencyFolder) do
			self[v] = true
		end
	end
end

return PackageInfoUtils