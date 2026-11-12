local parent = script.Parent
local ScriptInfoUtils = require(script.Parent.ScriptInfoUtils)
local LoaderUtils = require(script.Parent.LoaderUtils)
local BounceTemplateUtils = require(script.Parent.BounceTemplateUtils)

local StaticLegacyLoader = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "StaticLegacyLoader"
}

StaticLegacyLoader.__index = StaticLegacyLoader

function StaticLegacyLoader.new()
	return (setmetatable({ _packageLookups = {} }, StaticLegacyLoader))
end

function StaticLegacyLoader:__call(p)
	return self:Require(p)
end

function StaticLegacyLoader.Lock(_)
	error("Cannot start loader while not running")
end

function StaticLegacyLoader:Require(p, moduleScript)
	if type(moduleScript) == "number" then
		return require(moduleScript)
	end

	if type(moduleScript) == "string" then
		local module = self:_findModule(p, moduleScript)

		if module then
			self:_ensureFakeLoader(module)
			return require(module)
		end

		error("Error: Library '" .. tostring(moduleScript) .. "' does not exist.", 2)
	else
		if typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript") then
			return require(moduleScript)
		end

		error(("Error: module must be a string or ModuleScript, got '%s' for '%s'"):format(
			typeof(moduleScript),
			(tostring(moduleScript))
		))
	end
end

function StaticLegacyLoader:_findModule(instance, value)
	assert(typeof(instance) == "Instance", "Bad root")
	assert(type(value) == "string", "Bad name")

	local packageRoot = self:_findPackageRoot(instance)

	while packageRoot do
		local lookup = self:_getOrCreateLookup(packageRoot)

		if lookup[value] then
			return lookup[value]
		end

		local child = packageRoot:FindFirstChild(ScriptInfoUtils.DEPENDENCY_FOLDER_NAME)

		if child then
			for _, folder in pairs(child:GetChildren()) do
				if folder:IsA("Folder") and folder.Name:sub(1, 1) == "@" then
					for _, child2 in pairs(folder:GetChildren()) do
						local packageFolderLookup = self:_getPackageFolderLookup(child2)

						if packageFolderLookup[value] then
							return packageFolderLookup[value]
						end
					end
				else
					local packageFolderLookup = self:_getPackageFolderLookup(folder)

					if packageFolderLookup[value] then
						return packageFolderLookup[value]
					end
				end
			end
		end

		packageRoot = self:_findPackageRoot(packageRoot)
	end

	return nil
end

function StaticLegacyLoader:GetLoader(instance)
	assert(typeof(instance) == "Instance", "Bad moduleScript")

	return (setmetatable({}, {
		__call = function(_, p)
			return self:Require(instance, p)
		end,
		__index = function(_, p)
			return self:Require(instance, p)
		end
	}))
end

function StaticLegacyLoader:_getPackageFolderLookup(instance)
	if instance:IsA("ObjectValue") then
		if instance.Value then
			return self:_getOrCreateLookup(instance.Value)
		end

		warn("[StaticLegacyLoader] - Bad link in packageFolder")
	else
		if instance:IsA("Folder") or instance:IsA("Camera") or instance:IsA("ModuleScript") then
			return self:_getOrCreateLookup(instance)
		end

		warn(("Unknown instance %q (%s) in dependencyFolder - %q"):format(
			instance.Name,
			instance.ClassName,
			instance:GetFullName()
		))
	end

	return {}
end

function StaticLegacyLoader:_getOrCreateLookup(instance)
	assert(typeof(instance) == "Instance", "Bad packageFolderOrModuleScript")

	if self._packageLookups[instance] then
		return self._packageLookups[instance]
	end

	local v = {}

	self:_buildLookup(v, instance)

	self._packageLookups[instance] = v
	return v
end

function StaticLegacyLoader:_buildLookup(instancesByName, instance)
	if instance:IsA("Folder") or instance:IsA("Camera") then
		if instance.Name ~= ScriptInfoUtils.DEPENDENCY_FOLDER_NAME then
			for _, child in pairs(instance:GetChildren()) do
				self:_buildLookup(instancesByName, child)
			end
		end
	elseif instance:IsA("ModuleScript") then
		instancesByName[instance.Name] = instance
	end
end

function StaticLegacyLoader:_findPackageRoot(instance)
	assert(typeof(instance) == "Instance", "Bad instance")

	local parent2 = instance.Parent

	while parent2 and parent2 ~= game do
		if LoaderUtils.isPackage(parent2) then
			return parent2
		end

		if self:_couldBePackageRootTopLevel(parent2) then
			return parent2
		end

		parent2 = parent2.Parent
	end

	return nil
end

function StaticLegacyLoader:_couldBePackageRootTopLevel(instance): boolean
	for _, folder in pairs(instance:GetChildren()) do
		if not (folder:IsA("Folder") and folder.Name:sub(1, 1) == "@") then
			continue
		end

		for _, child in pairs(folder:GetChildren()) do
			if LoaderUtils.isPackage(child) then
				return true
			end
		end
	end

	return true
end

function StaticLegacyLoader:_ensureFakeLoader(instance)
	assert(typeof(instance) == "Instance", "Bad module")

	local parent2 = instance.Parent

	if not parent2 then
		warn("[StaticLegacyLoader] - No parent")
		return
	end

	local archivable = Load and true or false
	local loader = parent2:FindFirstChild("loader")

	if loader then
		if BounceTemplateUtils.isBounceTemplate(loader) then
			loader.Archivable = archivable
		end
	else
		local v = BounceTemplateUtils.create(parent, "loader")
		v.Archivable = archivable
		v.Parent = parent2
	end
end

return StaticLegacyLoader