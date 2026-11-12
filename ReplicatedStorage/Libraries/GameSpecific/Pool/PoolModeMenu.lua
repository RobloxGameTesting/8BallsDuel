local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolModeMenu = {}

local color = Color3.fromRGB(28, 32, 38)

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolModeMenu: %s.%s is missing (looking for %q)",
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

function PoolModeMenu.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)

	local modeMenu = instance:WaitForChild("ModeMenu")
	modeMenu.Visible = false

	local difficulty = bind(modeMenu, "Difficulty")
	local modeRow = bind(modeMenu, "ModeRow")
	local back = bind(modeMenu, "Back")

	local v = {
		Root = modeMenu,
		Title = bind(modeMenu, "Title"),
		ModeRow = modeRow,
		Difficulty = difficulty,
		Back = back,
		Levels = {},
		DifficultiesOnly = false,
		Selected = bindableEvent.Event,
		Exit = bindableEvent2.Event,
		Maid = maid
	}

	maid:GiveTask(bind(modeRow, "Solo").Activated:Connect(function()
		bindableEvent:Fire("Solo")
	end))

	maid:GiveTask(bind(modeRow, "Bots").Activated:Connect(function()
		PoolModeMenu.ShowDifficulties(v, true)
	end))

	maid:GiveTask(bind(modeRow, "Trickshot").Activated:Connect(function()
		bindableEvent:Fire("Trickshot")
	end))

	for _, level in PoolConstants.Bots.Levels do
		local button = difficulty:FindFirstChild(level.Id)

		if not (button and button:IsA("TextButton")) then
			continue
		end

		local top = button:FindFirstChild("Top")

		local levels = v.Levels
		local id = level.Id
		local label

		if top and top:IsA("TextLabel") then
			label = top
		end

		local name

		if top and top:IsA("TextLabel") then
			name = top.Text
		else
			name = level.Name
		end

		levels[id] = {
			Button = button,
			Label = label,
			Name = name,
			Colour = button.BackgroundColor3,
			Unlocked = true
		}

		maid:GiveTask(button.Activated:Connect(function()
			local level2 = v.Levels[level.Id]

			if level2 and not level2.Unlocked then
				return
			end

			bindableEvent:Fire(level.Id)
		end))
	end

	maid:GiveTask(back.Activated:Connect(function()
		if difficulty.Visible and not v.DifficultiesOnly then
			PoolModeMenu.ShowDifficulties(v, false)
		else
			bindableEvent2:Fire()
		end
	end))

	return v
end

function PoolModeMenu.SetProgress(p, p2)
	for _, level in PoolConstants.Bots.Levels do
		local level2 = p.Levels[level.Id]

		if not level2 then
			continue
		end

		local isBotUnlocked = PoolConstants.IsBotUnlocked(p2, level.Id)

		level2.Unlocked = isBotUnlocked

		level2.Button.Active = isBotUnlocked
		level2.Button.Selectable = isBotUnlocked
		level2.Button.AutoButtonColor = isBotUnlocked
		local setColour = PoolButtonSkin.SetColour
		local button = level2.Button
		local v

		if isBotUnlocked then
			v = level2.Colour
		else
			v = level2.Colour:Lerp(color, 0.82)
		end

		setColour(button, v)

		if not level2.Label then
			continue
		end

		local previousBotLevel = PoolConstants.PreviousBotLevel(level.Id)

		local label = level2.Label
		local text

		if isBotUnlocked or not previousBotLevel then
			text = level2.Name
		else
			text = string.format("BEAT %s", string.upper(previousBotLevel.Name))
		end

		label.Text = text
	end
end

function PoolModeMenu.ShowDifficulties(data, visible: boolean)
	data.Difficulty.Visible = visible
	data.ModeRow.Visible = not visible
	data.Title.Text = visible and "CHOOSE A BOT" or "PLAY OFFLINE"
end

function PoolModeMenu:SetVisible(visible: boolean)
	self.Root.Visible = visible

	if visible then
		self.DifficultiesOnly = false
		PoolModeMenu.ShowDifficulties(self, false)
	end
end

function PoolModeMenu:OpenBots()
	self.Root.Visible = true
	self.DifficultiesOnly = true
	PoolModeMenu.ShowDifficulties(self, true)
end

function PoolModeMenu.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolModeMenu