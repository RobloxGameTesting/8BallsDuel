local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local vector2 = Vector2.new(479, 326)

local vector2_2 = Vector2.new(57, 319)

local v = false

local function makePiece(body, name: string, p: number, p2: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = body.Image
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.ImageRectOffset = Vector2.new(p2, 0)
	imageLabel.ImageRectSize = Vector2.new(-(p2 - p), vector2.Y)
	imageLabel.ZIndex = body.ZIndex
	imageLabel.Parent = body

	return imageLabel
end

local function scaleOf(p) -- 2 equivalent calls inferred from this helper
	return p.Root.AbsoluteSize.Y / 256
end

local function layout(data)
	local absoluteSize = data.Root.AbsoluteSize

	if absoluteSize.Y <= 0 then
		return
	end

	local v2 = scaleOf(data) -- inferred equivalent call
	local v3 = math.round(v2 * -6)
	local v4 = math.round(vector2.Y * v2)

	local v5 = math.round(v2 * -6)
	local v6 = math.round(absoluteSize.X + v2 * 6)
	local v7 = not data.Flipped and 170 or vector2.X - 360
	local v8 = data.Flipped and 170 or vector2.X - 360
	local v9 = math.round(v2 * -6 + v7 * v2)

	local v10 = {
		v5,
		v9,
		math.max(math.round(absoluteSize.X + v2 * 6 - v8 * v2), v9),
		v6
	}

	for k, piece in data.Pieces do
		piece.Position = UDim2.fromOffset(v10[k], v3)
		piece.Size = UDim2.fromOffset(v10[k + 1] - v10[k], v4)
	end
end

local function setFlipped(state, flipped: boolean)
	if state.Flipped == flipped then
		return
	end

	state.Flipped = flipped
	local v2

	if flipped then
		v2 = {
			{ 360, vector2.X },
			{ 170, 360 },
			{ 0, 170 }
		}
	else
		v2 = {
			{ 0, 170 },
			{ 170, 360 },
			{ 360, vector2.X }
		}
	end

	for k, piece in state.Pieces do
		local v3 = v2[k][1]
		local v4 = v2[k][2]

		if flipped then
			piece.ImageRectOffset = Vector2.new(v4, 0)
			piece.ImageRectSize = Vector2.new(-(v4 - v3), vector2.Y)
		else
			piece.ImageRectOffset = Vector2.new(v3, 0)
			piece.ImageRectSize = Vector2.new(v4 - v3, vector2.Y)
		end
	end

	layout(state)
end

local function place(p, vector2_3: Vector2, p2: number)
	local root = p.Root
	local parent = root.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	local v2 = scaleOf(p) -- inferred equivalent call
	local v3 = (vector2_2.X - 6) * v2
	local v4

	if p.Flipped then
		v4 = vector2_3.X + v3
	else
		v4 = vector2_3.X - v3
	end

	local vector2_4 = Vector2.new(v4, vector2_3.Y - (vector2_2.Y - 262) * v2 - p2)

	local absolutePosition = parent.AbsolutePosition

	root.AnchorPoint = Vector2.new(p.Flipped and 1 or 0, 1)
	root.Position = UDim2.fromOffset(
		math.round(vector2_4.X - absolutePosition.X),
		(math.round(vector2_4.Y - absolutePosition.Y))
	)
end

local function shownOnScreen(guiObject): boolean
	while guiObject and guiObject:IsA("GuiObject") do
		if not guiObject.Visible then
			return false
		end

		guiObject = guiObject.Parent
	end

	return true
end

local PoolUpdateBubble = {}

function PoolUpdateBubble.new(instance, callback)
	local updateBubble = instance:FindFirstChild("UpdateBubble")

	if not (updateBubble and updateBubble:IsA("Frame")) then
		return nil
	end

	local body = updateBubble:FindFirstChild("Body")

	if not (body and body:IsA("ImageLabel")) then
		return nil
	end

	if body.Image == "" or v then
		updateBubble.Visible = false

		return nil
	end

	body.ImageTransparency = 1

	local maid = Maid.new()
	local v2 = {
		Root = updateBubble,
		Body = body,
		Pieces = {
			makePiece(body, "BubbleLeft", 360, vector2.X),
			makePiece(body, "BubbleMiddle", 170, 360),
			makePiece(body, "BubbleRight", 0, 170)
		},
		Flipped = true,
		At = nil,
		Key = nil,
		GlideFrom = nil,
		GlideStart = nil,
		Maid = maid
	}

	for _, piece in v2.Pieces do
		maid:GiveTask(piece)
	end

	maid:GiveTask(updateBubble:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		layout(v2)
	end))

	layout(v2)

	local position = updateBubble.Position
	local lastTime = os.clock()

	maid:GiveTask(function()
		updateBubble.Position = position
	end)

	RunService:BindToRenderStep("PoolUpdateBubble", Enum.RenderPriority.Last.Value, function()
		local v3 = instance

		if not shownOnScreen(v3) then
			return
		end

		local v4 = (0.5 - math.cos((os.clock() - lastTime) * 3.141592653589793 * 2 / 1.8) * 0.5) * 4

		if callback then
			local v5, v6 = callback()

			if v5 then
				local now = os.clock()

				if v2.At and v6 ~= v2.Key then
					v2.GlideFrom = v2.At
					v2.GlideStart = now
				end

				v2.Key = v6

				local glideStart = v2.GlideStart
				local glideFrom = v2.GlideFrom
				local at

				if glideStart and glideFrom then
					local v7 = (now - glideStart) / 0.18

					if v7 >= 1 then
						v2.GlideStart = nil
						v2.GlideFrom = nil
						at = v5
					else
						at = glideFrom:Lerp(v5, 1 - (1 - v7) ^ 3)
					end
				else
					at = v5
				end

				setFlipped(v2, v5.X >= v3.AbsolutePosition.X + v3.AbsoluteSize.X / 2)

				v2.At = at
				place(v2, at, v4)
				updateBubble.Visible = true
			else
				updateBubble.Visible = false
				v2.At = nil
				v2.Key = nil
				v2.GlideStart = nil
			end
		else
			updateBubble.Visible = true
			updateBubble.Position = UDim2.new(
				position.X.Scale,
				position.X.Offset,
				position.Y.Scale,
				position.Y.Offset - v4
			)
		end
	end)

	maid:GiveTask(function()
		RunService:UnbindFromRenderStep("PoolUpdateBubble")
	end)

	return v2
end

function PoolUpdateBubble.SetVisible(p, visible: boolean)
	p.Root.Visible = visible
end

function PoolUpdateBubble.Dismiss(p)
	v = true

	if p then
		p.Maid:DoCleaning()
		p.Root.Visible = false
	end
end

function PoolUpdateBubble.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolUpdateBubble