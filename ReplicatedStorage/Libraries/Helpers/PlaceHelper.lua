local HttpService = game:GetService("HttpService")

local GameId = game.GameId
local v = { ["129637944746049"] = "Game" }

local PlaceHelper = {
	GetGroupId = function(): number
		return 918657773
	end,
	GetWelcomeBadge = function(): number
		return 2568472679072461
	end,
	GetPlaceType = function()
		return v[tostring(game.PlaceId)]
	end,
	GetPlacesByType = function(p: string)
		local places = {}

		for k, v2 in v do
			if v2 == p then
				table.insert(places, k)
			end
		end

		return places
	end,
	GetServerType = function(): string
		if game.PrivateServerId == "" then
			return "StandardServer"
		end

		if game.PrivateServerOwnerId == 0 then
			return "ReservedServer"
		end

		return "PrivateServer"
	end,
	GetName = function(): string
		return "GAME_NAME"
	end,
	GetVersion = function(): string
		return "V1.0.0a"
	end
}

local votes = nil

function PlaceHelper.GetVotes(flag: boolean?)
	if votes and not flag then
		return votes
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode((HttpService:GetAsync(`https://games.roproxy.com/v1/games/{game.GameId}/votes`)))
	end)

	if success and typeof(result) == "table" and typeof(result.upVotes) == "number" then
		votes = result

		return votes
	end

	warn("Game must be public to get the game's vote data")

	return votes
end

return PlaceHelper