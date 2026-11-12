local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolTrickshotStyle = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTrickshotStyle)
local PoolButtonSkin = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolButtonSkin)

local color = Color3.fromRGB(250, 206, 70)
local color2 = Color3.fromRGB(64, 72, 88)

local color3 = Color3.fromRGB(114, 220, 78)
local color4 = Color3.fromRGB(70, 78, 92)

local function getAuthoredTree() -- 1 equivalent call inferred from this helper
	local frame = PoolTrickshotStyle.Authored("PoolTrickshotUI", "Result")

	assert(frame:IsA("Frame"), "[Trickshot] PoolTrickshotUI.Result must be a Frame")

	return frame
end

local PoolLevelResult = {}

function PoolLevelResult.new(parent)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)
	maid:GiveTask(bindableEvent3)

	local trickshotResult = getAuthoredTree():Clone() -- inferred equivalent call
	trickshotResult.Name = "TrickshotResult"
	trickshotResult.Visible = false
	trickshotResult.Parent = parent

	maid:GiveTask(trickshotResult)

	local v = {
		Root = trickshotResult,
		Level = trickshotResult:FindFirstChild("Level"),
		Title = trickshotResult:WaitForChild("Title"),
		Summary = trickshotResult:WaitForChild("Summary"),
		Stars = trickshotResult:WaitForChild("Stars"),
		Retry = trickshotResult:WaitForChild("Retry"),
		Quit = trickshotResult:WaitForChild("Quit"),
		RetryRequested = bindableEvent.Event,
		NextRequested = bindableEvent2.Event,
		QuitRequested = bindableEvent3.Event,
		Primary = "Replay",
		Maid = maid
	}

	local textLabel = v.Quit:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel then
		textLabel.Text = "LOBBY"
	end

	maid:GiveTask(v.Retry.Activated:Connect(function()
		if not v.Retry.Active then
			return
		end

		trickshotResult.Visible = false

		if v.Primary == "Next" then
			bindableEvent2:Fire()
		else
			bindableEvent:Fire()
		end
	end))

	maid:GiveTask(v.Quit.Activated:Connect(function()
		trickshotResult.Visible = false
		bindableEvent3:Fire()
	end))

	return v
end

function PoolLevelResult:Show(flag: boolean, p: number, value: string?, flag2: boolean?, p2: number?, flag3: boolean?, value2: string?)
	self.Root.Visible = true

	local level = self.Level

	if level then
		level.Text = value2 or ""
		level.Visible = value2 ~= nil
	end

	if flag then
		if p >= 1 then
			self.Title.Text = "LEVEL COMPLETE"
		else
			self.Title.Text = "MISSED"
		end
	else
		self.Title.Text = "COULD NOT SCORE"
	end

	local text = value or ""

	if flag2 then
		text ..= not p2 and "  --  lost a life" or string.format("  --  lost a life, %d left", p2)
	end

	self.Summary.Text = text

	for i = 1, 4 do
		local child = self.Stars:FindFirstChild("Star" .. i)

		if not child then
			continue
		end

		local v = flag and i <= p
		local backgroundColor = if v then color else color2
		child.BackgroundColor3 = backgroundColor
		child.BackgroundTransparency = v and 0 or 0.35
	end

	local textLabel = self.Retry:FindFirstChildWhichIsA("TextLabel", true)

	if flag3 and flag then
		self.Primary = "Next"
		self.Retry.Active = true
		self.Retry.AutoButtonColor = true
		PoolButtonSkin.SetColour(self.Retry, color3)

		if textLabel then
			textLabel.Text = "NEXT"
			textLabel.TextTransparency = 0
		end
	else
		self.Primary = "Replay"

		local v = p2 == nil or p2 > 0

		self.Retry.Active = v
		self.Retry.AutoButtonColor = v
		local setColour = PoolButtonSkin.SetColour
		local retry = self.Retry
		local v2 = if v then color3 else color4
		setColour(retry, v2)

		if textLabel then
			textLabel.Text = v and "REPLAY" or "NO LIVES"
			textLabel.TextTransparency = v and 0 or 0.35
		end
	end
end

function PoolLevelResult.Hide(p)
	p.Root.Visible = false
end

function PoolLevelResult:Destroy()
	self.Maid:Destroy()
end

return PoolLevelResult