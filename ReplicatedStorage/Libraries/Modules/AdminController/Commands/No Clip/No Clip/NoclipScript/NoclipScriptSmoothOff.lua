return function()
	local value = script.Parent.Parent.Speed.Value

	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local ContextActionService = game:GetService("ContextActionService")

	local localPlayer = game.Players.LocalPlayer
	local playerScripts = localPlayer:WaitForChild("PlayerScripts")
	local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local controls = PlayerModule:GetControls()

	local v = false
	local v2

	if type(value) then
		v2 = value or 50
	else
		v2 = 50
	end

	local heartbeatConnection = nil

	local function OnPress(p, p2, _)
		if not UserInputService:GetFocusedTextBox() and v then
			if p == "NoclipSpeedUp" then
				if p2 == Enum.UserInputState.Begin then
					v2 += 10
				end
			elseif p == "NoclipSpeedDown" then
				if p2 == Enum.UserInputState.Begin then
					v2 = math.max(v2 - 10, 10)
				end
			elseif p == "NoclipSpeedReset" and p2 == Enum.UserInputState.Begin then
				v2 = value
			end
		end
	end

	script.Parent.Parent.ToolTip = "Move around like you are playing normally."

	if Enum.KeyCode.Space then
		script.Parent.Parent.ToolTip = script.Parent.Parent.ToolTip .. " Press Space to move upwards."
	end

	if Enum.KeyCode.LeftControl then
		script.Parent.Parent.ToolTip = script.Parent.Parent.ToolTip .. " Press Space to move downwards."
	end

	if Enum.KeyCode.E then
		ContextActionService:BindAction("NoclipSpeedUp", OnPress, false, Enum.KeyCode.E)
		script.Parent.Parent.ToolTip = script.Parent.Parent.ToolTip .. " Press E to speed up."
	end

	if Enum.KeyCode.Q then
		ContextActionService:BindAction("NoclipSpeedDown", OnPress, false, Enum.KeyCode.Q)
		script.Parent.Parent.ToolTip = script.Parent.Parent.ToolTip .. " Press Q to slow down."
	end

	if Enum.KeyCode.R then
		ContextActionService:BindAction("NoclipSpeedReset", OnPress, false, Enum.KeyCode.R)
		script.Parent.Parent.ToolTip = script.Parent.Parent.ToolTip .. " Press R to reset speed."
	end

	script.Parent.Parent.Equipped:Connect(function()
		v = true
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local character = localPlayer.Character

			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local currentCamera = workspace.CurrentCamera

				if humanoid then
					humanoid.PlatformStand = true
				end

				if humanoidRootPart then
					humanoidRootPart.Anchored = true
					humanoidRootPart.Velocity = Vector3.new()

					if currentCamera then
						local v3 = controls:GetMoveVector() or Vector3.new()

						if not UserInputService:GetFocusedTextBox() then
							if Enum.KeyCode.Space and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
								v3 = Vector3.new(v3.X, 1, v3.Z)
							end

							if Enum.KeyCode.LeftControl and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
								v3 = Vector3.new(v3.X, v3.Y - 1, v3.Z)
							end
						end

						v3 = v3.Magnitude > 1 and v3.Unit or v3
						local v4 = v3 * dt * v2

						humanoidRootPart.CFrame = CFrame.new(
							humanoidRootPart.Position,
							humanoidRootPart.Position + currentCamera.CFrame.LookVector
						) * CFrame.new(v4)
					end
				end
			end
		end)
	end)

	script.Parent.Parent.Unequipped:Connect(function()
		v = false
		local character = localPlayer.Character

		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoid then
				humanoid.PlatformStand = false
			end

			if humanoidRootPart then
				humanoidRootPart.Anchored = false
			end
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end