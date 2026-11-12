local Players = game:GetService("Players")
game:GetService("CollectionService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function getOffset(screenGui) -- 1 equivalent call inferred from this helper
	return screenGui:GetAttribute("Offset") or 5
end

local function shadow(screenGui)
	if not screenGui:IsA("ScreenGui") or screenGui:FindFirstChild("Shadow") then
		return
	end

	local background = screenGui:FindFirstChild("Background")

	if not (background and background:IsA("GuiObject")) then
		return
	end

	local offset = getOffset(screenGui) -- inferred equivalent call
	local shadow2 = background:Clone()
	shadow2.BackgroundTransparency = 0
	shadow2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

	if shadow2:IsA("ImageLabel") then
		shadow2.Image = ""
	end

	shadow2.Name = "Shadow"

	for _, child in shadow2:GetChildren(), nil, nil do
		if child:IsA("UIStroke") or child:IsA("UIAspectRatioConstraint") or child:IsA("UICorner") then
			continue
		end

		child:Destroy()
	end

	shadow2.ZIndex = background.ZIndex - 1000
	shadow2.Position += UDim2.fromOffset(0, offset)
	shadow2.Parent = screenGui
end

PlayerGui.DescendantAdded:Connect(shadow)

for _, descendant in PlayerGui:GetDescendants(), nil, nil do
	shadow(descendant)
end