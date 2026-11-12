local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local function currencyInfo() -- 3 equivalent calls inferred from this helper
	local success, events = pcall(require, ReplicatedStorage.Libraries.Modules.Events)

	if success then
		return (events:GetCurrencyInfo())
	end

	return nil
end

local function ownIcon(p) -- 2 equivalent calls inferred from this helper
	local icon = p and p.icon

	return if typeof(icon) == "string" and icon ~= "" then icon else nil
end

local EventCurrency = {}
EventCurrency.name = "EventCurrency"
EventCurrency.itemType = "Currency"

function EventCurrency.image(_, _)
	return ownIcon(currencyInfo()) or "rbxassetid://91068843812037" -- inferred equivalent call
end

function EventCurrency.imageTint(_, _)
	local v = currencyInfo() -- inferred equivalent call

	if ownIcon(v) then -- inferred equivalent call
		return nil
	end

	local tint = v and v.tint

	if typeof(tint) == "ColorSequence" then
		return tint
	end

	return (ColorSequence.new(Color3.fromRGB(255, 175, 255), Color3.fromRGB(185, 125, 255)))
end

function EventCurrency.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function EventCurrency.labelBottom()
	local v = currencyInfo() -- inferred equivalent call
	return if v and v.name then v.name else "Event Gems"
end

function EventCurrency.rarity(_, _): string
	return "Tier4"
end

return EventCurrency