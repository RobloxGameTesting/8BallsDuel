local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.Libraries.Modules.Events)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Colours = require(ReplicatedStorage.Libraries.Modules.Colours)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local LocalPlayer = Players.LocalPlayer
local Quest = ReplicatedStorage.Assets.UI.Battlepass.Quest

local v = { "IncrementMission", "EventMissions", "EventWeeklyMissions", "EventQuestClaim" }

local v2 = { Daily = "missions", Weekly = "weeklyQuests" }

local PoolQuestPanel = {}

local function questsFor(p: string)
	local success, result = pcall(function()
		if p == "Daily" then
			return (Events:GetMissions(LocalPlayer))
		end

		return (Events:GetWeeklyMissions(LocalPlayer))
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return {}
end

local function fitCanvas(p) -- 2 equivalent calls inferred from this helper
	local uiListLayout = p.List:FindFirstChildWhichIsA("UIListLayout")

	if uiListLayout then
		p.List.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y)
	end
end

local function drawRow(category: string, k, data)
	local clone = Quest:Clone()
	local v3 = math.max(tonumber(data.requirement) or 1, 1)
	local v4 = math.clamp(tonumber(data.progress) or 0, 0, v3) / v3
	local visible

	if data.completed == true then
		visible = not data.claimed and Events:IsActive()
	else
		visible = false
	end

	clone.Size = UDim2.fromScale(0.98, 1)

	local uiAspectRatioConstraint = clone:FindFirstChildOfClass("UIAspectRatioConstraint")

	if uiAspectRatioConstraint then
		uiAspectRatioConstraint.AspectRatio = 4
	end

	clone.Background.Description.Text = tostring(data.description or "")
	clone.Background.Reward.Content.Amount.Text = tostring(data.reward or 0)
	clone.Background.Reward.Content.Label.Text = "Progress"
	clone.Background.Reward.Content.Checkmark.Visible = data.claimed == true
	clone.ProgressBar.Contents.Percent.Bar.UIGradient.Color = Colours.quest
	clone.ProgressBar.Contents.Percent.Size = UDim2.new(v4, 0, 1, 0)
	clone.ProgressBar.Contents.Percent.Bar.Size = UDim2.new(not (v4 > 0) and 0 or 1 / v4, 0, 1, 0)

	clone.LayoutOrder = visible and -10000000 or data.claimed and 10000000 or tonumber(data.reward) or 0

	clone.SeasonPass.Visible = visible
	clone.SeasonPass.AnchorPoint = Vector2.new(1, 0.5)
	clone.SeasonPass.Position = UDim2.fromScale(0.98, 0.5)
	clone.SeasonPass.Size = UDim2.fromScale(0.3, 0.8)
	clone.Background.Reward.Visible = not visible

	if visible then
		Button.Create(clone.SeasonPass, function()
			RemoteSignals.FireServer("Events", "EventQuestClaim", v2[category], k)
			Sounds.Play(Sounds.new({ "UserInterface", "Transactions", "Starterpack" }, nil), nil, true)
		end)
	end

	return clone
end

local function makeSeasonCover(p)
	local list = p.List
	local zIndex = list.ZIndex

	for _, guiObject in Quest:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			zIndex = math.max(zIndex, guiObject.ZIndex)
		end
	end

	local seasonCover = Instance.new("TextButton")
	seasonCover.Name = "SeasonCover"
	seasonCover.AnchorPoint = list.AnchorPoint
	seasonCover.Position = list.Position
	seasonCover.Size = list.Size
	seasonCover.BackgroundColor3 = Color3.new(0, 0, 0)
	seasonCover.BackgroundTransparency = 0.2
	seasonCover.BorderSizePixel = 0
	seasonCover.AutoButtonColor = false
	seasonCover.Text = ""
	seasonCover.ZIndex = zIndex + 10
	seasonCover.Visible = false

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.AnchorPoint = Vector2.new(0.5, 0.5)
	message.Position = UDim2.fromScale(0.5, 0.45)
	message.Size = UDim2.fromScale(0.86, 0.2)
	message.BackgroundTransparency = 1
	message.FontFace = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	message.Text = "The current event ended. New event coming soon!"
	message.TextColor3 = Color3.new(1, 1, 1)
	message.TextScaled = true
	message.TextWrapped = true
	message.ZIndex = zIndex + 11
	message.Parent = seasonCover

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(20, 20, 20)
	uiStroke.Thickness = 2
	uiStroke.Parent = message

	seasonCover.Parent = list.Parent

	return seasonCover
end

function PoolQuestPanel.Refresh(data)
	Button.SetColours(data.Tabs, data.Category, "blue", "white")

	if data.SeasonCover then
		data.SeasonCover.Visible = not Events:IsActive()
	end

	for k, tab in data.Tabs do
		local count = 0

		for _ in questsFor(k) do
			count += 1
		end

		tab.Content.Label.Text = string.format("%s [ %d ]", k:upper(), count)
	end

	for _, guiObject in data.List:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for k, v3 in questsFor(data.Category) do
		local drawRow_2 = drawRow(data.Category, k, v3)
		drawRow_2.Parent = data.List
	end

	fitCanvas(data) -- inferred equivalent call
end

function PoolQuestPanel.SetOpen(p, visible: boolean)
	p.Root.Visible = visible

	if visible then
		PoolQuestPanel.Refresh(p)
	end
end

function PoolQuestPanel.Toggle(p)
	PoolQuestPanel.SetOpen(p, not p.Root.Visible)
end

function PoolQuestPanel.new(instance)
	local questsPanel = instance:FindFirstChild("QuestsPanel")
	local hud = instance:FindFirstChild("Hud")
	local questsButton = hud and hud:FindFirstChild("QuestsButton")
	local header = questsPanel and questsPanel:FindFirstChild("Header")

	if not (questsPanel and questsPanel:IsA("Frame") and questsButton and questsButton:IsA("GuiButton") and header) then
		warn("[PoolQuestPanel] QuestsPanel (with Header) or Hud.QuestsButton is missing from PoolGameUI")

		return nil
	end

	local maid = Maid.new()

	questsPanel.Visible = false

	local v3 = {
		Root = questsPanel,
		Button = questsButton,
		List = questsPanel:FindFirstChild("List"),
		Tabs = { Daily = header.Daily, Weekly = header.Weekly },
		Category = "Daily",
		SeasonCover = nil,
		Maid = maid
	}

	v3.SeasonCover = makeSeasonCover(v3)
	maid:GiveTask(v3.SeasonCover)

	maid:GiveTask(Events.Ended:Connect(function()
		if questsPanel.Visible then
			PoolQuestPanel.Refresh(v3)
		end
	end))

	maid:GiveTask(questsButton.Activated:Connect(function()
		PoolQuestPanel.Toggle(v3)
	end))

	Button.Create(header.Exit, function()
		PoolQuestPanel.SetOpen(v3, false)
	end)

	for k, tab in v3.Tabs do
		Button.Create(tab, function()
			v3.Category = k
			PoolQuestPanel.Refresh(v3)
		end)
	end

	local uiListLayout = v3.List:FindFirstChildWhichIsA("UIListLayout")

	if uiListLayout then
		maid:GiveTask(uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			fitCanvas(v3) -- inferred equivalent call
		end))
	end

	maid:GiveTask(questsButton:GetPropertyChangedSignal("Visible"):Connect(function()
		if not questsButton.Visible then
			PoolQuestPanel.SetOpen(v3, false)
		end
	end))

	local exitButton = hud:FindFirstChild("ExitButton")

	local function exitShowing() -- 2 equivalent calls inferred from this helper
		return exitButton ~= nil and exitButton:IsA("GuiObject") and exitButton.Visible
	end

	local function placeButton() -- 1 equivalent call inferred from this helper
		if exitShowing() and questsButton.Visible then -- inferred equivalent call
			questsButton.Visible = false
		end
	end

	if exitButton and exitButton:IsA("GuiObject") then
		maid:GiveTask(exitButton:GetPropertyChangedSignal("Visible"):Connect(function()
			if exitShowing() then -- inferred equivalent call
				questsButton.Visible = false
			elseif hud:IsA("GuiObject") and hud.Visible then
				questsButton.Visible = true
			end
		end))
	end

	maid:GiveTask(questsButton:GetPropertyChangedSignal("Visible"):Connect(placeButton))
	placeButton() -- inferred equivalent call
	task.spawn(function()
		local userId = tostring(LocalPlayer.UserId)
		local v4 = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)

		if not v4 then
			return
		end

		for _, v5 in v do
			local connection = v4:ListenToWrite(v5, function()
				if questsPanel.Visible then
					PoolQuestPanel.Refresh(v3)
				end
			end)

			maid:GiveTask(function()
				connection:Disconnect()
			end)
		end
	end)

	return v3
end

function PoolQuestPanel:Destroy()
	self.Maid:Destroy()
end

return PoolQuestPanel