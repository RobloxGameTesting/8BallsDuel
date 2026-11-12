local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local PoolTutorialPopup = {}

local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function expect(instance, childName: string) -- 5 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName)

	if not child then
		error(
			string.format(
				"[PoolTutorialPopup] %s has no child named %q -- check ReplicatedStorage.UI.PoolTutorialUI",
				instance:GetFullName(),
				childName
			),
			0
		)
	end

	return child
end

local function setButtonText(instance, text: string) -- 2 equivalent calls inferred from this helper
	local top = instance:FindFirstChild("Top")

	if top and top:IsA("TextLabel") then
		top.Text = text
	else
		instance.Text = text
	end
end

function PoolTutorialPopup.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	maid.event = bindableEvent

	local bindableEvent2 = Instance.new("BindableEvent")
	maid.declineEvent = bindableEvent2
	local root = expect(instance, "TutorialPopup") -- inferred equivalent call
	local card = expect(root, "Card") -- inferred equivalent call
	local v = {
		Root = root,
		Card = card,
		Title = expect(card, "Title"), -- inferred equivalent call
		Body = expect(card, "Body"), -- inferred equivalent call
		Button = expect(card, "Confirm"), -- inferred equivalent call
		DeclineButton = nil,
		RestSize = card.Size,
		Confirmed = bindableEvent.Event,
		Event = bindableEvent,
		Declined = bindableEvent2.Event,
		DeclineEvent = bindableEvent2,
		Maid = maid
	}

	root.Visible = false

	maid.confirm = v.Button.Activated:Connect(function()
		bindableEvent:Fire()
	end)

	return v
end

function PoolTutorialPopup.Ask(p, p2)
	PoolTutorialPopup.Show(p, p2)
	p.Confirmed:Wait()
	PoolTutorialPopup.Hide(p)
end

local udim = UDim2.fromScale(0.5, 0.88)

local function applyDecline(state, decline: string?)
	if decline then
		if not state.DeclineButton then
			local decline2 = state.Button:Clone()
			decline2.Name = "Decline"
			decline2.Parent = state.Card

			state.DeclineButton = decline2

			state.Maid.decline = decline2.Activated:Connect(function()
				state.DeclineEvent:Fire()
			end)
		end

		local declineButton = state.DeclineButton
		setButtonText(declineButton, decline) -- inferred equivalent call
		declineButton.Visible = true
		declineButton.Size = UDim2.fromScale(0.44, 0.2)
		declineButton.Position = UDim2.fromScale(0.26, 0.88)

		state.Button.Size = UDim2.fromScale(0.44, 0.2)
		state.Button.Position = UDim2.fromScale(0.74, 0.88)
	else
		if state.DeclineButton then
			state.DeclineButton.Visible = false
		end

		state.Button.Position = udim
		state.Button.Size = UDim2.fromScale(0.5, 0.2)
	end
end

function PoolTutorialPopup.Show(data, data2)
	data.Title.Text = data2.Title
	data.Body.Text = data2.Body
	setButtonText(data.Button, data2.Confirm or "CONFIRM") -- inferred equivalent call

	applyDecline(data, data2.Decline)

	local restSize = data.RestSize

	data.Root.Visible = true
	data.Root.BackgroundTransparency = 1
	data.Card.Size = UDim2.new(
		restSize.X.Scale * 0.88,
		math.round(restSize.X.Offset * 0.88),
		restSize.Y.Scale * 0.88,
		(math.round(restSize.Y.Offset * 0.88))
	)

	TweenService:Create(data.Root, tweenInfo, { BackgroundTransparency = 0.45 }):Play()
	TweenService:Create(data.Card, tweenInfo, { Size = restSize }):Play()
end

function PoolTutorialPopup.Hide(p)
	p.Root.Visible = false
end

function PoolTutorialPopup.IsVisible(p)
	return p.Root.Visible
end

function PoolTutorialPopup:Destroy()
	PoolTutorialPopup.Hide(self)
	self.Maid:Destroy()
end

return PoolTutorialPopup