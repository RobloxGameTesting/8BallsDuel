local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
game:GetService("SocialService")
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
game:GetService("UserInputService")
game:GetService("HttpService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Menu)
game:GetService("TweenService")
game:GetService("RunService")
local Inventories = require(ReplicatedStorage.Libraries.Classes.Inventories)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
local FriendConstants = require(ReplicatedStorage.Libraries.Constants.FriendConstants)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local Assets = ReplicatedStorage.Assets
local FriendInviteUI = PlayerGui:WaitForChild("FriendInviteUI")
local Content = FriendInviteUI.Background.Content
local Friends = Content.Friends
local Reward = Content.Reward
local CantInvite = FriendInviteUI.Background.CantInvite
local InviteFrame = Assets.UI.Friend.InviteFrame
local v2 = Maid.new()
local Checkmark = Assets.UI.Battlepass.Checkmark
FriendHelper.CanSendInvite(userId)

local friendsAsync = Players:GetFriendsAsync((tonumber(userId)))

local clonesByVisitorId = {}

local function iterPageItems(friendsAsync2) -- 1 equivalent call inferred from this helper
	return coroutine.wrap(function()
		local v3 = 1

		while true do
			for _, v4 in friendsAsync2:GetCurrentPage(), nil, nil do
				coroutine.yield(v4, v3)
			end

			if friendsAsync2.IsFinished then
				break
			end

			friendsAsync2:AdvanceToNextPageAsync()
			v3 += 1
		end
	end)
end

local function createFriendButton(k)
	local clone = InviteFrame:Clone()
	clone.Username.Text = k.DisplayName
	task.spawn(function()
		pcall(function()
			clone.Icon.Image = Players:GetUserThumbnailAsync(
				k.VisitorId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size180x180
			)
		end)
	end)

	Button.Create(clone, function()
		local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
		experienceInviteOptions.InviteUser = k.VisitorId
		experienceInviteOptions.PromptMessage = FriendConstants.PROMPT_MESSAGE(k)
		experienceInviteOptions.InviteMessageId = FriendConstants.INVITE_MESSAGE_ID

		FriendHelper.PromptGameInvite(experienceInviteOptions)
	end)

	clone.Parent = Friends
	clonesByVisitorId[tostring(k.VisitorId)] = clone
end

Friends.Visible = true
CantInvite.Visible = false

for k, _ in iterPageItems(friendsAsync), nil, nil do -- inferred equivalent call
	k.VisitorId = k.Id
	createFriendButton(k)
end

local function update() -- 1 equivalent call inferred from this helper
	if v.Data.rewardClaims[`Friend{v.Data.inviteRewardCount}`] then
		local clone = Checkmark:Clone()
		clone.Parent = Reward
		v2.checkmark = clone
	end
end

update() -- inferred equivalent call
v:ListenToWrite("RewardClaims", update)

local v3 = Inventories.fromList({}, Reward.Item, "misc", "v1")
Inventories.AddList(v3, {
	Equipped = {
		writeLib = FriendConstants.INVITE_REWARD.writeLib,
		value = FriendConstants.INVITE_REWARD.value
	}
})

Content.Reward.Header.Text = FriendConstants.HEADER
Content.Reward.Info.Text = FriendConstants.DESCRIPTION