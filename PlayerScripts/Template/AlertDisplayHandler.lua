local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
local AlertDisplays = require(ReplicatedStorage.Libraries.GameSpecific.AlertDisplays)

local userId = tostring(Players.LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)

local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local v2 = {}

local function onScreen(instance)
	while instance do
		if instance:IsA("GuiObject") and not instance.Visible then
			return false
		end

		if instance:IsA("LayerCollector") then
			return instance.Enabled
		end

		instance = instance.Parent
	end

	return false
end

local function register(instance)
	if v2[instance] then
		return
	end

	v2[instance] = true

	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		local function fit() -- 1 equivalent call inferred from this helper
			uiStroke.Thickness = math.max(1, (math.round(instance.AbsoluteSize.X * 0.08)))
		end

		fit() -- inferred equivalent call
		instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	end

	instance.Destroying:Connect(function()
		v2[instance] = nil
	end)
end

task.spawn(function()
	while true do
		for k in v2 do
			local burst = k:FindFirstChild("Burst")

			if not (burst and burst:IsA("GuiObject") and onScreen(k)) then
				continue
			end

			burst.Size = UDim2.fromScale(1, 1)
			burst.BackgroundTransparency = 0.25

			TweenService:Create(burst, tweenInfo, {
				Size = UDim2.fromScale(2.2, 2.2),
				BackgroundTransparency = 1
			}):Play()
		end

		task.wait(3)
	end
end)

local function resolve(alertDisplay) -- 1 equivalent call inferred from this helper
	local alerts = alertDisplay.alerts

	if typeof(alerts) == "function" then
		return alerts()
	end

	return alerts
end

local function update(alertDisplay, items)
	local enabled = alertDisplay.enabled()
	local display = alertDisplay.display

	for _, item in items do
		item.Visible = enabled > 0

		local textLabel = item:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.Text = display == "#" and tostring(enabled) or "!"
		end
	end
end

for _, alertDisplay in AlertDisplays do
	task.spawn(function()
		local v3 = resolve(alertDisplay) -- inferred equivalent call

		for _, v4 in v3 do
			register(v4)
		end

		update(alertDisplay, v3)

		for _, writeLib in alertDisplay.writeLibs do
			v:ListenToWrite(writeLib, function()
				update(alertDisplay, v3)
			end)
		end

		if alertDisplay.signals then
			for _, v4 in alertDisplay.signals() do
				v4:Connect(function()
					update(alertDisplay, v3)
				end)
			end
		end
	end)
end