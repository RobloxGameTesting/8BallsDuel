local CollectionService = game:GetService("CollectionService")

local parent = script.Parent
local Utils = require(script.Parent.Utils)
local BounceTemplateUtils = require(script.Parent.BounceTemplateUtils)

local ScriptInfoUtils = {}
ScriptInfoUtils.DEPENDENCY_FOLDER_NAME = "node_modules"
ScriptInfoUtils.ModuleReplicationTypes = Utils.readonly({
	CLIENT = "client",
	SERVER = "server",
	SHARED = "shared",
	IGNORE = "ignore",
	PLUGIN = "plugin"
})

function ScriptInfoUtils.createScriptInfo(instance, name, value)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(name) == "string", "Bad name")
	assert(type(value) == "string", "Bad replicationMode")

	return Utils.readonly({ name = name, replicationMode = value, instance = instance })
end

function ScriptInfoUtils.createScriptInfoLookup()
	return Utils.readonly({
		[ScriptInfoUtils.ModuleReplicationTypes.SERVER] = {},
		[ScriptInfoUtils.ModuleReplicationTypes.CLIENT] = {},
		[ScriptInfoUtils.ModuleReplicationTypes.SHARED] = {},
		[ScriptInfoUtils.ModuleReplicationTypes.PLUGIN] = {}
	})
end

function ScriptInfoUtils.getScriptInfoLookupForMode(p, value)
	assert(type(p) == "table", "Bad scriptInfoLookup")
	assert(type(value) == "string", "Bad replicationMode")

	return p[value]
end

function ScriptInfoUtils.populateScriptInfoLookup(instance, p, value)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(p) == "table", "Bad scriptInfoLookup")
	assert(type(value) == "string", "Bad lastReplicationMode")

	if instance:IsA("Folder") or instance:IsA("Camera") then
		local folderReplicationMode = ScriptInfoUtils.getFolderReplicationMode(instance.Name, value)

		if folderReplicationMode ~= ScriptInfoUtils.ModuleReplicationTypes.IGNORE then
			for _, child in pairs(instance:GetChildren()) do
				if BounceTemplateUtils.isBounceTemplate(child) then
					continue
				end

				if child:IsA("Folder") or child:IsA("Camera") then
					ScriptInfoUtils.populateScriptInfoLookup(child, p, folderReplicationMode)
				elseif child:IsA("ModuleScript") then
					ScriptInfoUtils.addToInfoMap(
						p,
						ScriptInfoUtils.createScriptInfo(child, child.Name, folderReplicationMode)
					)
				end
			end
		end
	elseif instance:IsA("ModuleScript") then
		if not BounceTemplateUtils.isBounceTemplate(instance) then
			if instance == parent then
				ScriptInfoUtils.addToInfoMap(p, ScriptInfoUtils.createScriptInfo(instance, "loader", value))
			else
				ScriptInfoUtils.addToInfoMap(p, ScriptInfoUtils.createScriptInfo(instance, instance.Name, value))
			end
		end
	elseif instance:IsA("ObjectValue") then
		error("ObjectValue links are not supported at this time for retrieving inline module scripts")
	end
end

local v = { IKService = true, IKServiceClient = true }

function ScriptInfoUtils.isAvailableInShared(p)
	if CollectionService:HasTag(p.instance, "LinkToShared") then
		return true
	end

	return v[p.name]
end

function ScriptInfoUtils.addToInfoMap(p, p2)
	assert(type(p) == "table", "Bad scriptInfoLookup")
	assert(type(p2) == "table", "Bad scriptInfo")

	local v2 = assert(p2.replicationMode, "Bad replicationMode")
	local v3 = assert(p[v2], "Bad replicationMode")

	ScriptInfoUtils.addToInfoMapForMode(v3, p2)

	if v2 == ScriptInfoUtils.ModuleReplicationTypes.SHARED then
		ScriptInfoUtils.addToInfoMapForMode(p[ScriptInfoUtils.ModuleReplicationTypes.SERVER], p2)
		ScriptInfoUtils.addToInfoMapForMode(p[ScriptInfoUtils.ModuleReplicationTypes.CLIENT], p2)
	elseif ScriptInfoUtils.isAvailableInShared(p2) then
		ScriptInfoUtils.addToInfoMapForMode(p[ScriptInfoUtils.ModuleReplicationTypes.SHARED], p2)
	end
end

function ScriptInfoUtils:addToInfoMapForMode(p)
	if self[p.name] then
		warn(("Duplicate module %q in same package under same replication scope. Only using first one. \n- %q\n- %q"):format(
			p.name,
			p.instance:GetFullName(),
			self[p.name].instance:GetFullName()
		))
	else
		self[p.name] = p
	end
end

function ScriptInfoUtils.getFolderReplicationMode(value, value2)
	assert(type(value) == "string", "Bad folderName")
	assert(type(value2) == "string", "Bad lastReplicationMode")

	if value == ScriptInfoUtils.DEPENDENCY_FOLDER_NAME then
		return ScriptInfoUtils.ModuleReplicationTypes.IGNORE
	end

	if value2 == ScriptInfoUtils.ModuleReplicationTypes.PLUGIN then
		return value2
	end

	if value == "Shared" then
		return ScriptInfoUtils.ModuleReplicationTypes.SHARED
	elseif value == "Client" then
		return ScriptInfoUtils.ModuleReplicationTypes.CLIENT
	elseif value == "Server" then
		return ScriptInfoUtils.ModuleReplicationTypes.SERVER
	end

	return value2
end

return ScriptInfoUtils