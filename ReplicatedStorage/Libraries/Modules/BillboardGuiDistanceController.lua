local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local BillboardGuiDistanceController = {}
BillboardGuiDistanceController._tracked = {}
BillboardGuiDistanceController._guList = {}
BillboardGuiDistanceController._index = 1

function BillboardGuiDistanceController.Register(instance, p: number)
	if BillboardGuiDistanceController._tracked[instance] == nil then
		table.insert(BillboardGuiDistanceController._guList, instance)

		instance.Destroying:Connect(function()
			BillboardGuiDistanceController.Unregister(instance)
		end)
	end

	BillboardGuiDistanceController._tracked[instance] = p
end

function BillboardGuiDistanceController.Unregister(p)
	BillboardGuiDistanceController._tracked[p] = nil

	for i, gu in ipairs(BillboardGuiDistanceController._guList) do
		if gu == p then
			table.remove(BillboardGuiDistanceController._guList, i)
			break
		end
	end
end

local function GetRoot() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character

	if character then
		return (character:FindFirstChild("HumanoidRootPart"))
	end

	return nil
end

local characters = {}
local function BuildRayParams() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	characters = {}

	if character then
		table.insert(characters, character)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	return raycastParams
end

local function getPosition(adornee) -- 1 equivalent call inferred from this helper
	if adornee:IsA("BasePart") then
		return adornee.Position
	end

	if adornee:IsA("Model") then
		return adornee.PrimaryPart.Position
	end

	if adornee:IsA("Attachment") then
		return adornee.WorldPosition
	end

	return nil
end

local function IsVisible(gu, p, p2: number, _): boolean -- 1 equivalent call inferred from this helper
	local position = getPosition(gu.Adornee or gu.Parent) -- inferred equivalent call

	if position then
		return not (p2 < (position - p.Position).Magnitude)
	end

	return false
end

RunService.RenderStepped:Connect(function()
	local root = GetRoot() -- inferred equivalent call

	if not root then
		return
	end

	BuildRayParams() -- inferred equivalent call
	local count = #BillboardGuiDistanceController._guList

	if count == 0 then
		return
	end

	local v = math.max(1, (math.floor(count / 5)))
	local index = BillboardGuiDistanceController._index
	local v2 = math.min(index + v - 1, count)

	for i = index, v2 do
		local gu = BillboardGuiDistanceController._guList[i]
		gu.Enabled = IsVisible(gu, root, BillboardGuiDistanceController._tracked[gu]) -- inferred equivalent call
	end

	BillboardGuiDistanceController._index = v2 + 1

	if count < BillboardGuiDistanceController._index then
		BillboardGuiDistanceController._index = 1
	end
end)

return BillboardGuiDistanceController