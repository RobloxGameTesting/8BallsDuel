local TextService = game:GetService("TextService")
local StringHelper = {}

function StringHelper.Capitalize(value: string)
	local v, _ = value:gsub("^%a", string.upper)
	return v
end

function StringHelper.RemovePlural(value: string)
	return (string.sub(value, 1, value:len() - 1))
end

function StringHelper.StartsWith(value: string, list: string): boolean
	return string.sub(value, 1, #list) == list
end

function StringHelper.Filter(p: string, p2: string)
	local success, result = pcall(function()
		return TextService:FilterStringAsync(p, tonumber(p2), Enum.TextFilterContext.PublicChat)
	end)
	return if success then result else nil
end

function StringHelper.FilterForBroadcast(object)
	local success, result = pcall(function()
		return object:GetNonChatStringForBroadcastAsync()
	end)
	return if success then result else nil
end

function StringHelper.FilterForUser(object, p: string)
	local success, result = pcall(function()
		return object:GetNonChatStringForUserAsync((tonumber(p)))
	end)
	return if success then result else nil
end

function StringHelper.RetrieveNumbers(value: string)
	local numbers, _ = string.gsub(value, "[^0-9]", "")
	return numbers
end

function StringHelper.RemoveRichText(value: string)
	local v, _ = string.gsub(value, "<[^>]->", "")
	return v
end

return StringHelper