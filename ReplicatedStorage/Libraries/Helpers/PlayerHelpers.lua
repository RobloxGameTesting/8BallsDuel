local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

local PlayerHelpers = {}

function PlayerHelpers.GetName(p)
	if p then
		return p.DisplayName == p.Name and p.Name or p.DisplayName .. " @" .. p.Name .. ""
	end

	return ""
end

function PlayerHelpers.GetProfileIcon(p)
	if not p then
		return ""
	end

	local userId = tostring(p.UserId)

	local headShot = Enum.ThumbnailType.HeadShot
	local size420x420 = Enum.ThumbnailSize.Size420x420

	local _, result = pcall(function()
		local userThumbnailAsync, _ = Players:GetUserThumbnailAsync(tonumber(userId), headShot, size420x420)

		return userThumbnailAsync
	end)

	return result
end

function PlayerHelpers.GetPlayerCharacter(player)
	return player.Character or player.CharacterAdded:Wait()
end

function PlayerHelpers.GetPlayerHumanoid(p)
	return (PlayerHelpers.GetPlayerCharacter(p):FindFirstChildWhichIsA("Humanoid"))
end

function PlayerHelpers.GetPlayerHrp(p)
	return PlayerHelpers.GetPlayerCharacter(p).PrimaryPart
end

function PlayerHelpers.GetPlayerComponents(p)
	return {
		chr = PlayerHelpers.GetPlayerCharacter(p),
		hum = PlayerHelpers.GetPlayerHumanoid(p),
		hrp = PlayerHelpers.GetPlayerHrp(p)
	}
end

function PlayerHelpers.GetPlayerByUsername(_, value)
	for _, v in Players:GetPlayers(), nil, nil do
		if string.lower(v.Name) == string.lower(value) then
			return v
		end
	end

	return nil
end

function PlayerHelpers.GetPlayerFromInstance(instance)
	for _, v in Players:GetPlayers(), nil, nil do
		local character = v.Character

		if character and instance:IsDescendantOf(character) then
			return v
		end
	end

	return nil
end

function PlayerHelpers.GetPlayersInHitbox(object)
	if not object then
		return {}
	end

	local touchingParts = object and object:GetTouchingParts()
	local playerFromCharacters = {}

	if not touchingParts then
		return playerFromCharacters
	end

	for _, touchingPart in touchingParts do
		if touchingPart.Name ~= "HumanoidRootPart" then
			continue
		end

		local parent = touchingPart and touchingPart.Parent
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter then
			tostring(playerFromCharacter.UserId)
		end

		if parent and playerFromCharacter then
			table.insert(playerFromCharacters, playerFromCharacter)
		end
	end

	return playerFromCharacters
end

function PlayerHelpers.GetChatColour(p)
	local v = {
		Color3.new(253 / 255, 41 / 255, 67 / 255),
		Color3.new(1 / 255, 162 / 255, 1),
		Color3.new(2 / 255, 184 / 255, 87 / 255),
		BrickColor.new("Bright violet").Color,
		BrickColor.new("Bright orange").Color,
		BrickColor.new("Bright yellow").Color,
		BrickColor.new("Light reddish violet").Color,
		BrickColor.new("Brick yellow").Color
	}

	local function GetNameValue(value)
		local nameValue = 0

		for i = 1, #value do
			local v2 = string.byte((string.sub(value, i, i)))
			local v3 = #value - i + 1

			if #value % 2 == 1 then
				v3 -= 1
			end

			if v3 % 4 >= 2 then
				v2 = -v2
			end

			nameValue += v2
		end

		return nameValue
	end

	local function ComputeNameColor(p2) -- 1 equivalent call inferred from this helper
		return v[(GetNameValue(p2) + 0) % #v + 1]
	end

	return ComputeNameColor(p) -- inferred equivalent call
end

function PlayerHelpers.OnEachPlayer(callback)
	local object = setmetatable({}, { __mode = "k" })

	local function run(p) -- 1 equivalent call inferred from this helper
		if object[p] then
			return
		end

		object[p] = true
		task.spawn(callback, p)
	end

	local playerAddedConnection = Players.PlayerAdded:Connect(run)

	for _, v in Players:GetPlayers(), nil, nil do
		run(v) -- inferred equivalent call
	end

	return playerAddedConnection
end

return PlayerHelpers