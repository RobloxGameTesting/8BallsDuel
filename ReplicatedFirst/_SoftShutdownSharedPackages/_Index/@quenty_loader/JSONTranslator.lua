local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local v = loaded("Blend")
local v2 = loaded("JsonToLocalizationTable")
local v3 = loaded("LocalizationServiceUtils")
local v4 = loaded("Maid")
local v5 = loaded("Observable")
local v6 = loaded("Promise")
local v7 = loaded("PseudoLocalize")
local v8 = loaded("Rx")
local v9 = loaded("RxInstanceUtils")
local v10 = loaded("TranslationKeyUtils")

local JSONTranslator = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "JSONTranslator",
	ServiceName = "JSONTranslator"
}

JSONTranslator.__index = JSONTranslator

function JSONTranslator.new(serviceName, ...)
	local self = setmetatable({}, JSONTranslator)

	assert(type(serviceName) == "string", "Bad translatorName")
	self.ServiceName = serviceName

	self._localizationTable = v2.toLocalizationTable(serviceName, ...)
	self._englishTranslator = self._localizationTable:GetTranslator("en")
	self._fallbacks = {}

	if RunService:IsRunning() and RunService:IsClient() then
		self._promiseTranslator = v3.promiseTranslator(Players.LocalPlayer)
	else
		self._promiseTranslator = v6.resolved(self._englishTranslator)
	end

	if RunService:IsStudio() then
		v7.addToLocalizationTable(self._localizationTable, nil, "en")
	end

	return self
end

function JSONTranslator:Init(p)
	self._serviceBag = assert(p, "No serviceBag")
end

function JSONTranslator:ObserveLocaleId()
	return v8.fromPromise(self._promiseTranslator):Pipe({ v8.switchMap(function(p)
			return v9.observeProperty(p, "LocaleId")
		end) })
end

function JSONTranslator:SetEntryValue(value, value2, value3, value4, value5)
	assert(type(value) == "string", "Bad translationKey")
	assert(type(value2) == "string", "Bad source")
	assert(type(value3) == "string", "Bad context")
	assert(type(value4) == "string", "Bad localeId")
	assert(type(value5) == "string", "Bad text")

	self._localizationTable:SetEntryValue(value, value2, value3, value4, value5 or value2)

	if RunService:IsStudio() then
		self._localizationTable:SetEntryValue(
			value,
			value2,
			value3,
			v7.getDefaultPseudoLocaleId(),
			v7.pseudoLocalize(value5)
		)
	end
end

function JSONTranslator:ObserveTranslation(value, value2, p)
	assert(type(value) == "string", "Bad text")
	assert(type(value2) == "string", "Bad text")

	return self:ObserveFormatByKey(self:ToTranslationKey(value, value2), p)
end

function JSONTranslator:ToTranslationKey(value, value2)
	assert(type(value) == "string", "Bad text")
	assert(type(value2) == "string", "Bad text")

	local translationKey = v10.getTranslationKey(value, value2)
	self:SetEntryValue(translationKey, value2, ("automatic.%s"):format(translationKey), "en", value2)

	return translationKey
end

function JSONTranslator:GetLocaleId()
	if self._promiseTranslator:IsFulfilled() then
		return self._promiseTranslator:Wait().LocaleId
	end

	warn("[JSONTranslator.GetLocaleId] - Translator is not loaded yet, returning english")
	return "en"
end

function JSONTranslator:GetLocalizationTable()
	return self._localizationTable
end

function JSONTranslator:PromiseLoaded()
	return self._promiseTranslator
end

function JSONTranslator:FallbackTo(p)
	assert(p, "Bad translator")
	assert(p.FormatByKey, "Bad translator")

	table.insert(self._fallbacks, p)
end

function JSONTranslator:PromiseFormatByKey(value, p)
	assert(self ~= JSONTranslator, "Construct a new version of this class to use it")
	assert(type(value) == "string", "Key must be a string")

	return self._promiseTranslator:Then(function()
		return self:FormatByKey(value, p)
	end)
end

function JSONTranslator:ObserveFormatByKey(value, items)
	assert(self ~= JSONTranslator, "Construct a new version of this class to use it")
	assert(type(value) == "string", "Key must be a string")
	local args

	if items then
		local v11 = {}

		for k, item in pairs(items) do
			v11[k] = v.toPropertyObservable(item) or v8.of(item)
		end

		args = v8.combineLatest(v11)
	else
		args = nil
	end

	return v5.new(function(object)
		local maid = v4.new()

		maid:GivePromise(self._promiseTranslator):Then(function(p)
			if args then
				maid:GiveTask(v8.combineLatest({
					localeId = v9.observeProperty(p, "LocaleId"),
					args = args
				}):Subscribe(function(p2)
					object:Fire(self:FormatByKey(value, p2.args))
				end))
			else
				maid:GiveTask(v9.observeProperty(p, "LocaleId"):Subscribe(function()
					object:Fire(self:FormatByKey(value, nil))
				end))
			end
		end)

		return maid
	end)
end

function JSONTranslator:FormatByKey(value, p)
	assert(self ~= JSONTranslator, "Construct a new version of this class to use it")
	assert(type(value) == "string", "Key must be a string")

	if not RunService:IsRunning() then
		return self:_formatByKeyTestMode(value, p)
	end

	local clientTranslatorOrError = self:_getClientTranslatorOrError()

	local v11 = nil
	local success, result = pcall(function()
		v11 = clientTranslatorOrError:FormatByKey(value, p)
	end)

	if success and not result then
		return v11
	end

	if result then
		warn(result)
	else
		warn("Failed to localize '" .. value .. "'")
	end

	if clientTranslatorOrError.LocaleId ~= self._englishTranslator.LocaleId then
		local success2, result2 = pcall(function()
			v11 = self._englishTranslator:FormatByKey(value, p)
		end)

		if success2 and not result2 then
			return v11
		end
	end

	return value
end

function JSONTranslator:_getClientTranslatorOrError()
	assert(self._promiseTranslator, "ClientTranslator is not initialized")

	if self._promiseTranslator:IsFulfilled() then
		return assert(self._promiseTranslator:Wait(), "Failed to get translator")
	end

	error("Translator is not yet acquired yet")
	return nil
end

function JSONTranslator:_formatByKeyTestMode(p, p2)
	local translator = self._localizationTable:GetTranslator("en")
	local v11 = nil
	local success, result = pcall(function()
		v11 = translator:FormatByKey(p, p2)
	end)

	if success and not result then
		return v11
	end

	for _, fallback in pairs(self._fallbacks) do
		local formatByKey = fallback:FormatByKey(p, p2)

		if formatByKey then
			return formatByKey
		end
	end

	if result then
		warn(result)
	else
		warn("[JSONTranslator._formatByKeyTestMode] - Failed to localize '" .. p .. "'")
	end

	return p
end

function JSONTranslator:Destroy()
	self._localizationTable:Destroy()
	self._localizationTable = nil
	self._englishTranslator = nil
	self._promiseTranslator = nil

	setmetatable(self, nil)
end

return JSONTranslator