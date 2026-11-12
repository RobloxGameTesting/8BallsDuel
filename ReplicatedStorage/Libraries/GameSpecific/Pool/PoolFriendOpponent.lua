local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")

require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
local PoolMatchmakingConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMatchmakingConstants)

local PoolFriendOpponent = {}

local bindableEvent = Instance.new("BindableEvent")
PoolFriendOpponent.Changed = bindableEvent.Event

local count = 0
local v = nil
local v2 = false
local v3 = false
local v4 = false
local lastTime = -1e999

local v5 = {}

local v6 = false

local userId = nil

local function setPicked(p) -- 2 equivalent calls inferred from this helper
	local v7 = v

	v = p

	if p then
		userId = p.UserId
	end

	if p ~= v7 then
		bindableEvent:Fire(p)
	end
end

function PoolFriendOpponent.Roll()
	if #v5 == 0 or v6 then
		PoolFriendOpponent.Prefetch()
	end

	if #v5 == 0 then
		return
	end

	if #v5 == 1 then
		setPicked(v5[1]) -- inferred equivalent call
	else
		local v7 = v5[math.random(1, #v5)]

		while v7.UserId == userId do
			v7 = v5[math.random(1, #v5)]
		end

		setPicked(v7) -- inferred equivalent call
	end
end

local function readFriends()
	local v7 = nil
	local v8 = nil

	for i = 1, 3 do
		local success, result = pcall(function()
			return Players:GetFriendsAsync(Players.LocalPlayer.UserId)
		end)

		if success then
			v7 = result
			break
		end

		task.wait(i)
		v8 = result
	end

	if not v7 then
		return {}, "GetFriendsAsync failed: " .. tostring(v8)
	end

	local result = {}

	while #result < 50 do
		local success, result2 = pcall(function()
			return v7:GetCurrentPage()
		end)

		if not success then
			return result, "reading a friends page failed: " .. tostring(result2)
		end

		for _, v9 in result2 do
			if not (typeof(v9) == "table" and v9.Id and v9.DisplayName) then
				continue
			end

			table.insert(result, { UserId = v9.Id, DisplayName = v9.DisplayName })

			if #result >= 50 then
				break
			end
		end

		if #result >= 50 or v7.IsFinished then
			break
		end

		local success2, result3 = pcall(function()
			v7:AdvanceToNextPageAsync()
		end)

		if not success2 then
			return result, "loading the next friends page failed: " .. tostring(result3)
		end
	end

	return result, nil
end

local function resolveFallbackFriends()
	local localPlayer = Players.LocalPlayer
	local v7 = {}

	for _, friendFallbackUserId in PoolMatchmakingConstants.FriendFallbackUserIds do
		if not (tonumber(friendFallbackUserId) and friendFallbackUserId ~= localPlayer.UserId) then
			continue
		end

		local success, result = pcall(function()
			return localPlayer:IsFriendsWith(friendFallbackUserId)
		end)

		if success and result then
			table.insert(v7, friendFallbackUserId)
		end
	end

	if #v7 == 0 then
		if not RunService:IsStudio() then
			return {}
		end

		for _, studioPlaceholderUserId in PoolMatchmakingConstants.StudioPlaceholderUserIds do
			if tonumber(studioPlaceholderUserId) and studioPlaceholderUserId ~= localPlayer.UserId then
				table.insert(v7, studioPlaceholderUserId)
			end
		end
	end

	if #v7 == 0 then
		return {}
	end

	local result = {}
	local success, result2 = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync(v7)
	end)

	if success and typeof(result2) == "table" then
		for _, v8 in result2 do
			if not (typeof(v8) == "table" and tonumber(v8.Id)) then
				continue
			end

			table.insert(result, {
				UserId = tonumber(v8.Id),
				DisplayName = tostring(v8.DisplayName or v8.Username or "Player")
			})
		end
	end

	if #result ~= 0 then
		return result
	end

	for _, userId2 in v7 do
		local success2, result3 = pcall(function()
			return Players:GetNameFromUserIdAsync(userId2)
		end)

		if success2 and result3 then
			table.insert(result, { UserId = userId2, DisplayName = tostring(result3) })
		end
	end

	return result
end

function PoolFriendOpponent.Prefetch()
	if #v5 > 0 and not v6 or v4 or os.clock() - lastTime < 15 then
		return
	end

	v2 = true
	v4 = true
	lastTime = os.clock()

	count += 1

	task.spawn(function()
		local success, result, v7 = pcall(readFriends)

		if not success then
			v7 = tostring(result)
			result = {}
		end

		local v8 = false

		if #result == 0 then
			local success2, result2 = pcall(resolveFallbackFriends)

			v7 = v7 or "enumeration returned nobody"

			if success2 and typeof(result2) == "table" and #result2 > 0 then
				result = result2
				v8 = true
			elseif not success2 then
				v7 = "friend fallback failed: " .. tostring(result2)
			end
		end

		if #result > 0 then
			local v9 = #v5 == 0

			v5 = result
			v6 = v8

			if v9 or not v8 then
				PoolFriendOpponent.Roll()
			end
		end

		if v7 then
			warn(string.format("[PoolFriendOpponent] friends lookup: %s (kept %d)", v7, #result))
		end

		v4 = false
		v3 = true

		if (#v5 == 0 or v6) and count < 6 then
			task.delay(15, PoolFriendOpponent.Prefetch)
		end
	end)
end

function PoolFriendOpponent.Get()
	return v
end

function PoolFriendOpponent.IsReady()
	return v3
end

return PoolFriendOpponent