local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolSettingsMenu = {}

local Menu = PoolConstants.Menu

PoolSettingsMenu.Settings = {
	{
		Id = "poolAimMode",
		Title = "AIM MODE",
		Description = "How your finger or cursor moves the cue.",
		Options = {
			{
				Value = "Drag",
				Label = "DRAG",
				Blurb = "Swipe to turn the cue. Small moves for fine aim."
			},
			{ Value = "Tap", Label = "TAP", Blurb = "Point the cue straight at where you touch." }
		},
		MobileOnly = true
	},
	{
		Id = "poolAimSensitivity",
		Title = "AIM SENSITIVITY",
		Description = "How far the cue turns when you swipe.",
		Options = {},
		MobileOnly = true
	},
	{
		Id = "poolSoundVolume",
		Title = "SOUND EFFECTS",
		Description = "How loud the balls, cushions and pockets are.",
		Options = {}
	},
	{
		Id = "poolHaptics",
		Title = "VIBRATION",
		Description = "A short buzz when you pot one of your balls.",
		Options = {
			{ Value = "On", Label = "ON", Blurb = "Feel every ball you sink." },
			{ Value = "Off", Label = "OFF", Blurb = "No vibration." }
		}
	},
	{
		Id = "poolHidePredictions",
		Title = "PREDICTION LINES",
		Description = "The guides showing where the balls will go.",
		Options = {
			{
				Value = "Off",
				Label = "SHOW",
				Blurb = "See the path the cue ball and target will take."
			},
			{
				Value = "On",
				Label = "HIDE",
				Blurb = "Aim by eye. Harder, and the table reads cleaner."
			}
		}
	},
	{
		Id = "poolShowSkins",
		Title = "TABLE SKINS",
		Description = "Custom cloth and ball designs.",
		Options = {
			{ Value = "On", Label = "ON", Blurb = "Show skins once they arrive." },
			{ Value = "Off", Label = "OFF", Blurb = "Always use the default table and balls." }
		}
	}
}

for _, setting in PoolSettingsMenu.Settings do
	if setting.Id ~= "poolSoundVolume" then
		continue
	end

	for i = 1, 10 do
		local blurb

		if i == 1 then
			blurb = "Barely there."
		elseif i <= 3 then
			blurb = "Quiet. The table is in the background."
		elseif i <= 7 then
			blurb = "Balanced."
		elseif i < 10 then
			blurb = "Loud. Every contact lands."
		else
			blurb = "As loud as it gets."
		end

		table.insert(setting.Options, { Value = tostring(i), Label = tostring(i), Blurb = blurb })
	end
end

local v = {
	"Slowest. Big swipes for tiny adjustments -- best for long pots.",
	"Slow. Plenty of room to fine-tune the angle.",
	"Middle ground.",
	"Quick. Turns most of the way with your thumb.",
	"Fastest. The cue follows your thumb exactly."
}

for _, setting in PoolSettingsMenu.Settings do
	if setting.Id ~= "poolAimSensitivity" then
		continue
	end

	for i = 1, #PoolConstants.DragAimGain do
		table.insert(setting.Options, {
			Value = tostring(i),
			Label = tostring(i),
			Blurb = v[i] or ""
		})
	end
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolSettingsMenu: %s.%s is missing (looking for %q)",
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

local function captionOf(instance)
	local top = instance:FindFirstChild("Top")

	return if top and top:IsA("TextLabel") then top else instance
end

local function setLabel(frame, childName: string, text: string) -- 2 equivalent calls inferred from this helper
	local label = frame:FindFirstChild(childName)

	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

function PoolSettingsMenu.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)

	local settingsMenu = instance:WaitForChild("SettingsMenu")
	settingsMenu.Visible = false

	settingsMenu.Active = true

	local v2 = bind(settingsMenu, "List")
	maid:GiveTask(bind(settingsMenu, "Back").Activated:Connect(function()
		bindableEvent2:Fire()
	end))
	local count = 0
	local rows = {}

	for _, setting in PoolSettingsMenu.Settings do
		local frame = v2:FindFirstChild(setting.Id)

		if not (frame and frame:IsA("Frame")) then
			continue
		end

		local visible = not setting.MobileOnly or Device:Get() == "Mobile"

		frame.Visible = visible

		if not visible then
			continue
		end

		count += 1
		frame.LayoutOrder = count

		setLabel(frame, "Title", setting.Title) -- inferred equivalent call
		setLabel(frame, "Description", setting.Description) -- inferred equivalent call

		local buttons = {}

		for _, option in setting.Options do
			local v3 = bind(frame, option.Value)
			buttons[option.Value] = v3
			local label = v3:FindFirstChild("Top")

			if label then
				if not label:IsA("TextLabel") then
					label = v3
				end
			else
				label = v3
			end

			label.Text = option.Label
			local v4 = option
			maid:GiveTask(v3.Activated:Connect(function()
				bindableEvent:Fire(setting.Id, v4.Value)
			end))
		end

		rows[setting.Id] = { Buttons = buttons, Blurb = bind(frame, "Blurb") }
	end

	local empty = settingsMenu:FindFirstChild("Empty")

	if empty and empty:IsA("GuiObject") then
		empty.Visible = count == 0
	end

	return {
		Root = settingsMenu,
		Rows = rows,
		Changed = bindableEvent.Event,
		ChangedBindable = bindableEvent,
		Closed = bindableEvent2.Event,
		CloseBindable = bindableEvent2,
		Maid = maid
	}
end

local PlayPrimary = Menu.PlayPrimary
local PlayPrimaryShade = Menu.PlayPrimaryShade
local color = Color3.fromRGB(48, 53, 60)
local color2 = Color3.fromRGB(28, 31, 36)

function PoolSettingsMenu.SetValue(p, p2: string, p3: string)
	local row = p.Rows[p2]

	if not row then
		return
	end

	for k, button in row.Buttons do
		local v2 = k == p3
		local uiGradient = button:FindFirstChildOfClass("UIGradient")

		if uiGradient then
			button.BackgroundColor3 = Color3.new(1, 1, 1)
			local color3

			if v2 then
				color3 = ColorSequence.new(PlayPrimary, PlayPrimaryShade)
			else
				color3 = ColorSequence.new(color, color2)
			end

			uiGradient.Color = color3
		else
			local setColour = PoolButtonSkin.SetColour
			local v3 = if v2 then PlayPrimary else color
			setColour(button, v3)
		end
	end

	for _, setting in PoolSettingsMenu.Settings do
		if setting.Id ~= p2 then
			continue
		end

		for _, option in setting.Options do
			if option.Value == p3 then
				row.Blurb.Text = option.Blurb
			end
		end
	end
end

function PoolSettingsMenu.SetVisible(p, visible: boolean)
	p.Root.Visible = visible
end

function PoolSettingsMenu.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolSettingsMenu