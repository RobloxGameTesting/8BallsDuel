local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local FriendConstants = require(ReplicatedStorage.Libraries.Constants.FriendConstants)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolInviteReward = require(Pool.PoolInviteReward)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolInviteMenu = {}

local v = {
	Tier1 = "COMMON",
	Tier2 = "UNCOMMON",
	Tier3 = "RARE",
	Tier4 = "EPIC",
	Tier5 = "LEGENDARY"
}

local v2 = nil

local v3 = nil

local function need(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolInviteMenu: %s.%s is missing (looking for %q)",
					instance:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

local function bindGui(localPlayer)
	if v2 and v2.Gui.Parent then
		return v2
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("PoolInviteUI")

	if not gui then
		gui = ReplicatedStorage.UI.PoolInviteUI:Clone()
		gui.Parent = playerGui
	end

	gui.Enabled = false

	local dimmer = need(gui, "Dimmer")
	local v4 = need(gui, "Root")

	local v5 = {
		Gui = gui,
		Dimmer = dimmer,
		DimmerTransparency = dimmer.BackgroundTransparency,
		Scale = v4:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", v4),
		Picture = need(v4, "Rewards.Picture"),
		Rays = v4:FindFirstChild("Rays", true),
		Preview = need(v4, "Rewards.Picture.Preview"),
		Stamp = need(v4, "Rewards.Picture.Unlocked"),
		ItemName = need(v4, "Rewards.ItemName"),
		Rarity = need(v4, "Rewards.Rarity"),
		Body = need(v4, "Rewards.Body"),
		Scroll = need(v4, "Invite.Friends"),
		Grid = need(v4, "Invite.Friends"):FindFirstChildOfClass("UIGridLayout"),
		Status = need(v4, "Invite.Status"),
		Anyone = need(v4, "Invite.InviteAnyone"),
		Locked = need(v4, "Invite.Locked"),
		Close = need(v4, "Close"),
		RowTemplate = need(gui, "Templates.FriendRow")
	}

	local title = v4:FindFirstChild("Title", true)

	if title and title:IsA("TextLabel") then
		title.Text = PoolInviteReward.Title
	end

	v2 = v5

	return v5
end

local function colourAttribute(rowTemplate, attributeName: string, color: Color3) -- 6 equivalent calls inferred from this helper
	local attribute = rowTemplate:GetAttribute(attributeName)

	return if typeof(attribute) == "Color3" then attribute else color
end

local function setButton(instance, text: string, color: Color3, flag: boolean) -- 3 equivalent calls inferred from this helper
	PoolButtonSkin.SetColour(instance, color)
	instance.Active = flag
	instance.AutoButtonColor = flag
	instance.Selectable = flag

	local label = instance:FindFirstChild("Label", true)

	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function rarityOf(item)
	local result = item and item.rarity

	if typeof(result) == "function" then
		local success
		success, result = pcall(result, {}, item)

		if not success then
			result = nil
		end
	end

	return if typeof(result) == "string" then result else "Tier1"
end

local function rarityColour(p: string) -- 1 equivalent call inferred from this helper
	local rarityData = Rarities.GetRarityData(p)
	local keypoints = rarityData and rarityData.colour and rarityData.colour.Keypoints

	if keypoints and keypoints[#keypoints] then
		return keypoints[#keypoints].Value
	end

	return nil
end

local function loadFriends(localPlayer)
	local v4 = {}
	local v5 = {}

	local function add(userId: number, displayName: string?, value: string?, flag: boolean)
		local v6 = v4[userId]

		if v6 then
			v6.Online = v6.Online or flag

			return
		end

		local here = Players:GetPlayerByUserId(userId) ~= nil
		local v7 = {
			UserId = userId,
			DisplayName = tostring(displayName or value or userId),
			Username = tostring(value or ""),
			Online = here or flag,
			Here = here
		}

		v4[userId] = v7
		table.insert(v5, v7)
	end

	local v6 = 0
	local v7 = nil

	for i = 1, 3 do
		local success, result = pcall(function()
			return Players:GetFriendsAsync(localPlayer.UserId)
		end)

		if success and result then
			local success2, result2 = pcall(FriendHelper.ConvertPagesToList, result)

			if success2 and typeof(result2) == "table" then
				for _, v8 in result2 do
					local id = tonumber(v8.Id)

					if id then
						add(id, v8.DisplayName, v8.Username, v8.IsOnline == true)
					end
				end

				v6 = #result2
			else
				v7 = tostring(result2)
			end
		else
			v7 = tostring(result)
		end

		if v6 > 0 then
			v7 = nil
			break
		end

		task.wait(i * 0.75)
	end

	local success, result = pcall(function()
		return localPlayer:GetFriendsOnlineAsync(200)
	end)

	local count = 0

	if success and typeof(result) == "table" then
		for _, v8 in result do
			local visitorId = tonumber(v8.VisitorId)

			if not visitorId then
				continue
			end

			count += 1
			add(visitorId, v8.DisplayName, v8.UserName, true)
		end

		v7 = nil
	elseif v6 == 0 then
		v7 = v7 or tostring(result)
	end

	if #v5 == 0 and v6 == 0 then
		warn(string.format(
			"[PoolInviteMenu] no friends returned (full=%d, online=%d, error=%s)",
			v6,
			count,
			(tostring(v7))
		))
	end

	table.sort(v5, function(a, b): boolean
		local v8 = a.Here and 0 or a.Online and 1 or 2
		local v9 = b.Here and 0 or b.Online and 1 or 2

		if v8 == v9 then
			return string.lower(a.DisplayName) < string.lower(b.DisplayName)
		end

		return v8 < v9
	end)

	if #v5 == 0 then
		return v5, v7
	end

	return v5, nil
end

local function promptInvite(userId: number?, displayName: string?) -- 3 equivalent calls inferred from this helper
	local experienceInviteOptions = Instance.new("ExperienceInviteOptions")

	if userId then
		experienceInviteOptions.InviteUser = userId
		experienceInviteOptions.PromptMessage = string.format(
			"Invite %s to play pool? Play together and you both unlock a FREE cue stick!",
			displayName or "your friend"
		)
	else
		experienceInviteOptions.PromptMessage = "Invite a friend to play pool? Play together and you both unlock a FREE cue stick!"
	end

	experienceInviteOptions.InviteMessageId = FriendConstants.INVITE_MESSAGE_ID

	FriendHelper.PromptGameInvite(experienceInviteOptions)
end

function PoolInviteMenu.PromptAnyone()
	promptInvite(nil) -- inferred equivalent call
end

function PoolInviteMenu.IsOpen(): boolean
	return v3 ~= nil
end

function PoolInviteMenu.Close()
	local v4 = v3
	local v5 = v2

	if not v4 then
		return
	end

	v3 = nil

	if v4.WriteConnection then
		pcall(function()
			v4.WriteConnection:Disconnect()
		end)
	end

	if v5 then
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v5.Gui) then
			GuiService.SelectedObject = nil
		end

		v5.Gui.Enabled = false
	end

	local previousSelection = v4.PreviousSelection

	if previousSelection and previousSelection.Parent and previousSelection.Visible then
		GuiService.SelectedObject = previousSelection
	end

	v4.Maid:DoCleaning()
end

function PoolInviteMenu.Open(object)
	if v3 then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local v4 = bindGui(localPlayer)
	local maid = Maid.new()

	local v5 = { Maid = maid, WriteConnection = nil, PreviousSelection = GuiService.SelectedObject }

	v3 = v5

	local item = PoolInviteReward.GetItem()
	local v6 = rarityOf(item)

	PoolMenuWidgets.CuePreview(v4.Preview, PoolMenuWidgets.FindSkinModel(item))
	local itemName = v4.ItemName
	local v7

	if item and item.name then
		v7 = tostring(item.name)
	else
		v7 = PoolInviteReward.Item
	end

	itemName.Text = string.upper(v7)
	local itemName2 = v4.ItemName
	itemName2.TextColor3 = rarityColour(v6) or v4.ItemName.TextColor3 -- inferred equivalent call
	v4.Rarity.Text = (v[v6] or v6) .. " CUE STICK"

	local function refreshClaimed() -- 1 equivalent call inferred from this helper
		local isClaimed = PoolInviteReward.IsClaimed(object and object.Data)

		v4.Stamp.Visible = isClaimed
		v4.Preview.ImageTransparency = isClaimed and 0.35 or 0
		local body = v4.Body
		local text

		if isClaimed then
			text = PoolInviteReward.ClaimedBody
		else
			text = PoolInviteReward.Body
		end

		body.Text = text
	end

	refreshClaimed() -- inferred equivalent call

	if object then
		local success, result = pcall(function()
			return object:ListenToWrite("PoolOnboardingReward", refreshClaimed)
		end)

		if success then
			v5.WriteConnection = result
		end
	end

	v4.Scroll.Visible = true
	v4.Scroll.CanvasPosition = Vector2.zero
	v4.Status.Text = "Loading your friends..."
	v4.Status.Visible = true
	v4.Anyone.Visible = false
	v4.Locked.Visible = false

	local rowTemplate = v4.RowTemplate
	local v8 = colourAttribute(rowTemplate, "OnlineColour", Color3.fromRGB(120, 232, 110)) -- inferred equivalent call
	local v9 = colourAttribute(rowTemplate, "OfflineColour", Color3.fromRGB(150, 156, 168)) -- inferred equivalent call
	local v10 = colourAttribute(rowTemplate, "HereColour", Color3.fromRGB(255, 214, 90)) -- inferred equivalent call
	local v11 = colourAttribute(rowTemplate, "InviteColour", Color3.fromRGB(76, 204, 70)) -- inferred equivalent call
	local v12 = colourAttribute(rowTemplate, "InvitedColour", Color3.fromRGB(110, 118, 132)) -- inferred equivalent call
	local v13 = colourAttribute(rowTemplate, "HereButtonColour", Color3.fromRGB(150, 130, 60)) -- inferred equivalent call

	local function fitGrid()
		local grid = v4.Grid

		if not grid then
			return
		end

		local v14 = v4.Scroll.AbsoluteSize.X - 12
		local v15 = math.max(math.floor(v14 * 0.015), 4)
		local v16 = (v14 - v15) / 2

		grid.CellPadding = UDim2.fromOffset(v15, v15)
		grid.CellSize = UDim2.fromOffset(math.floor(v16), (math.floor(v16 * 0.27)))
	end

	fitGrid()
	maid:GiveTask(v4.Scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitGrid))

	local set = {}
	local invitesByUserId = {}
	local v14 = {}

	local function refreshButton(p: number)
		local v15 = invitesByUserId[p]
		local v16 = v14[p]

		if not (v15 and v16) then
			return
		end

		if v16.Here then
			setButton(v15, "HERE", v13, false) -- inferred equivalent call
		elseif set[p] then
			setButton(v15, "INVITED", v12, true) -- inferred equivalent call
		else
			setButton(v15, "INVITE", v11, true) -- inferred equivalent call
		end
	end

	local function buildRow(player, layoutOrder: number)
		local clone = rowTemplate:Clone()
		clone.Name = "Friend" .. player.UserId
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		clone.Parent = v4.Scroll
		maid:GiveTask(clone)

		local avatar = clone:FindFirstChild("Avatar", true)

		if avatar and avatar:IsA("ImageLabel") then
			avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.UserId)
		end

		local displayName = clone:FindFirstChild("DisplayName", true)

		if displayName and displayName:IsA("TextLabel") then
			displayName.Text = player.DisplayName
		end

		local status = clone:FindFirstChild("Status", true)

		if status and status:IsA("TextLabel") then
			status.Text = player.Here and "In this server" or player.Online and "Online" or "Offline"
			local textColor

			if player.Here then
				textColor = v10
			else
				textColor = if player.Online then v8 else v9
			end

			status.TextColor3 = textColor
		end

		local invite = clone:FindFirstChild("Invite", true)

		if not (invite and invite:IsA("GuiButton")) then
			return nil
		end

		invitesByUserId[player.UserId] = invite
		refreshButton(player.UserId)

		maid:GiveTask(invite.Activated:Connect(function()
			if not invite.Active then
				return
			end

			PoolAudio.PlayCue("MenuOpen")
			promptInvite(player.UserId, player.DisplayName) -- inferred equivalent call
		end))

		return invite
	end

	maid:GiveTask(v4.Anyone.Activated:Connect(function()
		promptInvite(nil) -- inferred equivalent call
	end))

	maid:GiveTask(SocialService.GameInvitePromptClosed:Connect(function(p, items)
		if p ~= localPlayer or typeof(items) ~= "table" then
			return
		end

		for _, item2 in items do
			local v15 = tonumber(item2)

			if not v15 then
				continue
			end

			set[v15] = true
			refreshButton(v15)
		end
	end))

	task.spawn(function()
		local canSendInvite = FriendHelper.CanSendInvite((tostring(localPlayer.UserId)))

		if v3 ~= v5 then
			return
		end

		if canSendInvite == false then
			v4.Status.Visible = false
			v4.Scroll.Visible = false
			v4.Locked.Visible = true
		else
			local v15, v16 = loadFriends(localPlayer)

			if v3 ~= v5 then
				return
			end

			if v16 then
				v4.Status.Text = "Couldn't load your friends right now. Close and try again."
				v4.Anyone.Visible = true
			elseif #v15 == 0 then
				v4.Status.Text = "No friends to show yet. Invite someone to play!"
				v4.Anyone.Visible = true

				if UserInputService.GamepadEnabled then
					GuiService.SelectedObject = v4.Anyone
				end
			else
				v4.Status.Visible = false
				local selectedObject = nil

				for k, v17 in v15 do
					if k > 200 then
						break
					end

					v14[v17.UserId] = v17

					local row = buildRow(v17, k)

					if selectedObject or not row or not row.Selectable then
						continue
					end

					selectedObject = row
				end

				if selectedObject and UserInputService.GamepadEnabled then
					GuiService.SelectedObject = selectedObject
				end
			end
		end
	end)

	local function requestClose() -- 1 equivalent call inferred from this helper
		if v3 ~= v5 then
			return
		end

		PoolAudio.PlayCue("MenuOpen")
		PoolInviteMenu.Close()
	end

	maid:GiveTask(v4.Close.Activated:Connect(requestClose))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonB then
			requestClose() -- inferred equivalent call
		end
	end))

	local rays = v4.Rays

	if rays then
		maid:GiveTask(RunService.RenderStepped:Connect(function(dt: number)
			rays.Rotation += dt * 12
		end))
	end

	v4.Gui.Enabled = true
	v4.Dimmer.BackgroundTransparency = 1
	v4.Scale.Scale = 0.9

	PoolAudio.PlayCue("MenuOpen")
	TweenService:Create(v4.Dimmer, TweenInfo.new(0.25), {
		BackgroundTransparency = v4.DimmerTransparency
	}):Play()
	TweenService:Create(v4.Scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

return PoolInviteMenu