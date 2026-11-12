local Players = game:GetService("Players")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ViewportSize = workspace.CurrentCamera.ViewportSize
Maid.new()

local function getThickness(label) -- 2 equivalent calls inferred from this helper
	return label:GetAttribute("Thickness") or 1.5
end

local function shadow(label)
	if not (label:IsA("TextLabel") and label.Name ~= "Shadow") then
		return
	end

	local uiStroke = label:FindFirstChildWhichIsA("UIStroke")
	local thickness = getThickness(label) -- inferred equivalent call

	if not (uiStroke and thickness ~= 0) then
		return
	end

	local v = Maid.new()

	uiStroke.Thickness = thickness

	local shadow2 = label:FindFirstChild("Shadow")

	if shadow2 then
		shadow2:Destroy()
	end

	local shadow3 = label:Clone()
	local uiStroke2 = shadow3:FindFirstChildWhichIsA("UIStroke")
	shadow3.Name = "Shadow"
	shadow3.Size = UDim2.new(1, 0, 1, 0)
	shadow3.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow3.TextColor3 = uiStroke.Color
	shadow3.Position = UDim2.new(0.5, 0, 0.5, thickness)
	uiStroke2.Thickness = thickness
	shadow3.ZIndex -= 10
	shadow3.Visible = true
	shadow3.Rotation = 0
	shadow3.Parent = label

	v.alignConnection = label.Changed:Connect(function(p)
		if p == "TextXAlignment" then
			shadow3.TextXAlignment = label.TextXAlignment
		elseif p == "TextYAlignment" then
			shadow3.TextYAlignment = label.TextYAlignment
		end
	end)

	v.textChangedConnection = label:GetPropertyChangedSignal("Text"):Connect(function()
		shadow3.Text = label.Text
	end)
	v.textBoundsConnection = label:GetPropertyChangedSignal("TextBounds"):Connect(function()
		local thickness2 = getThickness(label) -- inferred equivalent call
		uiStroke.Thickness = thickness2
		shadow3.Position = UDim2.new(0.5, 0, 0.5, thickness2)
		uiStroke2.Thickness = thickness2
	end)

	v.cloneDestroyConnection = shadow3.Destroying:Connect(function()
		v:Destroy()
	end)
	v.objDestroyConnection = label.Destroying:Connect(function()
		v:Destroy()
	end)
end

PlayerGui.DescendantAdded:Connect(shadow)

for _, descendant in PlayerGui:GetDescendants(), nil, nil do
	shadow(descendant)
end