local PoolCommunity = {
	Sorts = { "Favourites", "Newest", "Plays", "Mine" },
	SortLabels = {
		Favourites = "MOST FAVOURITES",
		Newest = "NEWEST",
		Plays = "MOST PLAYS",
		Mine = "MY FAVOURITES"
	},
	Icons = {
		Heart = "rbxassetid://120571037728125",
		HeartOff = "rbxassetid://137353331241798",
		Play = "rbxassetid://109292860910862",
		Check = "rbxassetid://83714645326305"
	},
	PageSize = 8,
	ListSize = 200,
	ListRefresh = 60,
	CardRefresh = 120,
	PlayRefresh = 30,
	ReadReserve = 8,
	ReadReservePerPlayer = 2,
	CardReadsBase = 20,
	CardReadsPerPlayer = 20,
	CountFlush = 60,
	MaxFavourites = 200,
	StoreName = "PoolCommunityTrickshots_V1",
	NewestName = "PoolCommunityNewest_V1",
	FavouritesName = "PoolCommunityFavourites_V1",
	PlaysName = "PoolCommunityPlays_V1",
	SharedListsName = "PoolCommunityLists_V1"
}
local function canonical(items)
	local typeName = typeof(items)

	if typeName == "number" then
		return string.format("%.3f", items)
	elseif typeName == "string" then
		return string.format("%q", items)
	end

	if typeName == "boolean" then
		return if items then "T" else "F"
	else
		if typeName ~= "table" then
			return "?"
		end

		local v = {}

		for k in items do
			table.insert(v, k)
		end

		table.sort(v, function(a, b): boolean
			return tostring(a) < tostring(b)
		end)

		local v2 = table.create(#v)

		for _, v3 in v do
			table.insert(v2, tostring(v3) .. "=" .. canonical(items[v3]))
		end

		return "{" .. table.concat(v2, ",") .. "}"
	end
end

function PoolCommunity.Layout(data)
	if typeof(data) == "table" then
		return canonical({
			Balls = data.Balls or {},
			Mods = data.Mods or {},
			TL = data.TL or 1,
			TH = data.TH or 1
		})
	end

	return ""
end

local function whole(p) -- 8 equivalent calls inferred from this helper
	local v = tonumber(p)

	if v and v == v and v ~= 1e999 then
		return (math.max(math.floor(v), 0))
	end

	return 0
end

function PoolCommunity.SanitizeCard(data)
	if typeof(data) ~= "table" or typeof(data.Code) ~= "string" then
		return nil
	end

	local v = {
		Code = data.Code,
		Name = typeof(data.Name) ~= "string" and "Trickshot" or data.Name,
		Author = whole(data.Author), -- inferred equivalent call
		AuthorName = typeof(data.AuthorName) ~= "string" and "Someone" or data.AuthorName,
		Kind = typeof(data.Kind) ~= "string" and "None" or data.Kind,
		Balls = whole(data.Balls), -- inferred equivalent call
		Plays = whole(data.Plays), -- inferred equivalent call
		Clears = whole(data.Clears), -- inferred equivalent call
		Favourites = whole(data.Favourites), -- inferred equivalent call
		Favourited = data.Favourited == true,
		Published = whole(data.Published), -- inferred equivalent call
		Updated = 0
	}
	local updated

	if data.Updated == nil then
		updated = whole(data.Published) -- inferred equivalent call
	else
		updated = whole(data.Updated) -- inferred equivalent call
	end

	v.Updated = updated
	return v
end

function PoolCommunity.Date(p: number)
	if p <= 0 then
		return "?"
	end

	local success, result = pcall(function()
		return DateTime.fromUnixTimestamp(p):FormatLocalTime("D MMM YYYY", "en-us")
	end)

	if success then
		return (string.upper(result))
	end

	return "?"
end

function PoolCommunity.Short(p: number)
	if p >= 1000000 then
		return (string.format("%.1fM", p / 1000000):gsub("%.0M", "M"))
	end

	if p >= 1000 then
		return (string.format("%.1fK", p / 1000):gsub("%.0K", "K"))
	end

	return (tostring((math.floor(p))))
end

return PoolCommunity