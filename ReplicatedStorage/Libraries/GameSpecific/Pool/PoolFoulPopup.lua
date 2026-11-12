local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolRules = require(Pool.PoolRules)

local function iconFor(icon: string?)
	if not icon or icon == "" then
		return nil
	end

	local foulPopup = PoolConstants.FoulPopup
	local selected = foulPopup.Icons and foulPopup.Icons[icon]

	if typeof(selected) == "string" and selected ~= "" then
		return selected
	end

	if RunService:IsStudio() and typeof(foulPopup.IconStudioFolder) == "string" then
		return foulPopup.IconStudioFolder .. "Foul_" .. icon .. ".png"
	end

	return nil
end

local function applyIcon(state, value: string?)
	local icon = state.Icon
	local visible

	if icon == nil then
		visible = false
	else
		visible = value ~= nil
	end

	if icon then
		icon.Image = value or ""
		icon.Visible = visible
	end

	for k, v in state.TextPlacement do
		local position = if visible then v.WithIcon else v.Alone
		k.Position = position
		local size = if visible then v.WithIconSize else v.AloneSize
		k.Size = size
	end
end

local function hiddenPosition(state)
	local card = state.Card
	local restPosition = state.RestPosition
	local layerCollector = card:FindFirstAncestorWhichIsA("LayerCollector")
	local v = not (layerCollector and layerCollector:IsA("ScreenGui")) and 0 or layerCollector.AbsoluteSize.Y
	local v2 = not (v > 0) and 0.25 or card.AbsoluteSize.Y / v

	return UDim2.new(restPosition.X.Scale, restPosition.X.Offset, 1 + v2 * card.AnchorPoint.Y + 0.02, 0)
end

local function slide(state, position: UDim2, tweenInfo)
	if state.Tween then
		state.Tween:Cancel()
	end

	local tween = TweenService:Create(state.Card, tweenInfo, { Position = position })
	state.Tween = tween
	tween:Play()

	return tween
end

local PoolFoulPopup = {}

function PoolFoulPopup.new(guiObject)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return nil
	end

	local header = guiObject:FindFirstChild("Header")
	local body = guiObject:FindFirstChild("Body")

	if not (header and header:IsA("TextLabel") and body and body:IsA("TextLabel")) then
		warn("[PoolFoulPopup] " .. guiObject:GetFullName() .. " needs Header and Body TextLabels")

		return nil
	end

	guiObject.Visible = false

	local icon = guiObject:FindFirstChild("Icon")

	if not (icon and icon:IsA("ImageLabel")) then
		icon = nil
	end

	local textPlacement = {}

	for _, v in { header, body } do
		local position = v.Position
		local size = v.Size
		local v2 = math.max(1 - (position.X.Scale + size.X.Scale * (1 - v.AnchorPoint.X)), 0.04)
		local v3 = 1 - v2 * 2

		textPlacement[v] = {
			WithIcon = position,
			WithIconSize = size,
			Alone = UDim2.new(v2 + v3 * v.AnchorPoint.X, 0, position.Y.Scale, position.Y.Offset),
			AloneSize = UDim2.new(v3, 0, size.Y.Scale, size.Y.Offset)
		}
	end

	return {
		Card = guiObject,
		Header = header,
		Body = body,
		Icon = icon,
		TextPlacement = textPlacement,
		RestPosition = guiObject.Position,
		Token = 0,
		Tween = nil
	}
end

function PoolFoulPopup:Show(data)
	local foulPopup = PoolConstants.FoulPopup

	self.Token += 1

	local token = self.Token
	local card = self.Card

	self.Header.Text = data.Header
	self.Body.Text = data.Body
	applyIcon(self, iconFor(data.Icon))

	card.Visible = true
	card.Position = hiddenPosition(self)

	slide(self, self.RestPosition, TweenInfo.new(foulPopup.InSeconds, Enum.EasingStyle.Back, Enum.EasingDirection.Out))

	task.delay(foulPopup.InSeconds + foulPopup.HoldSeconds, function()
		if self.Token ~= token then
			return
		end

		slide(
			self,
			hiddenPosition(self),
			TweenInfo.new(foulPopup.OutSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		).Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed and self.Token == token then
				card.Visible = false
			end
		end)
	end)
end

function PoolFoulPopup:Hide()
	self.Token += 1

	if self.Tween then
		self.Tween:Cancel()
		self.Tween = nil
	end

	self.Card.Visible = false
	self.Card.Position = self.RestPosition
end

function PoolFoulPopup.ForFoul(p: string?, p2: string?)
	if not p or p == "" then
		return nil
	end

	local foulPopup = PoolConstants.FoulPopup
	local v

	if p2 == "NineBall" then
		v = foulPopup.NineBall[p]
	end

	return v or foulPopup.Fouls[p]
end

function PoolFoulPopup.ForLoss(p: string?)
	local lossKind = PoolRules.LossKind(p)

	if lossKind then
		return PoolConstants.FoulPopup.Losses[lossKind]
	end

	return nil
end

return PoolFoulPopup