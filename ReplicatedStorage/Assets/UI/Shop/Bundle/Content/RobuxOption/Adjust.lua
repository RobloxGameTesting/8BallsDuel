game:GetService("RunService")

local parent = script.Parent
local robuxIcon = parent.RobuxIcon
local robux = parent.Robux

local function update()
	robuxIcon.Position = UDim2.new(
		robux.Position.X.Scale,
		-robux.TextBounds.X - 3,
		robux.Position.Y.Scale + robux.Size.Y.Scale / 2.2,
		0
	)
	robuxIcon.Size = UDim2.new(1, 0, 0, robux.TextBounds.Y)
end

update()
robux:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
robux:GetPropertyChangedSignal("TextBounds"):Connect(update)