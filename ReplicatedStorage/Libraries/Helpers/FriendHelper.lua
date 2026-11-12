local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local SharedConstants = require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local SocialService = game:GetService("SocialService")
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.Types.NotificationTypes)
require(ReplicatedStorage.Types.Types)

local isServer = RunService:IsServer()
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local isStudio = RunService:IsStudio()

local v = {}

local function replicaWhileHere(p, userId: string)
	while p.Parent == Players do
		local playerReplica = Profiles.GetPlayerReplica(userId)

		if playerReplica then
			return playerReplica
		end

		task.wait(0.5)
	end

	return nil
end

local FriendHelper = { Added = bindableEvent.Event, Removing = bindableEvent2.Event }

function FriendHelper.Init()
	if isServer then
		Players.PlayerAdded:Connect(function(player)
			local userId = tostring(player.UserId)

			local userIds = {}
			v[userId] = userIds

			local v2 = replicaWhileHere(player, userId)

			if not v2 or v[userId] ~= userIds then
				return
			end

			for _, v3 in Players:GetPlayers(), nil, nil do
				local userId2 = tostring(v3.UserId)

				if userId2 == userId then
					continue
				end

				local success, result = pcall(function()
					return v3:IsFriendsWithAsync((tonumber(userId)))
				end)

				if v[userId] ~= userIds then
					break
				end

				local userIds2 = v[userId2]

				if not success or not result or not userIds2 or table.find(userIds, userId2) then
					continue
				end

				if not table.find(userIds2, userId) then
					table.insert(userIds2, userId)
				end

				table.insert(userIds, userId2)

				task.spawn(function()
					local v4 = replicaWhileHere(v3, userId2)

					if v4 and v4:IsActive() then
						v4:Write("FriendPlays", 1)
					end

					if v2:IsActive() then
						v2:Write("FriendPlays", 1)
					end

					bindableEvent:Fire(userId2, userId)

					if not (v4 and v4:IsActive() and v2:IsActive()) or player.AccountAge < 30 then
						return
					end

					if v3.AccountAge < 30 then
						return
					end

					if
						v2.Data.inviteRewardInvites[tostring(userId2)]
						and os.time() - v2.Data.inviteRewardInvites[tostring(userId2)] < SharedConstants.FRIEND_COOLDOWN
					then
						warn("It hasn't been 12 hours")
						return
					end

					if
						v4.Data.inviteRewardInvites[tostring(userId)]
						and os.time() - v4.Data.inviteRewardInvites[tostring(userId)] < SharedConstants.FRIEND_COOLDOWN
					then
						warn("It hasn't been 12 hours")
						return
					end

					local now = os.time()
					local _ = v2.Data.plays <= 1

					v2:Write("InviteRewardInvites", userId2, now)
					v4:Write("InviteRewardInvites", userId, now)
				end)
			end
		end)

		Players.PlayerRemoving:Connect(function(player)
			local userId = tostring(player.UserId)

			v[userId] = nil

			for k, list in v do
				local index = table.find(list, userId)

				if not index then
					continue
				end

				table.remove(list, index)
				bindableEvent2:Fire(k, userId)
			end
		end)
	else
		local userId = tostring(Players.LocalPlayer.UserId)

		v[userId] = {}

		local function checkFriend(object): boolean -- 2 equivalent calls inferred from this helper
			local userId2 = tostring(object.UserId)

			local success, result = pcall(function()
				return object:IsFriendsWithAsync((tonumber(userId)))
			end)

			if success and result then
				table.insert(v[userId], userId2)
				return true
			end

			return false
		end

		Players.PlayerAdded:Connect(function(player)
			local userId2 = tostring(player.UserId)

			if checkFriend(player) then -- inferred equivalent call
				bindableEvent:Fire(userId2, userId)
			end
		end)

		for _, v2 in Players:GetPlayers(), nil, nil do
			local userId2 = tostring(v2.UserId)

			task.spawn(function()
				if checkFriend(v2) then -- inferred equivalent call
					bindableEvent:Fire(userId2, userId)
				end
			end)
		end
	end
end

function FriendHelper.GetFriendsInServer(p: string)
	return v[p] or {}
end

function FriendHelper.IterateFriendsList(object)
	return coroutine.wrap(function()
		local v2 = 1

		while true do
			for _, v3 in object:GetCurrentPage(), nil, nil do
				coroutine.yield(v3, v2)
			end

			if object.IsFinished then
				break
			end

			object:AdvanceToNextPageAsync()
			v2 += 1
		end
	end)
end

function FriendHelper:PromptGameInvite()
	local localPlayer = Players.LocalPlayer

	UserInputService.MouseIconEnabled = true
	SocialService:PromptGameInvite(localPlayer, self)
end

function FriendHelper.ConvertPagesToList(object)
	local result = {}

	while true do
		for _, v2 in object:GetCurrentPage(), nil, nil do
			table.insert(result, v2)
		end

		if object.IsFinished then
			return result
		end

		object:AdvanceToNextPageAsync()
	end
end

function FriendHelper.GetFriendsPages(p: string)
	local count = 0
	local friendsPages = nil

	repeat
		local success, result = pcall(function()
			return Players:GetFriendsAsync((tonumber(p)))
		end)

		if success then
			friendsPages = result
		else
			task.wait(0.5)
			count += 1
		end
	until success or count == 10

	return friendsPages
end

function FriendHelper.GetOnlineFriends(p: string)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	local count = 0
	local onlineFriends = nil

	repeat
		local success, result = pcall(function()
			return playerByUserId:GetFriendsOnlineAsync()
		end)

		if success then
			onlineFriends = result
		else
			task.wait(0.5)
			count += 1
		end
	until success or count == 10

	return onlineFriends
end

function FriendHelper.CanSendInvite(p: string)
	if isStudio then
		return true
	end

	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	local count = 0
	local v2 = nil

	repeat
		local success, result = pcall(function()
			return SocialService:CanSendGameInviteAsync(playerByUserId)
		end)

		if success then
			v2 = result
		else
			task.wait(0.5)
			count += 1
		end
	until success or count == 10

	return v2
end

return FriendHelper