local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FriendConstants = require(ReplicatedStorage.Libraries.Constants.FriendConstants)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local friendBoost = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI").FriendBoost
local label = friendBoost.Display.Label
local invite = friendBoost.Invite
local canSendInvite = FriendHelper.CanSendInvite(userId)

if not canSendInvite then
	warn("Can't invite")
	return
end

local function update()
	label.Text = `Friend boost: {math.clamp(
		100 + #FriendHelper.GetFriendsInServer(userId) * FriendConstants.INVITE_BOOST,
		1,
		FriendConstants.INVITE_BOOST_LIMIT
	) - 100}%`
end

label.Text = `Friend boost: {math.clamp(
	100 + #FriendHelper.GetFriendsInServer(userId) * FriendConstants.INVITE_BOOST,
	1,
	FriendConstants.INVITE_BOOST_LIMIT
) - 100}%`

FriendHelper.Added:Connect(update)
FriendHelper.Removing:Connect(update)

Button.Create(invite, function()
	if canSendInvite then
		local onlineFriends = FriendHelper.GetOnlineFriends(userId)
		local onlineFriend = onlineFriends[Random.new():NextInteger(1, #onlineFriends)]

		if not onlineFriend then
			return
		end

		local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
		experienceInviteOptions.InviteUser = onlineFriend.VisitorId
		experienceInviteOptions.PromptMessage = `Invite your friend for a +{FriendConstants.INVITE_BOOST} boost!`

		FriendHelper.PromptGameInvite(experienceInviteOptions)
	end
end)