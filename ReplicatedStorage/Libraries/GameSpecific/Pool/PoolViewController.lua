local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolGeometry = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGeometry)
local PoolTableRenderer2D = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTableRenderer2D)
local PoolTableRenderer3D = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTableRenderer3D)
local PoolRack3D = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolRack3D)

local PoolViewController = {}
PoolViewController.MinZoom = 1
PoolViewController.MaxZoom = 3

local function matchCameraToRect(state)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local root = state.Renderer2D.Root
	local absoluteSize = root.AbsoluteSize
	local viewportSize = currentCamera.ViewportSize

	if absoluteSize.Y <= 0 or viewportSize.Y <= 0 then
		return
	end

	local v = math.tan(math.rad(currentCamera.FieldOfView) / 2)

	if v <= 0 then
		return
	end

	local v2 = PoolTableRenderer2D.GetFrameSize().Y * viewportSize.Y / (2 * absoluteSize.Y * v)
	local v3 = 2 * v2 * v / viewportSize.Y

	local v4 = root.AbsolutePosition + GuiService:GetGuiInset() + absoluteSize / 2 - viewportSize / 2

	local v5 = state.Renderer3D.Centre + Vector3.new(0, v2, 0) - Vector3.new(1, 0, 0) * (v4.X * v3) + Vector3.new(0, 0, -1) * (v4.Y * v3)

	currentCamera.CFrame = CFrame.lookAt(v5, v5 + Vector3.new(0, -1, 0), Vector3.new(0, 0, -1))
end

local function applyFraming(state)
	local root = state.Renderer2D.Root
	local parent = root.Parent

	local cameraZoom = math.clamp(state.CameraZoom, PoolViewController.MinZoom, PoolViewController.GetMaxZoom(state))
	local cameraPan = state.CameraPan

	if parent and parent:IsA("GuiObject") then
		local v = (root.AbsoluteSize - parent.AbsoluteSize) / 2
		local v2 = math.max(v.X, 0)
		local v3 = math.max(v.Y, 0)

		cameraPan = Vector2.new(math.clamp(cameraPan.X, -v2, v2), (math.clamp(cameraPan.Y, -v3, v3)))
	end

	state.CameraZoom = cameraZoom
	state.CameraPan = cameraPan

	root.Size = UDim2.fromScale(cameraZoom, cameraZoom)
	root.Position = UDim2.new(0.5, cameraPan.X, 0.5, cameraPan.Y)
end

function PoolViewController:PanCamera(vector2: Vector2)
	self.CameraPan += vector2
	applyFraming(self)
end

function PoolViewController:ZoomCamera(p: number)
	self.CameraZoom += p
	applyFraming(self)
end

function PoolViewController.GetFitZoom(p)
	local parent = p.Renderer2D.Root.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return 1
	end

	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return 1
	end

	local frameSize = PoolTableRenderer2D.GetFrameSize()
	return (math.max(
		math.min(absoluteSize.X / PoolConstants.FrameWidth, absoluteSize.Y / PoolConstants.FrameHeight) / math.min(
			absoluteSize.X / frameSize.X,
			absoluteSize.Y / frameSize.Y
		),
		1
	))
end

function PoolViewController.GetMaxZoom(p)
	return (math.clamp(PoolViewController.GetFitZoom(p) * 2, PoolViewController.MaxZoom, 8))
end

function PoolViewController:SetCameraZoom(value: number, vector2: Vector2?)
	local parent = self.Renderer2D.Root.Parent
	local cameraZoom = self.CameraZoom
	local cameraZoom2 = math.clamp(value, PoolViewController.MinZoom, (PoolViewController.GetMaxZoom(self)))

	if vector2 and parent and parent:IsA("GuiObject") and cameraZoom > 0 then
		local v = vector2 - (parent.AbsolutePosition + parent.AbsoluteSize / 2 + self.CameraPan)
		local v2 = cameraZoom2 / cameraZoom

		self.CameraPan -= v * (v2 - 1)
	end

	self.CameraZoom = cameraZoom2
	applyFraming(self)
end

function PoolViewController.GetZoom(p)
	return p.CameraZoom
end

function PoolViewController:ResetCamera()
	self.CameraPan = Vector2.zero
	self.CameraZoom = PoolViewController.MinZoom
	applyFraming(self)
end

function PoolViewController.new(instance, p: string?)
	local maid = Maid.new()

	local renderer2D = PoolTableRenderer2D.new(instance, p)
	local renderer3D = PoolTableRenderer3D.new(p)

	local rackAnchor = instance:FindFirstChild("RackAnchor")
	local new = PoolRack3D.new
	local root = renderer3D.Root

	if not (rackAnchor and rackAnchor:IsA("GuiObject")) then
		rackAnchor = nil
	end

	local rack = new(root, rackAnchor, renderer2D.Root)

	maid:GiveTask(function()
		PoolRack3D.Destroy(rack)
		PoolTableRenderer2D.Destroy(renderer2D)
		PoolTableRenderer3D.Destroy(renderer3D)
	end)

	local v = {
		Mode = "2D",
		Renderer2D = renderer2D,
		Renderer3D = renderer3D,
		Rack = rack,
		CameraMaid = Maid.new(),
		Maid = maid,
		RestoreCameraType = nil,
		CameraPan = Vector2.zero,
		CameraZoom = PoolViewController.MinZoom,
		RestoreFieldOfViewMode = nil,
		RestoreFieldOfView = nil
	}

	maid:GiveTask(function()
		v.CameraMaid:DoCleaning()
	end)

	PoolTableRenderer3D.SetVisible(renderer3D, false)

	return v
end

function PoolViewController.SetTableSkin(p, p2: string?)
	return PoolTableRenderer3D.SetTableSkin(p.Renderer3D, p2)
end

function PoolViewController.SetTheme(p, p2)
	PoolTableRenderer2D.SetTheme(p.Renderer2D, p2)
	PoolTableRenderer3D.SetTheme(p.Renderer3D, p2)
end

function PoolViewController.SetTable(data, p)
	PoolTableRenderer2D.SetTable(data.Renderer2D, p)
	PoolTableRenderer3D.SetTable(data.Renderer3D, p)

	if p and p ~= PoolGeometry.Default then
		PoolRack3D.SetVisible(data.Rack, false)
	end

	applyFraming(data)
end

local function sweepBallHolder(instance)
	if not instance then
		return
	end

	for _, child in instance:GetChildren() do
		if not (child.Name:match("^Ball%d+$") or child.Name:match("^Shadow%d+$")) then
			continue
		end

		child:Destroy()
	end
end

function PoolViewController.SetModifiers(p, p2, p3)
	PoolTableRenderer2D.SetModifiers(p.Renderer2D, p2, p3)
	PoolTableRenderer3D.SetModifiers(p.Renderer3D, p2, p3)
end

function PoolViewController.PopBubble(p, p2: number)
	PoolTableRenderer2D.PopBubble(p.Renderer2D, p2)
	PoolTableRenderer3D.PopBubble(p.Renderer3D, p2)
end

function PoolViewController.ClearBalls(p)
	PoolTableRenderer2D.ClearBalls(p.Renderer2D)
	PoolTableRenderer3D.ClearBalls(p.Renderer3D)

	sweepBallHolder(p.Renderer2D.BallHolder)
	sweepBallHolder(p.Renderer3D.BallHolder)
	sweepBallHolder(p.Renderer3D.ShadowHolder)
end

function PoolViewController.RemoveBall(p, p2: number)
	PoolTableRenderer2D.RemoveBall(p.Renderer2D, p2)
	PoolTableRenderer3D.RemoveBall(p.Renderer3D, p2)
end

function PoolViewController.SetBallSkin(p, p2: number, p3: number?)
	PoolTableRenderer2D.SetBallSkin(p.Renderer2D, p2, p3)
	PoolTableRenderer3D.SetBallSkin(p.Renderer3D, p2, p3)
end

function PoolViewController.SetBallScale(p, p2: number, p3: number)
	PoolTableRenderer2D.SetBallScale(p.Renderer2D, p2, p3)
	PoolTableRenderer3D.SetBallScale(p.Renderer3D, p2, p3)
end

function PoolViewController.SetBall(p, p2: number, vector2: Vector2)
	PoolTableRenderer2D.SetBall(p.Renderer2D, p2, vector2)
	PoolTableRenderer3D.SetBall(p.Renderer3D, p2, vector2)
end

function PoolViewController.PocketBall(p, p2: number, p3, vector2: Vector2?, p4: number?)
	PoolTableRenderer2D.SetBallVisible(p.Renderer2D, p2, false)
	PoolTableRenderer3D.DropBall(p.Renderer3D, p2, p3, vector2, p4)
end

function PoolViewController.SetBallHeight(p, p2: number, p3: number)
	PoolTableRenderer2D.SetBallHeight(p.Renderer2D, p2, p3)
	PoolTableRenderer3D.SetBallHeight(p.Renderer3D, p2, p3)
end

function PoolViewController.BurnBall(p, p2: number)
	PoolTableRenderer2D.BurnBall(p.Renderer2D, p2)
	PoolTableRenderer3D.BurnBall(p.Renderer3D, p2)
end

function PoolViewController.SetBallVisible(p, p2: number, flag: boolean)
	PoolTableRenderer2D.SetBallVisible(p.Renderer2D, p2, flag)
	PoolTableRenderer3D.SetBallVisible(p.Renderer3D, p2, flag)
end

function PoolViewController.IsDropping(p, p2: number): boolean
	return PoolTableRenderer3D.DropRemaining(p.Renderer3D, p2) > 0
end

function PoolViewController.ReturnBall(p, p2: number, vector2: Vector2)
	local function show() -- 1 equivalent call inferred from this helper
		PoolViewController.SetBallVisible(p, p2, true)
		PoolViewController.SetBall(p, p2, vector2)
	end

	local v = PoolTableRenderer3D.DropRemaining(p.Renderer3D, p2)

	if v <= 0 then
		show() -- inferred equivalent call
	else
		task.delay(v, show)
	end
end

function PoolViewController.SetCueStick(p, vector2: Vector2, vector2_2: Vector2, p2: number)
	PoolTableRenderer3D.SetCueStick(p.Renderer3D, vector2, vector2_2, p2)
end

function PoolViewController.SetCueStickVisible(p, flag: boolean)
	PoolTableRenderer3D.SetCueStickVisible(p.Renderer3D, flag and p.Mode == "3D")
end

function PoolViewController.SetCueStickModel(p, p2: string?)
	PoolTableRenderer3D.SetCueStickModel(p.Renderer3D, p2)
end

function PoolViewController.RenderRack(p, p2)
	local v = p2 or PoolGeometry.BuildRack()

	local set = { [PoolConstants.CueBallNumber] = true }

	for _, v2 in v do
		set[v2.Number] = true
	end

	local v2 = {}

	for k in p.Renderer2D.Balls do
		if not set[k] then
			table.insert(v2, k)
		end
	end

	for k in p.Renderer3D.Balls do
		if not (set[k] or table.find(v2, k)) then
			table.insert(v2, k)
		end
	end

	for _, v3 in v2 do
		PoolViewController.RemoveBall(p, v3)
	end

	local function sweepHolder(instance)
		if not instance then
			return
		end

		for _, child in instance:GetChildren() do
			local v3 = tonumber(child.Name:match("^Ball(%d+)$") or child.Name:match("^Shadow(%d+)$"))

			if not v3 or set[v3] then
				continue
			end

			child:Destroy()
		end
	end

	sweepHolder(p.Renderer2D.BallHolder)
	sweepHolder(p.Renderer3D.BallHolder)
	sweepHolder(p.Renderer3D.ShadowHolder)

	for _, v3 in v do
		PoolViewController.SetBall(p, v3.Number, v3.DisplayPosition or v3.Position)
	end

	PoolViewController.SetBall(p, PoolConstants.CueBallNumber, PoolGeometry.BreakSpot)
end

function PoolViewController.RackBall(p, p2: number)
	PoolRack3D.Add(p.Rack, p2)
end

function PoolViewController.UnrackBall(p, p2: number)
	PoolRack3D.Remove(p.Rack, p2)
end

function PoolViewController.SetRackVisible(p, flag: boolean)
	PoolRack3D.SetVisible(p.Rack, flag)
end

function PoolViewController.ClearRack(p)
	PoolRack3D.Clear(p.Rack)
end

function PoolViewController.UpdateRack(p, p2: number)
	PoolRack3D.Update(p.Rack, p2)
end

function PoolViewController.GetBallPart(p, p2: number)
	return p.Renderer3D.Balls[p2]
end

function PoolViewController.ToWorld(vector2: Vector2, p: number)
	return PoolTableRenderer3D.ToWorld(vector2, p)
end

function PoolViewController:SetMode(mode: string)
	if self.Mode == mode then
		return
	end

	self.Mode = mode
	self.CameraMaid:DoCleaning()

	local currentCamera = workspace.CurrentCamera

	if mode == "3D" then
		PoolTableRenderer3D.SetVisible(self.Renderer3D, true)

		self.Renderer2D.Root.BackgroundTransparency = 1

		for _, guiObject in self.Renderer2D.Root:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "Overlay" and guiObject.Name ~= "CollisionOverlay" then
				guiObject.Visible = false
			end
		end

		if currentCamera then
			self.RestoreCameraType = currentCamera.CameraType
			self.RestoreFieldOfViewMode = currentCamera.FieldOfViewMode
			self.RestoreFieldOfView = currentCamera.FieldOfView

			currentCamera.FieldOfView = math.clamp(PoolConstants.View3D.FieldOfView, 1, 120)

			currentCamera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end

		matchCameraToRect(self)

		self.CameraMaid:GiveTask(RunService.RenderStepped:Connect(function()
			matchCameraToRect(self)
		end))
	else
		PoolTableRenderer3D.SetVisible(self.Renderer3D, false)
		PoolTableRenderer3D.SetCueStickVisible(self.Renderer3D, false)

		self.Renderer2D.Root.BackgroundTransparency = 0

		for _, guiObject in self.Renderer2D.Root:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "CollisionOverlay" then
				guiObject.Visible = true
			end
		end

		if currentCamera then
			currentCamera.CameraType = self.RestoreCameraType or Enum.CameraType.Custom
			currentCamera.FieldOfViewMode = self.RestoreFieldOfViewMode or Enum.FieldOfViewMode.Vertical
			currentCamera.FieldOfView = self.RestoreFieldOfView or 70
		end
	end

	PoolTableRenderer2D.SetCollisionOverlayVisible(self.Renderer2D, PoolConstants.ShowCollisionOverlay == true)
end

function PoolViewController.Toggle(p)
	PoolViewController.SetMode(p, p.Mode == "2D" and "3D" or "2D")

	return p.Mode
end

function PoolViewController.Destroy(p)
	PoolViewController.SetMode(p, "3D")
	p.Maid:DoCleaning()
end

return PoolViewController