local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BillboardGuiDistanceController = require(ReplicatedStorage.Libraries.Modules.BillboardGuiDistanceController)

local function Register(billboardGui) -- 1 equivalent call inferred from this helper
	if not billboardGui:IsA("BillboardGui") then
		return
	end

	BillboardGuiDistanceController.Register(billboardGui, billboardGui:GetAttribute("MaxDistance") or 20)
end

workspace.DescendantAdded:Connect(Register)

for _, descendant in workspace:GetDescendants(), nil, nil do
	Register(descendant) -- inferred equivalent call
end