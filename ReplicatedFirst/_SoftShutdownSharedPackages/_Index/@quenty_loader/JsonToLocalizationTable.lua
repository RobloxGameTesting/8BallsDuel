local LocalizationService = game:GetService("LocalizationService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local JsonToLocalizationTable = {}
local function recurseAdd(object, p, p2, items, value)
	if p2 ~= "" then
		p2 ..= "."
	end

	for k, item in pairs(items) do
		local v = p2 .. k

		if type(item) == "table" then
			recurseAdd(object, p, v, item, value)
		elseif type(item) == "string" then
			local v2 = value .. "." .. v

			object:SetEntryValue(v, p ~= "en" and "" or item, v2, p, item)
		else
			error("Bad type for value in '" .. v .. "'.")
		end
	end
end

function JsonToLocalizationTable.localeFromName(value)
	if value:sub(-5) == ".json" then
		return value:sub(1, #value - 5)
	end

	return value
end

function JsonToLocalizationTable.getOrCreateLocalizationTable()
	local name = RunService:IsServer() and "GeneratedJSONTable_Server" or "GeneratedJSONTable_Client"

	local v = LocalizationService:FindFirstChild(name)

	if v then
		return v
	end

	v = Instance.new("LocalizationTable")
	v.Name = name

	if RunService:IsRunning() then
		v.Parent = LocalizationService
	end

	return v
end

function JsonToLocalizationTable.loadFolder(value, folder)
	assert(type(value) == "string", "Bad tableName")

	local localizationTable = JsonToLocalizationTable.getOrCreateLocalizationTable()

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("StringValue") then
			local localeFromName = JsonToLocalizationTable.localeFromName(descendant.Name)
			JsonToLocalizationTable.addJsonToTable(localizationTable, localeFromName, descendant.Value, value)
		elseif descendant:IsA("ModuleScript") then
			local localeFromName = JsonToLocalizationTable.localeFromName(descendant.Name)
			local module = require(descendant)
			recurseAdd(localizationTable, localeFromName, "", module, value)
		end
	end

	return localizationTable
end

function JsonToLocalizationTable.toLocalizationTable(value, value2, p)
	assert(type(value) == "string", "Bad tableName")

	if typeof(value2) == "Instance" then
		return (JsonToLocalizationTable.loadFolder(value, value2))
	end

	if type(value2) == "string" and type(p) == "table" then
		return (JsonToLocalizationTable.loadTable(value, value2, p))
	end

	error("Bad args")
end

function JsonToLocalizationTable.loadTable(value, p, p2)
	assert(type(value) == "string", "Bad tableName")

	local localizationTable = JsonToLocalizationTable.getOrCreateLocalizationTable()

	recurseAdd(localizationTable, p, "", p2, value)

	return localizationTable
end

function JsonToLocalizationTable.addJsonToTable(p, p2, json, value)
	assert(type(value) == "string", "Bad tableName")

	recurseAdd(p, p2, "", HttpService:JSONDecode(json), value)
end

return JsonToLocalizationTable