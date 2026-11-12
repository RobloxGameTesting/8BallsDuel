local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolConstants = require(Pool.PoolConstants)
local PoolTableRenderer3D = require(Pool.PoolTableRenderer3D)
local PoolVip = require(Pool.PoolVip)

local PoolChallengeModePopup = {}

local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local cframe = CFrame.Angles(0, 3.141592653589793, 0)

local v = {
	{ Button = "EightBall", Ball = 8, GameType = "EightBall" },
	{ Button = "NineBall", Ball = PoolConstants.NineBall.BallNumber, GameType = "NineBall" }
}

local function expect(instance, button: string) -- 5 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(button)

	if not child then
		error(
			string.format(
				"[PoolChallengeModePopup] %s has no child named %q -- check ReplicatedStorage.UI.PoolMenuUI.ChallengeModePopup",
				instance:GetFullName(),
				button
			),
			0
		)
	end

	return child
end

local function fillBall(parent, p: number)
	parent:ClearAllChildren()

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = parent

	local createLooseBall = PoolTableRenderer3D.CreateLooseBall(parent, p, "Ball")
	createLooseBall.CFrame = cframe

	local camera = Instance.new("Camera")
	camera.FieldOfView = 30

	local v2 = PoolConstants.BallDiameter / 2 * 1.12 / 0.2679491924311227

	camera.CFrame = CFrame.new(Vector3.new(0, 0, v2), Vector3.new(0, 0, 0))
	camera.Parent = parent
	parent.CurrentCamera = camera
end

function PoolChallengeModePopup.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")

	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)
	local root = expect(instance, "ChallengeModePopup") -- inferred equivalent call
	local card = expect(root, "Card") -- inferred equivalent call
	local title = expect(card, "Title") -- inferred equivalent call
	local close = expect(card, "Close") -- inferred equivalent call
	root.Visible = false

	pcall(PoolButtonSkin.ApplyExit, close)

	for _, v2 in v do
		local child = expect(card, v2.Button) -- inferred equivalent call
		local ball = child:FindFirstChild("Ball")

		pcall(PoolButtonSkin.Apply, child)

		if ball and ball:IsA("ViewportFrame") then
			local success, result = pcall(fillBall, ball, v2.Ball)

			if not success then
				warn("[PoolChallengeModePopup] could not draw the", v2.Ball, "ball:", result)
			end
		end

		local gameType = v2.GameType

		maid:GiveTask(child.Activated:Connect(function()
			bindableEvent:Fire(gameType)
		end))
	end

	maid:GiveTask(close.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	return {
		Root = root,
		Card = card,
		Title = title,
		Close = close,
		RestSize = card.Size,
		Picked = bindableEvent.Event,
		Closed = bindableEvent2.Event,
		Maid = maid
	}
end

function PoolChallengeModePopup.Show(data, value: string?, flag: boolean?)
	data.Title.RichText = true
	data.Title.Text = (not value or value == "") and "CHALLENGE A FRIEND"
		or "CHALLENGE " .. PoolVip.Format(string.upper(value), flag)

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

function PoolChallengeModePopup.Hide(p)
	p.Root.Visible = false
end

function PoolChallengeModePopup.IsVisible(p)
	return p.Root.Visible
end

function PoolChallengeModePopup.Destroy(p)
	PoolChallengeModePopup.Hide(p)
	p.Maid:DoCleaning()
end

return PoolChallengeModePopup