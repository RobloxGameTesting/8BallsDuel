local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local HapticService = game:GetService("HapticService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local VoiceChatService = game:GetService("VoiceChatService")
local LocalizationService = game:GetService("LocalizationService")
local parent = script.Parent
local TopbarPlusReference = require(parent.TopbarPlusReference)
local object = TopbarPlusReference.getObject()
local value = object and object.Value

if value and value.IconController ~= script then
	return require(value.IconController)
end

if not object then
	TopbarPlusReference.addToReplicatedStorage()
end

local IconController = {}
local Signal = require(parent.Signal)
local TopbarPlusGui = require(parent.TopbarPlusGui)
local v = {}
local v2 = false
local v3 = nil
local flag = false
local viewportSizeChangedConnection = nil
local inputBeganConnection = nil
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local v4 = false
local v5 = false

local function checkTopbarEnabled()
	local success, result = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_): boolean
		return true
	end)

	return success and result
end

local function checkTopbarEnabledAccountingForMimic()
	local success, result = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_): boolean
		return true
	end)

	return success and result or not IconController.mimicCoreGui
end

local function bindCamera() -- 1 equivalent call inferred from this helper
	if not workspace.CurrentCamera then
		return
	end

	if viewportSizeChangedConnection and viewportSizeChangedConnection.Connected then
		viewportSizeChangedConnection:Disconnect()
	end

	viewportSizeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(IconController.updateTopbar)
end

local v6 = {}
v6.left = {
	startScale = 0,
	getOffset = function()
		local offset = 0 + IconController.leftOffset
		local success, result = xpcall(function()
			return StarterGui:GetCore("TopbarEnabled")
		end, function(_): boolean
			return true
		end)

		if success and result and v4 and not isStudio then
			offset += 0
		end

		return offset
	end,
	getStartOffset = function()
		local leftGap = IconController.leftGap
		return v6.left.getOffset() + leftGap
	end,
	records = {}
}

v6.mid = {
	startScale = 0.5,
	getOffset = function(): number
		return 0
	end,
	getStartOffset = function(p)
		local midGap = IconController.midGap
		return -p / 2 + midGap / 2
	end,
	records = {}
}

v6.right = {
	startScale = 1,
	getOffset = function()
		local rightOffset = IconController.rightOffset
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local v7 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 and true or false
		local success, result = xpcall(function()
			return StarterGui:GetCore("TopbarEnabled")
		end, function(_): boolean
			return true
		end)

		if
			(success and result or VRService.VREnabled)
			and (StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) or StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) or not v7 and StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu))
		then
			rightOffset += 48
		end

		return rightOffset
	end,
	getStartOffset = function(p)
		return -p - v6.right.getOffset()
	end,
	records = {}
}

IconController.topbarEnabled = true
IconController.controllerModeEnabled = false
local success, result = xpcall(function()
	return StarterGui:GetCore("TopbarEnabled")
end, function(_): boolean
	return true
end)

IconController.previousTopbarEnabled = success and result
IconController.leftGap = 12
IconController.midGap = 12
IconController.rightGap = 12
IconController.leftOffset = IconController.leftGap
IconController.rightOffset = -47
IconController.voiceChatEnabled = true
IconController.mimicCoreGui = true
IconController.healthbarDisabled = false
IconController.activeButtonBCallbacks = 0
IconController.disableButtonB = false
IconController.translator = LocalizationService:GetTranslatorForPlayer(LocalPlayer)

IconController.iconAdded = Signal.new()
IconController.iconRemoved = Signal.new()
IconController.controllerModeStarted = Signal.new()
IconController.controllerModeEnded = Signal.new()
IconController.healthbarDisabledSignal = Signal.new()

local count = 0
IconController.iconAdded:Connect(function(object2)
	v[object2] = true

	if IconController.gameTheme then
		object2:setTheme(IconController.gameTheme)
	end

	object2.updated:Connect(function()
		IconController.updateTopbar()
	end)

	object2.selected:Connect(function()
		local icons = IconController.getIcons()

		for _, icon in pairs(icons) do
			if
				object2.deselectWhenOtherIconSelected
				and icon ~= object2
				and icon.deselectWhenOtherIconSelected
				and icon:getToggleState() == "selected"
			then
				icon:deselect(object2)
			end
		end
	end)

	count += 1
	object2:setOrder(count)

	if IconController.controllerModeEnabled then
		IconController._enableControllerModeForIcon(object2, true)
	end

	IconController:_updateSelectionGroup()
	IconController.updateTopbar()
end)

IconController.iconRemoved:Connect(function(object2)
	v[object2] = nil
	object2:setEnabled(false)
	object2:deselect()
	object2.updated:Fire()
	IconController:_updateSelectionGroup()
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)

function IconController.setGameTheme(gameTheme)
	IconController.gameTheme = gameTheme
	local icons = IconController.getIcons()

	for _, icon in pairs(icons) do
		icon:setTheme(gameTheme)
	end
end

function IconController.setDisplayOrder(p)
	TopbarPlusGui.DisplayOrder = tonumber(p) or TopbarPlusGui.DisplayOrder
end
IconController.setDisplayOrder(10)

function IconController.getIcons()
	local icons = {}

	for k, _ in pairs(v) do
		table.insert(icons, k)
	end

	return icons
end

function IconController.getIcon(p)
	for k, _ in pairs(v) do
		if k.name == p then
			return k
		end
	end

	return false
end

function IconController.disableHealthbar(p)
	local healthbarDisabled = p == nil or p
	IconController.healthbarDisabled = healthbarDisabled
	IconController.healthbarDisabledSignal:Fire(healthbarDisabled)
end

function IconController.disableControllerOption(p)
	v5 = p == nil or p

	if IconController.getIcon("_TopbarControllerOption") then
		IconController._determineControllerDisplay()
	end
end

function IconController.canShowIconOnTopbar(data): boolean
	if (data.enabled == true or data.accountForWhenDisabled) and data.presentOnTopbar then
		return true
	end

	return false
end

function IconController.getMenuOffset(object2)
	local v7 = IconController[object2:get("alignment") .. "Gap"]
	local v8 = 0
	local total = 0
	local v9 = 0

	if not object2.menuOpen then
		return v8, total, v9
	end

	local offset = object2:get("menuSize").X.Offset
	local menuDirection = object2:_getMenuDirection()

	if menuDirection == "right" then
		total += offset + v7 / 6
	elseif menuDirection == "left" then
		v8 = offset + 4
		total += v7 / 3
		v9 = offset
	end

	return v8, total, v9
end

local flag2 = false
function IconController.updateTopbar()
	local function getIncrement(record, k)
		local v7 = (record:get("iconSize", record:getIconState()) or UDim2.new(0, 32, 0, 32)).X.Offset + IconController[k .. "Gap"] * 2

		local total = 0

		if record._parentIcon == nil then
			local menuOffset, v8, v9 = IconController.getMenuOffset(record)
			total += menuOffset
			v7 += v8 + v9
		end

		return v7, total
	end

	if flag then
		flag2 = true
		return false
	end

	task.defer(function(): boolean
		flag = true
		RunService.Heartbeat:Wait()
		flag = false

		for _, v7 in pairs(v6) do
			v7.records = {}
		end

		for k, _ in pairs(v) do
			if not IconController.canShowIconOnTopbar(k) then
				continue
			end

			local alignment = k:get("alignment")
			table.insert(v6[alignment].records, k)
		end

		local viewportSize = workspace.CurrentCamera.ViewportSize

		for k, v7 in pairs(v6) do
			local records = v7.records

			if #records > 1 then
				if v7.reverseSort then
					table.sort(records, function(a, b): boolean
						return a:get("order") > b:get("order")
					end)
				else
					table.sort(records, function(a, b): boolean
						return a:get("order") < b:get("order")
					end)
				end
			end

			local total = 0

			for _, record in pairs(records) do
				total += getIncrement(record, k)
			end

			local startOffset = v7.getStartOffset(total, k)

			local x = TopbarPlusGui.TopbarContainer.AbsoluteSize.X
			local v8 = startOffset

			for _, record in pairs(records) do
				local increment, v9 = getIncrement(record, k)
				local _ = v7.startScale * x + v8 + v9
				v8 += increment
			end

			for _, record in pairs(records) do
				local iconContainer = record.instances.iconContainer
				iconContainer.AnchorPoint = Vector2.new(0, 0.5)
				local increment, v9 = getIncrement(record, k)
				local topPadding = record.topPadding
				local udim = UDim2.new(v7.startScale, startOffset + v9, topPadding.Scale, topPadding.Offset)
				string.match(record.name, "_overflowIcon-")
				local repositionInfo = record:get("repositionInfo")

				if repositionInfo then
					TweenService:Create(iconContainer, repositionInfo, { Position = udim }):Play()
				else
					iconContainer.Position = udim
				end

				startOffset += increment
				record.targetPosition = UDim2.new(
					0,
					udim.X.Scale * viewportSize.X + udim.X.Offset,
					0,
					udim.Y.Scale * viewportSize.Y + udim.Y.Offset
				)
			end
		end

		local function getBoundaryX(object2, p, value2)
			local v7 = value2 or 0
			local offset = object2:get("iconSize", object2:getIconState()).X.Offset
			local menuOffset, v8 = IconController.getMenuOffset(object2)
			local v9 = p == "left" and -v7 - menuOffset

			if not v9 then
				if p == "right" then
					v9 = offset + v7 + v8
				else
					v9 = false
				end
			end

			return object2.targetPosition.X.Offset + v9
		end

		local function getSizeX(object2, p)
			local v7, v8 = object2:get("iconSize", object2:getIconState(), "beforeDropdown")
			local v9 = object2:get("iconSize", "hovering")

			if object2.wasHoveringBeforeOverflow and v8 and v9 and v9.X.Offset > v8.X.Offset then
				v8 = v9
			end

			v7 = p and v8 or v7
			local menuOffset, v10 = IconController.getMenuOffset(object2)
			return v7.X.Offset + menuOffset + v10
		end

		for k, v7 in pairs(v6) do
			local overflowIcon = v7.overflowIcon

			if not overflowIcon then
				continue
			end

			local v8 = IconController[k .. "Gap"]
			local v9 = k == "left" and "right" or "left"
			local v10 = v6[v9]
			local icon = IconController.getIcon("_overflowIcon-" .. v9)
			local offset = overflowIcon:get("iconSize", overflowIcon:getIconState()).X.Offset
			local menuOffset, v11 = IconController.getMenuOffset(overflowIcon)
			local v12 = k == "left" and -0 - menuOffset

			if not v12 then
				if k == "right" then
					v12 = offset + 0 + v11
				else
					v12 = false
				end
			end

			local v13 = overflowIcon.targetPosition.X.Offset + v12

			if overflowIcon.enabled then
				v13 = getBoundaryX(overflowIcon, v9, v8)
			end

			local function doesExceed(p): boolean -- 2 equivalent calls inferred from this helper
				if k == "left" and p < v13 then
					return true
				elseif k == "right" then
					return v13 < p
				else
					return false
				end
			end

			local offset2 = v10.getOffset()

			if not overflowIcon.enabled then
				offset2 += 10
			end

			local v14 = k == "left" and viewportSize.X - offset2

			if not v14 then
				v14 = k == "right" and offset2
			end

			local v15 = v14
			local v16 = doesExceed(v15) -- inferred equivalent call

			local function checkBoundaryExceeded(records)
				local count2 = #records

				for i = 1, count2 do
					local item = records[count2 + 1 - i]

					if not IconController.canShowIconOnTopbar(item) then
						continue
					end

					local v17 = string.match(item.name, "_overflowIcon-")

					if v17 and count2 ~= 1 then
						break
					end

					if not (not v17 or item.enabled) then
						continue
					end

					local v18 = overflowIcon.enabled and 0 or 10

					local boundaryX = getBoundaryX(item, k, v18)
					local v19

					if k == "left" and boundaryX < v15 then
						v19 = true
					elseif k == "right" then
						v19 = v15 < boundaryX
					else
						v19 = false
					end

					if not v19 then
						continue
					end

					v15 = boundaryX

					if doesExceed(boundaryX) then -- inferred equivalent call
						v16 = true
					end
				end
			end
			checkBoundaryExceeded(v6[v9].records)
			checkBoundaryExceeded(v6.mid.records)

			if v16 then
				local records = v7.records
				local count2 = #records

				for i = 1, count2 do
					local v17 = k == "left" and records[count2 + 1 - i]

					if not v17 then
						if k == "right" then
							v17 = records[i]
						else
							v17 = false
						end
					end

					if v17 ~= overflowIcon and IconController.canShowIconOnTopbar(v17) then
						local offset3 = overflowIcon:get("iconSize", overflowIcon:getIconState()).X.Offset

						if overflowIcon.enabled then
							v8 += v8 + offset3
						end

						local boundaryX = getBoundaryX(v17, v9, v8)
						local v18

						if k == "left" and v15 <= boundaryX then
							v18 = true
						elseif k == "right" then
							v18 = boundaryX <= v15
						else
							v18 = false
						end

						if not v18 then
							break
						end

						if not overflowIcon.enabled then
							local iconContainer = overflowIcon.instances.iconContainer
							local y = iconContainer.Position.Y
							local boundaryX2 = getBoundaryX(v17, v9, k == "left" and -iconContainer.Size.X.Offset or 0)
							iconContainer.Position = UDim2.new(0, boundaryX2, y.Scale, y.Offset)
							overflowIcon:setEnabled(true)
						end

						if #v17.dropdownIcons > 0 then
							v17._overflowConvertedToMenu = true
							local isSelected = v17.isSelected
							v17:deselect()
							local dropdownIcons = {}

							for _, dropdownIcon in pairs(v17.dropdownIcons) do
								table.insert(dropdownIcons, dropdownIcon)
							end

							for _, dropdownIcon in pairs(v17.dropdownIcons) do
								dropdownIcon:leave()
							end

							v17:setMenu(dropdownIcons)

							if isSelected and overflowIcon.isSelected then
								v17:select()
							end
						end

						if v17.hovering then
							v17.wasHoveringBeforeOverflow = true
						end

						v17:join(overflowIcon, "dropdown")

						if not (#v17.menuIcons > 0 and v17.menuOpen) then
							break
						end

						v17:deselect()
						v17:select()
						overflowIcon:select()
						break
					end
				end
			else
				local v17 = nil
				local v18 = nil
				local v19 = #overflowIcon.dropdownIcons

				if not icon or not icon.enabled or #v7.records ~= 1 or #v10.records == 1 then
					for _, dropdownIcon in pairs(overflowIcon.dropdownIcons) do
						local order = dropdownIcon:get("order")

						if not (v18 == nil or k == "left" and order < v17 or k == "right" and v17 < order) then
							continue
						end

						v17 = order
						v18 = dropdownIcon
					end
				end

				if v18 then
					local sizeX = getSizeX(v18, true)
					local offset3 = overflowIcon:get("iconSize", overflowIcon:getIconState()).X.Offset
					local menuOffset2, v20 = IconController.getMenuOffset(overflowIcon)
					local v21 = v9 == "left" and -0 - menuOffset2

					if not v21 then
						if v9 == "right" then
							v21 = offset3 + 0 + v20
						else
							v21 = false
						end
					end

					local v22 = overflowIcon.targetPosition.X.Offset + v21

					if v19 == 1 then
						v22 = getBoundaryX(overflowIcon, k, v8 - 10)
					end

					if sizeX < math.abs(v15 - v22) - v8 * 2 then
						if #overflowIcon.dropdownIcons == 1 then
							overflowIcon:setEnabled(false)
						end

						local iconContainer = overflowIcon.instances.iconContainer
						local y = iconContainer.Position.Y
						iconContainer.Position = UDim2.new(0, v22, y.Scale, y.Offset)
						v18:leave()
						v18.wasHoveringBeforeOverflow = nil

						if v18._overflowConvertedToMenu then
							v18._overflowConvertedToMenu = nil
							local menuIcons = {}

							for _, menuIcon in pairs(v18.menuIcons) do
								table.insert(menuIcons, menuIcon)
							end

							for _, menuIcon in pairs(v18.menuIcons) do
								menuIcon:leave()
							end

							v18:setDropdown(menuIcons)
						end
					end
				end
			end
		end

		if flag2 then
			flag2 = false
			IconController.updateTopbar()
		end

		return true
	end)
end

function IconController.setTopbarEnabled(visible, p)
	local v7 = p == nil or p

	local indicator = TopbarPlusGui.Indicator

	if v7 and not visible then
		v2 = true
	elseif v7 and visible then
		v2 = false
	end

	local success2, result2 = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_): boolean
		return true
	end)

	local visible2 = success2 and result2 or not IconController.mimicCoreGui

	if IconController.controllerModeEnabled then
		if visible then
			if TopbarPlusGui.TopbarContainer.Visible or v2 or v3 or not visible2 then
				return
			end

			if v7 then
				indicator.Visible = visible2
				return
			end

			indicator.Active = false

			if inputBeganConnection and inputBeganConnection.Connected then
				inputBeganConnection:Disconnect()
			end

			if
				HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1)
				and HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small)
			then
				HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 1)
				delay(0.2, function()
					pcall(function()
						HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
					end)
				end)
			end

			TopbarPlusGui.TopbarContainer.Visible = true
			TopbarPlusGui.TopbarContainer:TweenPosition(
				UDim2.new(0, 0, 0, 37),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true
			)

			IconController:_updateSelectionGroup()
			RunService.Heartbeat:Wait()
			local v8 = nil
			local v9 = 0

			for k, _ in pairs(v) do
				if
					IconController.canShowIconOnTopbar(k)
					and (v8 == nil or k:get("order") < v8:get("order"))
					and k.enabled
				then
					v8 = k
				end

				local v10 = -27 + k.instances.iconContainer.AbsoluteSize.Y + 50

				if v9 < v10 then
					v9 = v10
				end
			end

			if GuiService:GetEmotesMenuOpen() then
				GuiService:SetEmotesMenuOpen(false)
			end

			if GuiService:GetInspectMenuEnabled() then
				GuiService:CloseInspectMenu()
			end

			local previousSelectedObject = IconController._previousSelectedObject or v8.instances.iconButton
			IconController._setControllerSelectedObject(previousSelectedObject)
			indicator.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB)
			indicator:TweenPosition(
				UDim2.new(0.5, 0, 0, v9 + 32),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true
			)
		else
			if v7 then
				indicator.Visible = false
			elseif visible2 then
				indicator.Visible = true
				indicator.Active = true
				inputBeganConnection = indicator.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						IconController.setTopbarEnabled(true, false)
					end
				end)
			else
				indicator.Visible = false
			end

			if not TopbarPlusGui.TopbarContainer.Visible then
				return
			end

			GuiService.AutoSelectGuiEnabled = true
			IconController:_updateSelectionGroup(true)
			TopbarPlusGui.TopbarContainer:TweenPosition(
				UDim2.new(0, 0, 0, -TopbarPlusGui.TopbarContainer.Size.Y.Offset + 32),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					TopbarPlusGui.TopbarContainer.Visible = false
				end
			)

			indicator.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.DPadDown)
			indicator:TweenPosition(UDim2.new(0.5, 0, 0, 5), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
		end
	else
		local topbarContainer = TopbarPlusGui.TopbarContainer

		if visible2 then
			topbarContainer.Visible = visible
		else
			topbarContainer.Visible = false
		end
	end
end

function IconController.setGap(p, p2)
	local v7 = tonumber(p) or 12
	local lower = tostring(p2):lower()

	if lower == "left" or lower == "mid" or lower == "right" then
		IconController[lower .. "Gap"] = v7
	else
		IconController.leftGap = v7
		IconController.midGap = v7
		IconController.rightGap = v7
	end

	IconController.updateTopbar()
end

function IconController.setLeftOffset(p)
	IconController.leftOffset = tonumber(p) or 0
	IconController.updateTopbar()
end

function IconController.setRightOffset(p)
	IconController.rightOffset = tonumber(p) or 0
	IconController.updateTopbar()
end

local localPlayer = Players.LocalPlayer
local v7 = {}
localPlayer.CharacterAdded:Connect(function()
	for _, v8 in pairs(v7) do
		v8:destroy()
	end

	v7 = {}
end)
function IconController.clearIconOnSpawn(p)
	coroutine.wrap(function()
		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		table.insert(v7, p)
	end)()
end

function IconController:_updateSelectionGroup(p)
	if IconController._navigationEnabled then
		GuiService:RemoveSelectionGroup("TopbarPlusIcons")
	end

	if p then
		GuiService.CoreGuiNavigationEnabled = IconController._originalCoreGuiNavigationEnabled
		GuiService.GuiNavigationEnabled = IconController._originalGuiNavigationEnabled
		IconController._navigationEnabled = nil
	elseif IconController.controllerModeEnabled then
		local icons = IconController.getIcons()
		local iconButtons = {}

		for _, icon in pairs(icons) do
			if not icon.joinedFeatureName or icon._parentIcon[icon.joinedFeatureName .. "Open"] == true then
				table.insert(iconButtons, icon.instances.iconButton)
			end
		end

		GuiService:AddSelectionTuple("TopbarPlusIcons", table.unpack(iconButtons))

		if not IconController._navigationEnabled then
			IconController._originalCoreGuiNavigationEnabled = GuiService.CoreGuiNavigationEnabled
			IconController._originalGuiNavigationEnabled = GuiService.GuiNavigationEnabled
			GuiService.CoreGuiNavigationEnabled = false
			GuiService.GuiNavigationEnabled = true
			IconController._navigationEnabled = true
		end
	end
end

local function getScaleMultiplier(): number -- 2 equivalent calls inferred from this helper
	return if GuiService:IsTenFootInterface() then 3 else 1.3
end

function IconController._setControllerSelectedObject(selectedObject)
	local controllerSetCount = IconController._controllerSetCount and IconController._controllerSetCount + 1 or 0
	IconController._controllerSetCount = controllerSetCount
	GuiService.SelectedObject = selectedObject
	task.delay(0.1, function()
		if controllerSetCount == IconController._controllerSetCountS then
			GuiService.SelectedObject = selectedObject
		end
	end)
end

function IconController._enableControllerMode(controllerModeEnabled)
	local indicator = TopbarPlusGui.Indicator
	IconController.getIcon("_TopbarControllerOption")

	if IconController.controllerModeEnabled == controllerModeEnabled then
		return
	end

	IconController.controllerModeEnabled = controllerModeEnabled

	local function fn()
		return StarterGui:GetCore("TopbarEnabled")
	end
	local function fn2(_): boolean
		return true
	end

	if controllerModeEnabled then
		TopbarPlusGui.TopbarContainer.Position = UDim2.new(0, 0, 0, 5)
		TopbarPlusGui.TopbarContainer.Visible = false
		local scaleMultiplier = getScaleMultiplier() -- inferred equivalent call
		indicator.Position = UDim2.new(0.5, 0, 0, 5)
		indicator.Size = UDim2.new(0, 18 * scaleMultiplier, 0, 18 * scaleMultiplier)
		indicator.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.DPadDown)
		local success2, result2 = xpcall(fn, fn2)

		indicator.Visible = success2 and result2 or not IconController.mimicCoreGui
		indicator.Position = UDim2.new(0.5, 0, 0, 5)
		indicator.Active = true
		inputBeganConnection = indicator.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				IconController.setTopbarEnabled(true, false)
			end
		end)
	else
		TopbarPlusGui.TopbarContainer.Position = UDim2.new(0, 0, 0, 0)
		local topbarContainer = TopbarPlusGui.TopbarContainer
		local success2, result2 = xpcall(fn, fn2)

		topbarContainer.Visible = success2 and result2 or not IconController.mimicCoreGui
		indicator.Visible = false
		IconController._setControllerSelectedObject(nil)
	end

	for k, _ in pairs(v) do
		IconController._enableControllerModeForIcon(k, controllerModeEnabled)
	end
end

function IconController:_enableControllerModeForIcon(p)
	local parentIcon = self._parentIcon
	local joinedFeatureName = self.joinedFeatureName

	if parentIcon then
		self:leave()
	end

	if p then
		local scaleMultiplier = getScaleMultiplier() -- inferred equivalent call
		local v8 = self:get("iconSize", "deselected")
		local v9 = self:get("iconSize", "selected")
		local hovering = self:getHovering("iconSize")
		self:set(
			"iconSize",
			UDim2.new(0, v8.X.Offset * scaleMultiplier, 0, v8.Y.Offset * scaleMultiplier),
			"deselected",
			"controllerMode"
		)
		self:set(
			"iconSize",
			UDim2.new(0, v9.X.Offset * scaleMultiplier, 0, v9.Y.Offset * scaleMultiplier),
			"selected",
			"controllerMode"
		)

		if hovering then
			self:set(
				"iconSize",
				UDim2.new(0, v9.X.Offset * scaleMultiplier, 0, v9.Y.Offset * scaleMultiplier),
				"hovering",
				"controllerMode"
			)
		end

		self:set("alignment", "mid", "deselected", "controllerMode")
		self:set("alignment", "mid", "selected", "controllerMode")
	else
		for _, v8 in pairs({ "deselected", "selected", "hovering" }) do
			local _, v9 = self:get("alignment", v8, "controllerMode")

			if v9 then
				self:set("alignment", v9, v8)
			end

			local _, v10 = self:get("iconSize", v8, "controllerMode")

			if v10 then
				self:set("iconSize", v10, v8)
			end
		end
	end

	if parentIcon then
		self:join(parentIcon, joinedFeatureName)
	end
end

local flag3 = false
function IconController.setupHealthbar()
	if flag3 then
		return
	end

	flag3 = true

	task.defer(function()
		RunService.Heartbeat:Wait()
		local module = require(parent)

		module.new():setProperty("internalIcon", true):setName("_FakeHealthbar"):setRight():setOrder(-420):setSize(
			80,
			32
		):lock():set(
			"iconBackgroundTransparency",
			1
		):give(function(object2)
			local healthContainer = Instance.new("Frame")
			healthContainer.Name = "HealthContainer"
			healthContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			healthContainer.BorderSizePixel = 0
			healthContainer.AnchorPoint = Vector2.new(0, 0.5)
			healthContainer.Position = UDim2.new(0, 0, 0.5, 0)
			healthContainer.Size = UDim2.new(1, 0, 0.2, 0)
			healthContainer.Visible = true
			healthContainer.ZIndex = 11
			healthContainer.Parent = object2.instances.iconButton

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = healthContainer

			local healthFrame = healthContainer:Clone()
			healthFrame.Name = "HealthFrame"
			healthFrame.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
			healthFrame.BorderSizePixel = 0
			healthFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			healthFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			healthFrame.Size = UDim2.new(1, -2, 1, -2)
			healthFrame.Visible = true
			healthFrame.ZIndex = 12
			healthFrame.Parent = healthContainer

			local healthBar = healthFrame:Clone()
			healthBar.Name = "HealthBar"
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			healthBar.BorderSizePixel = 0
			healthBar.AnchorPoint = Vector2.new(0, 0.5)
			healthBar.Position = UDim2.new(0, 0, 0.5, 0)
			healthBar.Size = UDim2.new(0.5, 0, 1, 0)
			healthBar.Visible = true
			healthBar.ZIndex = 13
			healthBar.Parent = healthFrame

			local color = Color3.fromRGB(27, 252, 107)
			local color2 = Color3.fromRGB(250, 235, 0)
			local color3 = Color3.fromRGB(255, 28, 0)

			local function powColor3(data, p) -- 5 equivalent calls inferred from this helper
				return Color3.new(math.pow(data.R, p), math.pow(data.G, p), (math.pow(data.B, p)))
			end

			local function lerpColor(data, data2, p, value2)
				local v8 = value2 or 2

				return powColor3(powColor3(data, v8):Lerp(powColor3(data2, v8), p), 1 / v8) -- inferred equivalent call
			end

			local v8 = true
			local function listenToHealth(character)
				if not character then
					return
				end

				local humanoid = character:WaitForChild("Humanoid", 10)

				if not humanoid then
					return
				end

				local function updateHealthBar()
					local coreGuiEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
					local v9 = humanoid.Health / humanoid.MaxHealth

					if v9 == 1 or IconController.healthbarDisabled or v8 and coreGuiEnabled == false then
						if object2.enabled then
							object2:setEnabled(false)
						end
					else
						if v9 < 1 then
							if not object2.enabled then
								object2:setEnabled(true)
							end

							v8 = false

							if coreGuiEnabled then
								StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
							end
						end

						local v10 = 1.25 * v9 + -0.125
						local v11 = v10 > 1 and 1 or v10 < 0 and 0 or v10
						local v12 = v9 > 0.5 and color or color2
						local v13 = v9 > 0.5 and color2 or color3
						local v14 = (1 - v11) * 2
						local v15 = v9 > 0.5 and 1 - v14 or 2 - v14
						local v16 = nil or 2

						local backgroundColor = powColor3(powColor3(v13, v16):Lerp(powColor3(v12, v16), v15), 1 / v16) -- inferred equivalent call

						local udim = UDim2.new(v9, 0, 1, 0)
						healthBar.BackgroundColor3 = backgroundColor
						healthBar.Size = udim
					end
				end

				humanoid.HealthChanged:Connect(updateHealthBar)
				IconController.healthbarDisabledSignal:Connect(updateHealthBar)
				updateHealthBar()
			end
			localPlayer.CharacterAdded:Connect(function(character)
				listenToHealth(character)
			end)
			task.spawn(listenToHealth, localPlayer.Character)
		end)
	end)
end

function IconController._determineControllerDisplay()
	local mouseEnabled = UserInputService.MouseEnabled
	local gamepadEnabled = UserInputService.GamepadEnabled
	local icon = IconController.getIcon("_TopbarControllerOption")

	if mouseEnabled and gamepadEnabled then
		if v5 then
			icon:setEnabled(false)
		else
			icon:setEnabled(true)
		end
	elseif mouseEnabled and not gamepadEnabled then
		icon:setEnabled(false)
		IconController._enableControllerMode(false)
		icon:deselect()
	elseif not mouseEnabled and gamepadEnabled then
		icon:setEnabled(false)
		IconController._enableControllerMode(true)
	end
end

coroutine.wrap(function()
	RunService.Heartbeat:Wait()
	local module = require(parent)
	local v8 = module.new():setProperty("internalIcon", true):setName("_TopbarControllerOption"):setOrder(100):setImage(11162828670):setRight():setEnabled(false):setTip("Controller mode"):setProperty(
		"deselectWhenOtherIconSelected",
		false
	)

	UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(IconController._determineControllerDisplay)
	UserInputService.GamepadConnected:Connect(IconController._determineControllerDisplay)
	UserInputService.GamepadDisconnected:Connect(IconController._determineControllerDisplay)
	IconController._determineControllerDisplay()

	local function iconClicked()
		local isSelected = v8.isSelected

		v8:setTip(isSelected and "Normal mode" or "Controller mode")
		IconController._enableControllerMode(isSelected)
	end
	v8.selected:Connect(iconClicked)
	v8.deselected:Connect(iconClicked)

	UserInputService.InputBegan:Connect(function(input, _)
		if not IconController.controllerModeEnabled then
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadDown then
			if not GuiService.SelectedObject then
				local success2, result2 = xpcall(function()
					return StarterGui:GetCore("TopbarEnabled")
				end, function(_): boolean
					return true
				end)

				if success2 and result2 or not IconController.mimicCoreGui then
					IconController.setTopbarEnabled(true, false)
				end
			end
		elseif input.KeyCode == Enum.KeyCode.ButtonB and not IconController.disableButtonB then
			if
				IconController.activeButtonBCallbacks == 1
				and TopbarPlusGui.Indicator.Image == UserInputService:GetImageForKeyCode(Enum.KeyCode.DPadDown)
			then
				IconController.activeButtonBCallbacks = 0
				GuiService.SelectedObject = nil
			end

			if IconController.activeButtonBCallbacks == 0 then
				IconController._previousSelectedObject = GuiService.SelectedObject
				IconController._setControllerSelectedObject(nil)
				IconController.setTopbarEnabled(false, false)
			end
		end

		input:Destroy()
	end)

	for k, v9 in pairs(v6) do
		if k == "mid" then
			continue
		end

		local v10 = "_overflowIcon-" .. k
		local overflowIcon = module.new():setProperty("internalIcon", true):setImage(6069276526):setName(v10):setEnabled(false)
		v9.overflowIcon = overflowIcon
		overflowIcon.accountForWhenDisabled = true

		if k == "left" then
			overflowIcon:setOrder(1e999)
			overflowIcon:setLeft()
			overflowIcon:set("dropdownAlignment", "right")
		elseif k == "right" then
			overflowIcon:setOrder(-1e999)
			overflowIcon:setRight()
			overflowIcon:set("dropdownAlignment", "left")
		end

		overflowIcon.lockedSettings = { iconImage = true, order = true, alignment = true }
	end

	task.defer(function()
		local success2, result2

		while true do
			success2, result2 = pcall(function()
				return VoiceChatService:IsVoiceEnabledForUserIdAsync(localPlayer.UserId)
			end)

			if success2 then
				break
			end

			task.wait(1)
		end

		local function checkVoiceChatManuallyEnabled() -- 2 equivalent calls inferred from this helper
			if IconController.voiceChatEnabled and success2 and result2 then
				v4 = true
				IconController.updateTopbar()
			end
		end

		checkVoiceChatManuallyEnabled() -- inferred equivalent call
		localPlayer.PlayerGui:WaitForChild("TopbarPlus", 999)
		task.delay(10, function()
			checkVoiceChatManuallyEnabled() -- inferred equivalent call

			if IconController.voiceChatEnabled == nil and success2 and result2 and isStudio then
				warn("⚠️TopbarPlus Action Required⚠️ If VoiceChat is enabled within your experience it's vital you set IconController.voiceChatEnabled to true ``require(game.ReplicatedStorage.Icon.IconController).voiceChatEnabled = true`` otherwise the BETA label will not be accounted for within your live servers. This warning will disappear after doing so. Feel free to delete this warning or to set to false if you don't have VoiceChat enabled within your experience.")
			end
		end)
	end)

	if not isStudio then
		local v9 = game.CreatorId
		local GroupService = game:GetService("GroupService")

		if game.CreatorType == Enum.CreatorType.Group then
			local success2, result2 = pcall(function()
				return GroupService:GetGroupInfoAsync(game.CreatorId).Owner
			end)

			if success2 then
				v9 = result2.Id
			end
		end

		local VERSION = require(parent.VERSION)

		if localPlayer.UserId ~= v9 then
			local MarketplaceService = game:GetService("MarketplaceService")
			local success2, result2 = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)

			if success2 and result2 then
				local name = result2.Name
				print(("\n\n\n⚽ %s uses TopbarPlus %s\n🍍 TopbarPlus was developed by ForeverHD and the Nanoblox Team\n🚀 You can learn more and take a free copy by searching for 'TopbarPlus' on the DevForum\n\n"):format(
					name,
					VERSION
				))
			end
		end
	end
end)()

coroutine.wrap(function()
	local chatScript = Players.LocalPlayer.PlayerScripts:WaitForChild("ChatScript", 4)

	if not chatScript then
		local Chat = game:GetService("Chat")
		chatScript = Chat:WaitForChild("ChatScript", 4)
	end

	if not chatScript then
		return
	end

	local chatMain = chatScript:FindFirstChild("ChatMain")

	if not chatMain then
		return
	end

	local module = require(chatMain)
	module.CoreGuiEnabled:connect(function()
		local success2, result2 = xpcall(function()
			return StarterGui:GetCore("TopbarEnabled")
		end, function(_): boolean
			return true
		end)

		local previousTopbarEnabled = success2 and result2

		if previousTopbarEnabled == IconController.previousTopbarEnabled then
			IconController.updateTopbar()
			return "SetCoreGuiEnabled was called instead of SetCore"
		end

		if IconController.mimicCoreGui then
			IconController.previousTopbarEnabled = previousTopbarEnabled

			if IconController.controllerModeEnabled then
				IconController.setTopbarEnabled(false, false)
			else
				IconController.setTopbarEnabled(previousTopbarEnabled, false)
			end
		end

		IconController.updateTopbar()
	end)
	local success2, result2 = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_): boolean
		return true
	end)

	local v8 = success2 and result2

	local v9 = not (v8 or IconController.mimicCoreGui) or v8

	IconController.setTopbarEnabled(v9, false)
end)()

GuiService.MenuClosed:Connect(function()
	if VRService.VREnabled then
		return
	end

	v3 = false

	if not IconController.controllerModeEnabled then
		IconController.setTopbarEnabled(IconController.topbarEnabled, false)
	end
end)
GuiService.MenuOpened:Connect(function()
	if VRService.VREnabled then
		return
	end

	v3 = true
	IconController.setTopbarEnabled(false, false)
end)
bindCamera() -- inferred equivalent call
task.spawn(function()
	local success2, result2 = pcall(function()
		return LocalizationService:GetTranslatorForPlayerAsync(localPlayer)
	end)
	local function updateAllIcons()
		local icons = IconController.getIcons()

		for _, icon in pairs(icons) do
			icon:_updateAll()
		end
	end

	if success2 then
		IconController.translator = result2
		result2:GetPropertyChangedSignal("LocaleId"):Connect(updateAllIcons)
		task.spawn(updateAllIcons)
		task.delay(1, updateAllIcons)
		task.delay(10, updateAllIcons)
	end
end)

return IconController