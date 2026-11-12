local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Satchel = {}
Satchel.OpenClose = nil
Satchel.IsOpen = false
Satchel.StateChanged = Instance.new("BindableEvent")
Satchel.ModuleName = "Backpack"
Satchel.KeepVRTopbarOpen = true
Satchel.VRIsExclusive = true
Satchel.VRClosesNonExclusive = true
Satchel.BackpackEmpty = Instance.new("BindableEvent")
Satchel.BackpackEmpty.Name = "BackpackEmpty"

Satchel.BackpackItemAdded = Instance.new("BindableEvent")
Satchel.BackpackItemAdded.Name = "BackpackAdded"

Satchel.BackpackItemRemoved = Instance.new("BindableEvent")
Satchel.BackpackItemRemoved.Name = "BackpackRemoved"

local script2 = script

require(script.Attribution)

local preferredTransparency = GuiService.PreferredTransparency or 1

local v = not script2:GetAttribute("OutlineEquipBorder") or false
local insetIconPadding = script2:GetAttribute("InsetIconPadding")

local backgroundTransparency = script2:GetAttribute("BackgroundTransparency") or 0.3
local backgroundTransparency3 = backgroundTransparency * preferredTransparency
local udim = UDim.new(0, 8)
local backgroundColor3 = script2:GetAttribute("BackgroundColor3") or Color3.new(25 / 255, 27 / 255, 29 / 255)

local equipBorderColor3 = script2:GetAttribute("EquipBorderColor3") or Color3.new(0, 162 / 255, 1)
local backgroundTransparency2 = script2:GetAttribute("BackgroundTransparency") or 0.3
local backgroundTransparency4 = backgroundTransparency2 * preferredTransparency
local equipBorderSizePixel = script2:GetAttribute("EquipBorderSizePixel") or 0.5
local cornerRadius = script2:GetAttribute("CornerRadius") or UDim.new(0, 8)
local color = Color3.new(1, 1, 1)

local cornerRadius2 = cornerRadius - UDim.new(0, 5) or UDim.new(0, 3)
local backgroundColor3_2 = script2:GetAttribute("BackgroundColor3") or Color3.new(25 / 255, 27 / 255, 29 / 255)

local textColor3 = script2:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
local textStrokeTransparency = script2:GetAttribute("TextStrokeTransparency") or 0.5
local textStrokeColor3 = script2:GetAttribute("TextStrokeColor3") or Color3.new(0, 0, 0)

local color2 = Color3.new(25 / 255, 27 / 255, 29 / 255)

local backgroundTransparency5 = preferredTransparency * 0.2
local color3 = Color3.new(1, 1, 1)

local udim2 = UDim.new(0, 3)

local fontFace = script2:GetAttribute("FontFace") or Font.new("rbxasset://fonts/families/BuilderSans.json")
local textSize = script2:GetAttribute("TextSize") or 16
local value = Enum.KeyCode.Backspace.Value
local value2 = Enum.KeyCode.Zero.Value

local color4 = Color3.fromRGB(255, 215, 0)
local color5 = Color3.fromRGB(80, 70, 40)

local set = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true
}

local set2 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}

local v2 = true

local topbarplus = require(script.Parent.topbarplus)

local v3 = topbarplus.new():setName("Inventory"):setImage("rbxasset://textures/ui/TopBar/inventoryOn.png", "Selected"):setImage(
	"rbxasset://textures/ui/TopBar/inventoryOff.png",
	"Deselected"
):setImageScale(1):setCaption("Inventory"):bindToggleKey(Enum.KeyCode.Backquote):autoDeselect(false):setOrder(-1)

v3.toggled:Connect(function()
	if not GuiService.MenuIsOpen then
		Satchel.OpenClose()
	end
end)

local backpackGui = Instance.new("ScreenGui")
backpackGui.DisplayOrder = 120
backpackGui.IgnoreGuiInset = true
backpackGui.ResetOnSpawn = false
backpackGui.Name = "BackpackGui"
backpackGui.Parent = PlayerGui

local isTenFootInterface = GuiService:IsTenFootInterface()
local v4

if isTenFootInterface then
	v4 = 100
	textSize = 24
else
	v4 = 60
end

local v5 = false

local v6 = UserInputService.TouchEnabled and workspace.CurrentCamera.ViewportSize.X < 1024

local LocalPlayer = Players.LocalPlayer

local backpack = nil
local hotbar = nil
local inventory = nil
local vrInventorySelector = nil
local scrollingFrame = nil
local uiGridFrame = nil

local fn

local v7 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local v8 = v7:WaitForChild("Humanoid")
local Backpack = LocalPlayer:WaitForChild("Backpack")

local slots = {}
local v9 = nil
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = 0
local v14 = nil
local v15 = false
local v16 = false
local v17 = false
local flag = false

local connections = {}
local flag2 = false

local VREnabled = VRService.VREnabled
local v18 = VREnabled and 6 or v6 and 6 or 10
local v19 = VREnabled and 3 or v6 and 2 or 4
local v20 = nil
local v21 = nil

local HttpService = game:GetService("HttpService")
local v22 = nil
local saveFavorite = nil
local requestFavorites = nil

local v23 = {}

local function EvaluateBackpackPanelVisibility(flag3: boolean)
	return flag3 and v3.enabled and v2 and VRService.VREnabled
end

local function ShowVRBackpackPopup() end

local function FindLowestEmpty()
	for i = 1, v18 do
		local v24 = slots[i]

		if not v24.Tool then
			return v24
		end
	end

	return nil
end

local function isInventoryEmpty(): boolean -- 1 equivalent call inferred from this helper
	for i = v18 + 1, #slots do
		local v24 = slots[i]

		if v24 and v24.Tool then
			return false
		end
	end

	return true
end

Satchel.IsInventoryEmpty = isInventoryEmpty

local function UseGazeSelection(): boolean
	return false
end

local function AdjustHotbarFrames()
	local visible = inventory.Visible
	local v24 = visible and v18 or v13
	local count = 0

	for i = 1, v18 do
		local v25 = slots[i]

		if v25.Tool or visible then
			count += 1
			v25:Readjust(count, v24)
			v25.Frame.Visible = true
		else
			v25.Frame.Visible = false
		end
	end
end

local function UpdateScrollingFrameCanvasSize() -- 5 equivalent calls inferred from this helper
	local v24 = math.floor(scrollingFrame.AbsoluteSize.X / (v4 + 5))
	local v25 = math.ceil((#uiGridFrame:GetChildren() - 1) / v24) * (v4 + 5) + 5
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, v25)
end

local function AdjustInventoryFrames()
	for i = v18 + 1, #slots do
		local v24 = slots[i]
		v24.Frame.LayoutOrder = v24.Index
		v24.Frame.Visible = v24.Tool ~= nil
	end

	UpdateScrollingFrameCanvasSize() -- inferred equivalent call
end

local function UpdateBackpackLayout()
	hotbar.Size = UDim2.new(0, v18 * (v4 + 5) + 5, 0, v4 + 5 + 5)

	hotbar.Position = UDim2.new(0.5, -hotbar.Size.X.Offset / 2, 1, -hotbar.Size.Y.Offset)
	inventory.Size = UDim2.new(0, hotbar.Size.X.Offset, 0, hotbar.Size.Y.Offset * v19 + 40 + (VREnabled and 80 or 0))

	inventory.Position = UDim2.new(
		0.5,
		-inventory.Size.X.Offset / 2,
		1,
		hotbar.Position.Y.Offset - inventory.Size.Y.Offset
	)

	scrollingFrame.Size = UDim2.new(1, scrollingFrame.ScrollBarThickness + 1, 1, -40 - (VREnabled and 80 or 0))

	scrollingFrame.Position = UDim2.fromOffset(0, 40 + (VREnabled and 40 or 0))
	AdjustHotbarFrames()
	AdjustInventoryFrames()
end

local function Clamp(p: number, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
	return (math.min(p2, (math.max(p, p3))))
end

local function CheckBounds(p, p2: number, p3: number): boolean -- 2 equivalent calls inferred from this helper
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return absolutePosition.X < p2
		and p2 <= absolutePosition.X + absoluteSize.X
		and absolutePosition.Y < p3
		and p3 <= absolutePosition.Y + absoluteSize.Y
end

local function GetOffset(frame, vector2: Vector2) -- 1 equivalent call inferred from this helper
	return (frame.AbsolutePosition + frame.AbsoluteSize / 2 - vector2).Magnitude
end

local function DisableActiveHopper() -- 2 equivalent calls inferred from this helper
	v14:ToggleSelect()
	v10[v14]:UpdateEquipView()
	v14 = nil
end

local function UnequipAllTools() -- 8 equivalent calls inferred from this helper
	if v8 then
		v8:UnequipTools()

		if v14 then
			DisableActiveHopper() -- inferred equivalent call
		end
	end
end

local function EquipNewTool(tool) -- 1 equivalent call inferred from this helper
	UnequipAllTools() -- inferred equivalent call
	v8:EquipTool(tool)
end

local function IsEquipped(tool) -- 4 equivalent calls inferred from this helper
	return tool and tool.Parent == v7
end

local function CanBeFavorited(tool): boolean -- 9 equivalent calls inferred from this helper
	if tool and tool:IsA("Tool") then
		return tool:GetAttribute("CanBeFavorited") == true
	end

	return false
end

local function SortInventorySlots()
	local v24 = {}

	for i = v18 + 1, #slots do
		if slots[i] and slots[i].Tool then
			table.insert(v24, slots[i])
		end
	end

	table.sort(v24, function(a, b): boolean
		local isFavorited = a.Tool:GetAttribute("IsFavorited") == true
		local isFavorited2 = b.Tool:GetAttribute("IsFavorited") == true

		if isFavorited and not isFavorited2 then
			return true
		end

		if (isFavorited or not isFavorited2) and isFavorited and isFavorited2 then
			return (a.Tool:GetAttribute("FavoritedTime") or 0) > (b.Tool:GetAttribute("FavoritedTime") or 0)
		end

		return false
	end)

	for i, v25 in ipairs(v24) do
		local layoutOrder = v18 + i
		v25.Index = layoutOrder
		v25.Frame.LayoutOrder = layoutOrder
	end
end

local function MakeSlot(parent, p: number?)
	local v24 = p or #slots + 1

	local slot = {}
	slot.Tool = nil
	slot.Index = v24
	slot.Frame = nil
	local textButton = nil
	local fakeSlot = nil
	local icon = nil
	local toolName = nil
	local changedConnection = nil
	local border = nil

	local favoriteIcon = nil

	local toolTip = nil
	local number = nil

	local function UpdateSlotFading() -- 2 equivalent calls inferred from this helper
		textButton.SelectionImageObject = nil
		textButton.BackgroundTransparency = textButton.Draggable and 0 or backgroundTransparency4
	end

	function slot:Readjust(p2: number, p3: number)
		local halfOffset = hotbar.Size.X.Offset / 2
		local v25 = v4 + 5
		local v26 = p2 - (p3 / 2 + 0.5)
		textButton.Position = UDim2.fromOffset(halfOffset - v4 / 2 + v25 * v26, 5)
	end

	function slot:Fill(tool)
		if not tool then
			return self:Clear()
		end

		self.Tool = tool

		local function assignToolData()
			local textureId = tool.TextureId
			icon.Image = textureId

			if textureId == "" then
				toolName.Visible = true
			else
				toolName.Visible = false
			end

			toolName.Text = tool.Name

			if toolTip and tool:IsA("Tool") then
				toolTip.Text = tool.ToolTip
				toolTip.Size = UDim2.fromOffset(0, 16)
				toolTip.Position = UDim2.new(0.5, 0, 0, -5)
			end
		end
		assignToolData()

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		changedConnection = tool.Changed:Connect(function(p2: string)
			if p2 == "TextureId" or p2 == "Name" or p2 == "ToolTip" then
				assignToolData()
			end
		end)

		local v25 = self.Index <= v18
		local visible = inventory.Visible

		if (not v25 or visible) and not UserInputService.VREnabled then
			textButton.Draggable = true
		end

		self:UpdateEquipView()

		if v25 then
			v13 += 1

			if v16 and v13 >= 1 and not v5 then
				v5 = true
				ContextActionService:BindAction(
					"BackpackHotbarEquip",
					fn,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		end

		v10[tool] = self
		local flag3 = true
		local v26

		for i = 1, v18 do
			v26 = slots[i]

			if not v26.Tool then
				flag3 = false
				break
			end
		end

		if flag3 then
			v26 = nil
		end

		v9 = v26

		if CanBeFavorited(tool) then -- inferred equivalent call
			textButton.BackgroundColor3 = color5
		end

		if CanBeFavorited(tool) then -- inferred equivalent call
			local v27 = tool:GetAttribute("FavoriteID")

			if not v27 then
				v27 = HttpService:GenerateGUID(false)
				tool:SetAttribute("FavoriteID", v27)
			end

			local name = tool.Name

			for _, v28 in pairs(v23) do
				if v28.ToolName == name and v28.IsFavorited then
					tool:SetAttribute("IsFavorited", true)
					tool:SetAttribute("FavoritedTime", v28.FavoritedTime)

					v23[v27] = v28
					break
				end
			end
		end

		if favoriteIcon then
			favoriteIcon.Visible = self:IsFavorited()
		end

		if v18 < self.Index and self:IsFavorited() then
			SortInventorySlots()
		end
	end

	function slot:Clear()
		if not self.Tool then
			return
		end

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		icon.Image = ""
		toolName.Text = ""

		if toolTip then
			toolTip.Text = ""
			toolTip.Visible = false
		end

		textButton.Draggable = false

		self:UpdateEquipView(true)

		if self.Index <= v18 then
			v13 -= 1

			if v13 < 1 then
				v5 = false
				ContextActionService:UnbindAction("BackpackHotbarEquip")
			end
		end

		v10[self.Tool] = nil
		self.Tool = nil
		local flag3 = true
		local v25

		for i = 1, v18 do
			v25 = slots[i]

			if not v25.Tool then
				flag3 = false
				break
			end
		end

		if flag3 then
			v25 = nil
		end

		v9 = v25

		textButton.BackgroundColor3 = backgroundColor3

		if favoriteIcon then
			favoriteIcon.Visible = false
		end
	end

	function slot:UpdateEquipView(flag3: boolean?)
		if flag3 then
			if border then
				border.Parent = nil
			end
		elseif IsEquipped(self.Tool) then -- inferred equivalent call
			v20 = slot

			if not border then
				border = Instance.new("UIStroke")
				border.Name = "Border"
				border.Thickness = equipBorderSizePixel
				border.Color = equipBorderColor3
				border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			end

			if v == true then
				border.Parent = icon
			else
				border.Parent = textButton
			end
		elseif border then
			border.Parent = nil
		end

		UpdateSlotFading() -- inferred equivalent call
	end

	function slot:IsEquipped()
		local tool = self.Tool
		return tool and tool.Parent == v7
	end

	function slot:IsFavorited(): boolean
		if self.Tool and CanBeFavorited(self.Tool) then -- inferred equivalent call
			return self.Tool:GetAttribute("IsFavorited") == true
		end

		return false
	end

	function slot:ToggleFavorite()
		if self.Tool and CanBeFavorited(self.Tool) then -- inferred equivalent call
			local visible = not self:IsFavorited()
			self.Tool:SetAttribute("IsFavorited", visible)

			local now = nil

			if visible then
				now = os.time()
				self.Tool:SetAttribute("FavoritedTime", now)
			else
				self.Tool:SetAttribute("FavoritedTime", nil)
			end

			if favoriteIcon then
				favoriteIcon.Visible = visible
			end

			if v18 < self.Index then
				SortInventorySlots()
			end

			if v21 then
				v21()
			end

			if saveFavorite and self.Tool then
				local v25 = self.Tool:GetAttribute("FavoriteID")

				if not v25 then
					v25 = HttpService:GenerateGUID(false)
					self.Tool:SetAttribute("FavoriteID", v25)
				end

				local name = self.Tool.Name
				saveFavorite:FireServer(v25, name, visible, now)

				if visible then
					v23[v25] = { ToolName = name, IsFavorited = true, FavoritedTime = now }
				else
					v23[v25] = nil
				end
			end
		end
	end

	function slot:Delete()
		textButton:Destroy()
		table.remove(slots, self.Index)
		local v25 = #slots

		for i = self.Index, v25 do
			slots[i]:SlideBack()
		end

		UpdateScrollingFrameCanvasSize() -- inferred equivalent call
	end

	function slot:Swap(object)
		local tool = self.Tool
		local tool2 = object.Tool
		self:Clear()

		if tool2 then
			object:Clear()
			self:Fill(tool2)
		end

		if tool then
			object:Fill(tool)
		else
			object:Clear()
		end
	end

	function slot:SlideBack()
		self.Index -= 1
		textButton.Name = self.Index
		textButton.LayoutOrder = self.Index
	end

	function slot:TurnNumber(visible: boolean)
		if number then
			number.Visible = visible
		end
	end

	function slot:SetClickability(flag3: boolean)
		if self.Tool then
			if UserInputService.VREnabled then
				textButton.Draggable = false
			else
				textButton.Draggable = not flag3
			end

			UpdateSlotFading() -- inferred equivalent call
		end
	end

	function slot:CheckTerms(items)
		local total = 0
		local function checkEm(text: string, k) -- 2 equivalent calls inferred from this helper
			local _, v25 = text:lower():gsub(k, "")
			total += v25
		end
		local tool = self.Tool

		if not tool then
			return total
		end

		for k in pairs(items) do
			checkEm(toolName.Text, k) -- inferred equivalent call

			if tool:IsA("Tool") then
				checkEm(toolTip and toolTip.Text or "", k) -- inferred equivalent call
			end
		end

		return total
	end

	function slot:Select()
		local tool = slot.Tool

		if tool then
			if IsEquipped(tool) then -- inferred equivalent call
				UnequipAllTools() -- inferred equivalent call
			elseif tool.Parent == Backpack then
				EquipNewTool(tool) -- inferred equivalent call
			end
		end
	end

	textButton = Instance.new("TextButton")
	textButton.Name = tostring(v24)
	textButton.BackgroundColor3 = backgroundColor3
	textButton.BorderColor3 = color
	textButton.Text = ""
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.fromOffset(v4, v4)
	textButton.Active = true
	textButton.Draggable = false
	textButton.BackgroundTransparency = backgroundTransparency4
	textButton.MouseButton1Click:Connect(function()
		changeSlot(slot)
	end)

	textButton.MouseButton2Click:Connect(function()
		slot:ToggleFavorite()
	end)

	local lastTime = 0
	local thread = nil

	textButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			lastTime = os.clock()

			thread = task.delay(0.5, function()
				if lastTime > 0 and os.clock() - lastTime >= 0.5 then
					slot:ToggleFavorite()
					lastTime = 0
				end
			end)
		end
	end)

	textButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if thread then
				task.cancel(thread)
			end

			lastTime = 0
		end
	end)
	local corner = Instance.new("UICorner")
	corner.Name = "Corner"
	corner.CornerRadius = cornerRadius
	corner.Parent = textButton
	slot.Frame = textButton

	local selectionObjectClipper = Instance.new("Frame")
	selectionObjectClipper.Name = "SelectionObjectClipper"
	selectionObjectClipper.BackgroundTransparency = 1
	selectionObjectClipper.Visible = false
	selectionObjectClipper.Parent = textButton

	local selector = Instance.new("ImageLabel")
	selector.Name = "Selector"
	selector.BackgroundTransparency = 1
	selector.Size = UDim2.fromScale(1, 1)
	selector.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
	selector.ScaleType = Enum.ScaleType.Slice
	selector.SliceCenter = Rect.new(12, 12, 52, 52)
	selector.Parent = selectionObjectClipper

	icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.Name = "Icon"
	icon.Size = UDim2.fromScale(1, 1)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)

	if insetIconPadding == true then
		icon.Size = UDim2.new(1, -equipBorderSizePixel * 2, 1, -equipBorderSizePixel * 2)
	else
		icon.Size = UDim2.fromScale(1, 1)
	end

	icon.Parent = textButton

	local corner2 = Instance.new("UICorner")
	corner2.Name = "Corner"

	if insetIconPadding == true then
		corner2.CornerRadius = cornerRadius - UDim.new(0, equipBorderSizePixel)
	else
		corner2.CornerRadius = cornerRadius
	end

	corner2.Parent = icon

	toolName = Instance.new("TextLabel")
	toolName.BackgroundTransparency = 1
	toolName.Name = "ToolName"
	toolName.Text = ""
	toolName.TextColor3 = textColor3
	toolName.TextStrokeTransparency = textStrokeTransparency
	toolName.TextStrokeColor3 = textStrokeColor3
	toolName.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	toolName.TextSize = textSize
	toolName.Size = UDim2.new(1, -equipBorderSizePixel * 2, 1, -equipBorderSizePixel * 2)
	toolName.Position = UDim2.fromScale(0.5, 0.5)
	toolName.AnchorPoint = Vector2.new(0.5, 0.5)
	toolName.TextWrapped = true
	toolName.TextTruncate = Enum.TextTruncate.AtEnd
	toolName.Parent = textButton

	favoriteIcon = Instance.new("TextLabel")
	favoriteIcon.Name = "FavoriteIcon"
	favoriteIcon.BackgroundTransparency = 1
	favoriteIcon.Text = "⭐"
	favoriteIcon.TextColor3 = color4
	favoriteIcon.TextSize = 10
	favoriteIcon.Size = UDim2.fromOffset(14, 14)
	favoriteIcon.Position = UDim2.new(1, -2, 1, -2)
	favoriteIcon.AnchorPoint = Vector2.new(1, 1)
	favoriteIcon.ZIndex = 3
	favoriteIcon.Visible = false
	favoriteIcon.TextXAlignment = Enum.TextXAlignment.Center
	favoriteIcon.TextYAlignment = Enum.TextYAlignment.Center
	favoriteIcon.Parent = textButton

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Color = Color3.new(0, 0, 0)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke.Parent = favoriteIcon

	slot.Frame.LayoutOrder = slot.Index

	if v24 <= v18 then
		toolTip = Instance.new("TextLabel")
		toolTip.Name = "ToolTip"
		toolTip.Text = ""
		toolTip.Size = UDim2.fromScale(1, 1)
		toolTip.TextColor3 = textColor3
		toolTip.TextStrokeTransparency = textStrokeTransparency
		toolTip.TextStrokeColor3 = textStrokeColor3
		toolTip.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		toolTip.TextSize = textSize
		toolTip.ZIndex = 2
		toolTip.TextWrapped = false
		toolTip.TextYAlignment = Enum.TextYAlignment.Center
		toolTip.BackgroundColor3 = backgroundColor3_2
		toolTip.BackgroundTransparency = backgroundTransparency4
		toolTip.AnchorPoint = Vector2.new(0.5, 1)
		toolTip.BorderSizePixel = 0
		toolTip.Visible = false
		toolTip.AutomaticSize = Enum.AutomaticSize.X
		toolTip.Parent = textButton

		local corner3 = Instance.new("UICorner")
		corner3.Name = "Corner"
		corner3.CornerRadius = cornerRadius2
		corner3.Parent = toolTip

		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 4)
		uiPadding.PaddingRight = UDim.new(0, 4)
		uiPadding.PaddingTop = UDim.new(0, 4)
		uiPadding.PaddingBottom = UDim.new(0, 4)
		uiPadding.Parent = toolTip
		textButton.MouseEnter:Connect(function()
			if toolTip.Text ~= "" then
				toolTip.Visible = true
			end
		end)
		textButton.MouseLeave:Connect(function()
			toolTip.Visible = false
		end)

		function slot:MoveToInventory()
			if slot.Index <= v18 then
				local tool = slot.Tool
				self:Clear()
				local slot2 = MakeSlot(uiGridFrame)
				slot2:Fill(tool)

				if IsEquipped(tool) then -- inferred equivalent call
					UnequipAllTools() -- inferred equivalent call
				end

				if flag then
					slot2.Frame.Visible = false
					slot2.Parent = inventory
				end
			end
		end

		if v24 < 10 or v24 == v18 then
			local v25 = v24 < 10 and v24 or 0
			number = Instance.new("TextLabel")
			number.BackgroundTransparency = 1
			number.Name = "Number"
			number.TextColor3 = textColor3
			number.TextStrokeTransparency = textStrokeTransparency
			number.TextStrokeColor3 = textStrokeColor3
			number.TextSize = textSize
			number.Text = tostring(v25)
			number.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
			number.Size = UDim2.fromScale(0.4, 0.4)
			number.Visible = false
			number.Parent = textButton
			v11[value2 + v25] = slot.Select
		end
	end

	local position = textButton.Position
	local v25 = 0
	local parent2 = nil

	textButton.DragBegin:Connect(function(udim3: UDim2)
		v12[textButton] = true
		position = udim3

		textButton.BorderSizePixel = 2
		v3:lock()

		textButton.ZIndex = 2
		icon.ZIndex = 2
		toolName.ZIndex = 2
		textButton.Parent.ZIndex = 2

		if number then
			number.ZIndex = 2
		end

		parent2 = textButton.Parent

		if parent2 == uiGridFrame then
			local udim4 = UDim2.new(
				0,
				textButton.AbsolutePosition.X - inventory.AbsolutePosition.X,
				0,
				textButton.AbsolutePosition.Y - inventory.AbsolutePosition.Y
			)

			textButton.Parent = inventory
			textButton.Position = udim4

			fakeSlot = Instance.new("Frame")
			fakeSlot.Name = "FakeSlot"
			fakeSlot.LayoutOrder = textButton.LayoutOrder
			fakeSlot.Size = textButton.Size
			fakeSlot.BackgroundTransparency = 1
			fakeSlot.Parent = uiGridFrame
		end
	end)

	textButton.DragStopped:Connect(function(p2: number, p3: number)
		if fakeSlot then
			fakeSlot:Destroy()
		end

		local v26 = os.clock()

		textButton.Position = position
		textButton.Parent = parent2

		textButton.BorderSizePixel = 0
		v3:unlock()

		textButton.ZIndex = 1
		icon.ZIndex = 1
		toolName.ZIndex = 1
		parent2.ZIndex = 1

		if number then
			number.ZIndex = 1
		end

		v12[textButton] = nil

		if not slot.Tool then
			return
		end

		if CheckBounds(inventory, p2, p3) then -- inferred equivalent call
			if slot.Index <= v18 then
				slot:MoveToInventory()
			end

			if v18 < slot.Index and v26 - v25 < 0.5 then
				if v9 then
					local tool = slot.Tool
					slot:Clear()
					v9:Fill(tool)
					slot:Delete()
				end

				v26 = 0
			end
		elseif CheckBounds(hotbar, p2, p3) then -- inferred equivalent call
			local v27 = { 1e999, nil }

			for i = 1, v18 do
				local v28 = slots[i]
				local offset = GetOffset(v28.Frame, Vector2.new(p2, p3)) -- inferred equivalent call

				if offset < v27[1] then
					v27 = { offset, v28 }
				end
			end

			local v28 = v27[2]

			if v28 ~= slot then
				slot:Swap(v28)

				if v18 < slot.Index then
					local tool = slot.Tool

					if tool then
						if IsEquipped(tool) then -- inferred equivalent call
							UnequipAllTools() -- inferred equivalent call
						end

						if flag then
							slot.Frame.Visible = false
							slot.Frame.Parent = inventory
						end
					else
						slot:Delete()
					end
				end
			end
		elseif slot.Index <= v18 then
			slot:MoveToInventory()
		end

		v25 = v26
	end)

	textButton.Parent = parent
	slots[v24] = slot

	if v18 < v24 then
		UpdateScrollingFrameCanvasSize() -- inferred equivalent call

		if inventory.Visible and not flag then
			local v26 = scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteSize.Y
			scrollingFrame.CanvasPosition = Vector2.new(0, (math.max(0, v26)))
		end
	end

	return slot
end

local function OnChildAdded(child)
	if child:IsA("Tool") or child:IsA("HopperBin") then
		local _ = child.Parent == v7

		if v14 and child.Parent == v7 then
			DisableActiveHopper() -- inferred equivalent call
		end

		if not v15 and child.Parent == v7 and not v10[child] then
			local starterGear = LocalPlayer:FindFirstChild("StarterGear")

			if starterGear and starterGear:FindFirstChild(child.Name) then
				v15 = true

				for i = (v9 or MakeSlot(uiGridFrame)).Index, 1, -1 do
					local v24 = slots[i]
					local v25 = i - 1

					if v25 > 0 then
						slots[v25]:Swap(v24)
					else
						v24:Fill(child)
					end
				end

				for _, tool in pairs(v7:GetChildren()) do
					if tool:IsA("Tool") and tool ~= child then
						tool.Parent = Backpack
					end
				end

				AdjustHotbarFrames()
				return
			end
		end

		local v24 = v10[child]

		if v24 then
			v24:UpdateEquipView()
		else
			v24 = v9 or MakeSlot(uiGridFrame)
			v24:Fill(child)

			if v24.Index <= v18 and not inventory.Visible then
				AdjustHotbarFrames()
			end

			if child:IsA("HopperBin") and child.Active then
				UnequipAllTools() -- inferred equivalent call
				v14 = child
			end
		end

		Satchel.BackpackItemAdded:Fire(v24)
	elseif child:IsA("Humanoid") and child.Parent == v7 then
		v8 = child
	end
end

local function OnChildRemoved(instance)
	if not (instance:IsA("Tool") or instance:IsA("HopperBin")) then
		return
	end

	local parent = instance.Parent

	if parent == v7 or parent == Backpack then
		return
	end

	local v24 = v10[instance]

	if v24 then
		v24:Clear()

		if v18 < v24.Index then
			v24:Delete()
		elseif not inventory.Visible then
			AdjustHotbarFrames()
		end
	end

	if instance == v14 then
		v14 = nil
	end

	if v24 then
		Satchel.BackpackItemRemoved:Fire(v24)
	end

	if isInventoryEmpty() then -- inferred equivalent call
		Satchel.BackpackEmpty:Fire()
	end
end

local function OnCharacterAdded(character)
	for i = #slots, 1, -1 do
		local v24 = slots[i]

		if v24.Tool then
			v24:Clear()
		end

		if v18 < i then
			v24:Delete()
		end
	end

	v14 = nil

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	connections = {}

	v7 = character
	table.insert(connections, character.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, character.ChildAdded:Connect(OnChildAdded))

	for _, child in pairs(character:GetChildren()) do
		OnChildAdded(child)
	end

	Backpack = LocalPlayer:WaitForChild("Backpack")
	table.insert(connections, Backpack.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, Backpack.ChildAdded:Connect(OnChildAdded))

	for _, child in pairs(Backpack:GetChildren()) do
		OnChildAdded(child)
	end

	AdjustHotbarFrames()
end

local function OnInputBegan(p, flag3: boolean)
	local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

	local v24 = p.UserInputType == Enum.UserInputType.Keyboard
		and not v17
		and not chatInputBarConfiguration.IsFocused
		and (v16 or p.KeyCode.Value == value)
		and v11[p.KeyCode.Value]

	if v24 then
		v24(flag3)
	end

	local userInputType = p.UserInputType

	if
		not flag3
		and (userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch)
		and inventory.Visible
	then
		v3:deselect()
	end
end

local function OnUISChanged()
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		for i = 1, v18 do
			slots[i]:TurnNumber(false)
		end
	elseif UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard then
		for i = 1, v18 do
			slots[i]:TurnNumber(true)
		end
	else
		for _, v24 in pairs(set) do
			if UserInputService:GetLastInputType() == v24 then
				for i = 1, v18 do
					slots[i]:TurnNumber(true)
				end

				return
			end
		end

		for _, v24 in pairs(set2) do
			if UserInputService:GetLastInputType() == v24 then
				for i = 1, v18 do
					slots[i]:TurnNumber(false)
				end

				return
			end
		end
	end
end

local v24 = nil
local lastTime = nil

local function fn2() end

function unbindAllGamepadEquipActions()
	ContextActionService:UnbindAction("BackpackHasGamepadFocus")
	ContextActionService:UnbindAction("BackpackCloseInventory")
end

fn = function(_: string, p, p2)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	if
		v24
		and (v24.KeyCode == Enum.KeyCode.ButtonR1 and p2.KeyCode == Enum.KeyCode.ButtonL1 or v24.KeyCode == Enum.KeyCode.ButtonL1 and p2.KeyCode == Enum.KeyCode.ButtonR1)
		and os.clock() - lastTime <= 0.06
	then
		UnequipAllTools() -- inferred equivalent call
		v24 = p2
		lastTime = os.clock()
	else
		v24 = p2
		lastTime = os.clock()

		task.delay(0.06, function()
			if v24 ~= p2 then
				return
			end

			local v25 = p2.KeyCode == Enum.KeyCode.ButtonL1 and -1 or 1

			for i = 1, v18 do
				if slots[i]:IsEquipped() then
					local v26 = v25 + i
					local v27 = false

					if v18 < v26 then
						v26 = 1
						v27 = true
					elseif v26 < 1 then
						v26 = v18
						v27 = true
					end

					local v28 = v26

					while not slots[v26].Tool do
						v26 += v25

						if v26 == v28 then
							return
						end

						if v18 < v26 then
							v26 = 1
							v27 = true
						elseif v26 < 1 then
							v26 = v18
							v27 = true
						end
					end

					if not v27 then
						slots[v26]:Select()

						return
					end

					UnequipAllTools() -- inferred equivalent call
					v20 = nil
					return
				end
			end

			if v20 and v20.Tool then
				v20:Select()
				return
			end

			for i = v25 == -1 and v18 or 1, v25 == -1 and 1 or v18, v25 do
				if slots[i].Tool then
					slots[i]:Select()
					break
				end
			end
		end)
	end
end

function getGamepadSwapSlot()
	for i = 1, #slots do
		if slots[i].Frame.BorderSizePixel > 0 then
			return slots[i]
		end
	end
end

function changeSlot(object)
	local v25 = not VRService.VREnabled or inventory.Visible

	if object.Frame == GuiService.SelectedObject and v25 then
		local gamepadSwapSlot = getGamepadSwapSlot()

		if gamepadSwapSlot then
			gamepadSwapSlot.Frame.BorderSizePixel = 0

			if gamepadSwapSlot ~= object then
				object:Swap(gamepadSwapSlot)
				vrInventorySelector.SelectionImageObject.Visible = false

				if v18 < object.Index and not object.Tool then
					if GuiService.SelectedObject == object.Frame then
						GuiService.SelectedObject = gamepadSwapSlot.Frame
					end

					object:Delete()
				end

				if v18 < gamepadSwapSlot.Index and not gamepadSwapSlot.Tool then
					if GuiService.SelectedObject == gamepadSwapSlot.Frame then
						GuiService.SelectedObject = object.Frame
					end

					gamepadSwapSlot:Delete()
				end
			end
		else
			local size = object.Frame.Size
			local position = object.Frame.Position
			object.Frame:TweenSizeAndPosition(
				size + UDim2.fromOffset(10, 10),
				position - UDim2.fromOffset(5, 5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					object.Frame:TweenSizeAndPosition(
						size,
						position,
						Enum.EasingDirection.In,
						Enum.EasingStyle.Quad,
						0.1,
						true
					)
				end
			)

			object.Frame.BorderSizePixel = 3
			vrInventorySelector.SelectionImageObject.Visible = true
		end
	else
		object:Select()
		vrInventorySelector.SelectionImageObject.Visible = false
	end
end

function vrMoveSlotToInventory()
	if not VRService.VREnabled then
		return
	end

	local gamepadSwapSlot = getGamepadSwapSlot()

	if gamepadSwapSlot and gamepadSwapSlot.Tool then
		gamepadSwapSlot.Frame.BorderSizePixel = 0
		gamepadSwapSlot:MoveToInventory()
		vrInventorySelector.SelectionImageObject.Visible = false
	end
end

function enableGamepadInventoryControl()
	local function fn3()
		if getGamepadSwapSlot() then
			local gamepadSwapSlot = getGamepadSwapSlot()

			if gamepadSwapSlot then
				gamepadSwapSlot.Frame.BorderSizePixel = 0
			end
		elseif inventory.Visible then
			v3:deselect()
		end
	end

	ContextActionService:BindAction("BackpackHasGamepadFocus", fn2, false, Enum.UserInputType.Gamepad1)
	ContextActionService:BindAction(
		"BackpackCloseInventory",
		fn3,
		false,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonStart
	)

	GuiService.SelectedObject = hotbar:FindFirstChild("1")
end

function disableGamepadInventoryControl()
	unbindAllGamepadEquipActions()

	for i = 1, v18 do
		local v25 = slots[i]

		if v25 and v25.Frame then
			v25.Frame.BorderSizePixel = 0
		end
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(backpack) then
		GuiService.SelectedObject = nil
	end
end

local function bindBackpackHotbarAction() -- 1 equivalent call inferred from this helper
	if v16 and not v5 then
		v5 = true
		ContextActionService:BindAction("BackpackHotbarEquip", fn, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	end
end

local function unbindBackpackHotbarAction() -- 1 equivalent call inferred from this helper
	disableGamepadInventoryControl()
	v5 = false
	ContextActionService:UnbindAction("BackpackHotbarEquip")
end

function gamepadDisconnected()
	flag2 = false
	disableGamepadInventoryControl()
end

function gamepadConnected()
	flag2 = true
	GuiService:AddSelectionParent("BackpackSelection", backpack)

	if v13 >= 1 then
		bindBackpackHotbarAction() -- inferred equivalent call
	end

	if inventory.Visible then
		enableGamepadInventoryControl()
	end
end

local function OnIconChanged(visible: boolean)
	local success, _ = pcall(function()
		return visible and StarterGui:GetCore("TopbarEnabled")
	end)

	if not success then
		return
	end

	v16 = visible
	backpack.Visible = visible

	if visible then
		if v13 >= 1 and v16 and not v5 then
			v5 = true
			ContextActionService:BindAction(
				"BackpackHotbarEquip",
				fn,
				false,
				Enum.KeyCode.ButtonL1,
				Enum.KeyCode.ButtonR1
			)
		end
	else
		unbindBackpackHotbarAction() -- inferred equivalent call
	end
end

local function MakeVRRoundButton(name: string, image: string)
	local imageButton = Instance.new("ImageButton")
	imageButton.BackgroundTransparency = 1
	imageButton.Name = name
	imageButton.Size = UDim2.fromOffset(40, 40)
	imageButton.Image = "rbxasset://textures/ui/Keyboard/close_button_background.png"

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromScale(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.25, 0.25)
	icon.Image = image
	icon.Parent = imageButton

	local selection = Instance.new("ImageLabel")
	selection.BackgroundTransparency = 1
	selection.Name = "Selection"
	selection.Size = UDim2.fromScale(0.9, 0.9)
	selection.Position = UDim2.fromScale(0.05, 0.05)
	selection.Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png"
	imageButton.SelectionImageObject = selection

	return imageButton, icon, selection
end

backpack = Instance.new("Frame")
backpack.BackgroundTransparency = 1
backpack.Name = "Backpack"
backpack.Size = UDim2.fromScale(1, 1)
backpack.Visible = false
backpack.Parent = backpackGui

hotbar = Instance.new("Frame")
hotbar.BackgroundTransparency = 1
hotbar.Name = "Hotbar"
hotbar.Size = UDim2.fromScale(1, 1)
hotbar.Parent = backpack

for i = 1, v18 do
	local slot = MakeSlot(hotbar, i)
	slot.Frame.Visible = false

	if not v9 then
		v9 = slot
	end
end

local leftBumper = Instance.new("ImageLabel")
leftBumper.BackgroundTransparency = 1
leftBumper.Name = "LeftBumper"
leftBumper.Size = UDim2.fromOffset(40, 40)
leftBumper.Position = UDim2.new(0, -leftBumper.Size.X.Offset, 0.5, -leftBumper.Size.Y.Offset / 2)

local rightBumper = Instance.new("ImageLabel")
rightBumper.BackgroundTransparency = 1
rightBumper.Name = "RightBumper"
rightBumper.Size = UDim2.fromOffset(40, 40)
rightBumper.Position = UDim2.new(1, 0, 0.5, -rightBumper.Size.Y.Offset / 2)

inventory = Instance.new("Frame")
inventory.Name = "Inventory"
inventory.Size = UDim2.fromScale(1, 1)
inventory.BackgroundTransparency = backgroundTransparency3
inventory.BackgroundColor3 = backgroundColor3
inventory.Active = true
inventory.Visible = false
inventory.Parent = backpack

local corner = Instance.new("UICorner")
corner.Name = "Corner"
corner.CornerRadius = udim
corner.Parent = inventory

vrInventorySelector = Instance.new("TextButton")
vrInventorySelector.Name = "VRInventorySelector"
vrInventorySelector.Position = UDim2.new(0, 0, 0, 0)
vrInventorySelector.Size = UDim2.fromScale(1, 1)
vrInventorySelector.BackgroundTransparency = 1
vrInventorySelector.Text = ""
vrInventorySelector.Parent = inventory

local selector = Instance.new("ImageLabel")
selector.BackgroundTransparency = 1
selector.Name = "Selector"
selector.Size = UDim2.fromScale(1, 1)
selector.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
selector.ScaleType = Enum.ScaleType.Slice
selector.SliceCenter = Rect.new(12, 12, 52, 52)
selector.Visible = false
vrInventorySelector.SelectionImageObject = selector

vrInventorySelector.MouseButton1Click:Connect(function()
	vrMoveSlotToInventory()
end)

scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.fromScale(1, 1)
scrollingFrame.Selectable = false
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.ScrollBarImageColor3 = Color3.new(1, 1, 1)
scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = inventory

uiGridFrame = Instance.new("Frame")
uiGridFrame.BackgroundTransparency = 1
uiGridFrame.Name = "UIGridFrame"
uiGridFrame.Selectable = false
uiGridFrame.Size = UDim2.new(1, -10, 1, 0)
uiGridFrame.Position = UDim2.fromOffset(5, 0)
uiGridFrame.Parent = scrollingFrame

local uiGridLayout = Instance.new("UIGridLayout")
uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiGridLayout.CellSize = UDim2.fromOffset(v4, v4)
uiGridLayout.CellPadding = UDim2.fromOffset(5, 5)
uiGridLayout.Parent = uiGridFrame

local vrRoundButton = MakeVRRoundButton("ScrollUpButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
vrRoundButton.Size = UDim2.fromOffset(34, 34)
vrRoundButton.Position = UDim2.new(0.5, -vrRoundButton.Size.X.Offset / 2, 0, 43)
vrRoundButton.Icon.Position = vrRoundButton.Icon.Position - UDim2.fromOffset(0, 2)
vrRoundButton.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		Clamp( -- inferred equivalent call
			0,
			scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y,
			scrollingFrame.CanvasPosition.Y - (v4 + 5)
		)
	)
end)

local vrRoundButton2 = MakeVRRoundButton("ScrollDownButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
vrRoundButton2.Rotation = 180
vrRoundButton2.Icon.Position = vrRoundButton2.Icon.Position - UDim2.fromOffset(0, 2)
vrRoundButton2.Size = UDim2.fromOffset(34, 34)
vrRoundButton2.Position = UDim2.new(0.5, -vrRoundButton2.Size.X.Offset / 2, 1, -vrRoundButton2.Size.Y.Offset - 3)
vrRoundButton2.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		Clamp( -- inferred equivalent call
			0,
			scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y,
			scrollingFrame.CanvasPosition.Y + (v4 + 5)
		)
	)
end)

scrollingFrame.Changed:Connect(function(p: string)
	if p == "AbsoluteWindowSize" or p == "CanvasPosition" or p == "CanvasSize" then
		local visible = scrollingFrame.CanvasPosition.Y ~= 0
		local visible2 = scrollingFrame.CanvasPosition.Y < scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y

		vrRoundButton.Visible = visible
		vrRoundButton2.Visible = visible2
	end
end)

UpdateBackpackLayout()

local gamepadHintsFrame = Instance.new("Frame")
gamepadHintsFrame.Name = "GamepadHintsFrame"
gamepadHintsFrame.Size = UDim2.fromOffset(hotbar.Size.X.Offset, isTenFootInterface and 95 or 60)
gamepadHintsFrame.BackgroundTransparency = backgroundTransparency3
gamepadHintsFrame.BackgroundColor3 = backgroundColor3
gamepadHintsFrame.Visible = false
gamepadHintsFrame.Parent = backpack

local layout = Instance.new("UIListLayout")
layout.Name = "Layout"
layout.Padding = UDim.new(0, 25)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = gamepadHintsFrame

local corner2 = Instance.new("UICorner")
corner2.Name = "Corner"
corner2.CornerRadius = udim
corner2.Parent = gamepadHintsFrame

local function addGamepadHint(imageForKeyCode: string, text: string)
	local hintFrame = Instance.new("Frame")
	hintFrame.Name = "HintFrame"
	hintFrame.AutomaticSize = Enum.AutomaticSize.XY
	hintFrame.BackgroundTransparency = 1
	hintFrame.Parent = gamepadHintsFrame

	local layout2 = Instance.new("UIListLayout")
	layout2.Name = "Layout"
	layout2.Padding = isTenFootInterface and UDim.new(0, 20) or UDim.new(0, 12)
	layout2.FillDirection = Enum.FillDirection.Horizontal
	layout2.SortOrder = Enum.SortOrder.LayoutOrder
	layout2.VerticalAlignment = Enum.VerticalAlignment.Center
	layout2.Parent = hintFrame

	local hintImage = Instance.new("ImageLabel")
	hintImage.Name = "HintImage"
	hintImage.Size = isTenFootInterface and UDim2.fromOffset(60, 60) or UDim2.fromOffset(30, 30)
	hintImage.BackgroundTransparency = 1
	hintImage.Image = imageForKeyCode
	hintImage.Parent = hintFrame

	local hintText = Instance.new("TextLabel")
	hintText.Name = "HintText"
	hintText.AutomaticSize = Enum.AutomaticSize.XY
	hintText.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	hintText.TextSize = isTenFootInterface and 32 or 19
	hintText.BackgroundTransparency = 1
	hintText.Text = text
	hintText.TextColor3 = Color3.new(1, 1, 1)
	hintText.TextXAlignment = Enum.TextXAlignment.Left
	hintText.TextYAlignment = Enum.TextYAlignment.Center
	hintText.TextWrapped = true
	hintText.Parent = hintFrame

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = hintText.TextSize
	uiTextSizeConstraint.Parent = hintText
end

addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX), "Remove From Hotbar")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA), "Select/Swap")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB), "Close Backpack")

local function resizeGamepadHintsFrame()
	gamepadHintsFrame.Size = UDim2.new(hotbar.Size.X.Scale, hotbar.Size.X.Offset, 0, isTenFootInterface and 95 or 60)
	gamepadHintsFrame.Position = UDim2.new(
		hotbar.Position.X.Scale,
		hotbar.Position.X.Offset,
		inventory.Position.Y.Scale,
		inventory.Position.Y.Offset - gamepadHintsFrame.Size.Y.Offset - 5
	)

	local children = gamepadHintsFrame:GetChildren()
	local guiObjects = {}
	local total = 0

	for _, guiObject in pairs(children) do
		if guiObject:IsA("GuiObject") then
			table.insert(guiObjects, guiObject)
		end
	end

	for i = 1, #guiObjects do
		if not guiObjects[i]:IsA("GuiObject") then
			continue
		end

		guiObjects[i].Size = UDim2.new(1, 0, 1, -5)
		guiObjects[i].Position = UDim2.new(0, 0, 0, 0)

		total += guiObjects[i].HintText.Position.X.Offset + guiObjects[i].HintText.TextBounds.X
	end

	local v25 = (gamepadHintsFrame.AbsoluteSize.X - total) / (#guiObjects - 1)

	for i = 1, #guiObjects do
		guiObjects[i].Position = i == 1 and UDim2.new(0, 0, 0, 0)
			or UDim2.new(0, guiObjects[i - 1].Position.X.Offset + guiObjects[i - 1].Size.X.Offset + v25, 0, 0)

		guiObjects[i].Size = UDim2.new(
			0,
			guiObjects[i].HintText.Position.X.Offset + guiObjects[i].HintText.TextBounds.X,
			1,
			-5
		)
	end
end

local search = Instance.new("Frame")

search.Name = "Search"
search.BackgroundColor3 = color2
search.BackgroundTransparency = backgroundTransparency5
search.Size = UDim2.new(0, 190, 0, 30)

search.Position = UDim2.new(1, -search.Size.X.Offset - 5, 0, 5)
search.Parent = inventory

local corner3 = Instance.new("UICorner")
corner3.Name = "Corner"
corner3.CornerRadius = udim2
corner3.Parent = search

local border = Instance.new("UIStroke")
border.Name = "Border"
border.Color = color3
border.Thickness = 1
border.Transparency = 0.8
border.Parent = search

local textBox = Instance.new("TextBox")
textBox.BackgroundTransparency = 1
textBox.Name = "TextBox"
textBox.Text = ""
textBox.TextColor3 = textColor3
textBox.TextStrokeTransparency = textStrokeTransparency
textBox.TextStrokeColor3 = textStrokeColor3
textBox.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
textBox.PlaceholderText = "Search"
textBox.TextColor3 = textColor3
textBox.TextTransparency = textStrokeTransparency
textBox.TextStrokeColor3 = textStrokeColor3
textBox.ClearTextOnFocus = false
textBox.TextTruncate = Enum.TextTruncate.AtEnd
textBox.TextSize = textSize
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Center
textBox.Size = UDim2.new(0, 154, 0, 14)

textBox.AnchorPoint = Vector2.new(0, 0.5)
textBox.Position = UDim2.new(0, 8, 0.5, 0)
textBox.ZIndex = 2
textBox.Parent = search

local x = Instance.new("TextButton")
x.Name = "X"
x.Text = ""
x.Size = UDim2.fromOffset(30, 30)
x.Position = UDim2.new(1, -x.Size.X.Offset, 0.5, -x.Size.Y.Offset / 2)
x.ZIndex = 4
x.Visible = false
x.BackgroundTransparency = 1
x.Parent = search

local x2 = Instance.new("ImageButton")
x2.Name = "X"
x2.Image = "rbxasset://textures/ui/InspectMenu/x.png"
x2.BackgroundTransparency = 1
x2.Size = UDim2.new(0, search.Size.Y.Offset - 20, 0, search.Size.Y.Offset - 20)

x2.AnchorPoint = Vector2.new(0.5, 0.5)
x2.Position = UDim2.fromScale(0.5, 0.5)
x2.ZIndex = 1
x2.BorderSizePixel = 0
x2.Parent = x

local favoritesControlPanel = Instance.new("Frame")
favoritesControlPanel.Name = "FavoritesControlPanel"
favoritesControlPanel.BackgroundColor3 = backgroundColor3
favoritesControlPanel.BackgroundTransparency = backgroundTransparency3
favoritesControlPanel.Size = UDim2.new(1, 0, 0, 50)
favoritesControlPanel.Position = UDim2.fromOffset(0, -55)
favoritesControlPanel.Parent = inventory

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = udim
uiCorner.Parent = favoritesControlPanel

local favoriteHelperText = Instance.new("TextLabel")
favoriteHelperText.Name = "FavoriteHelperText"
favoriteHelperText.BackgroundTransparency = 1
favoriteHelperText.Text = "Right-click or long-press to favorite.\nContributor: san (@hack_byte)"
favoriteHelperText.TextColor3 = Color3.fromRGB(200, 200, 200)
favoriteHelperText.TextSize = 12
favoriteHelperText.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
favoriteHelperText.TextXAlignment = Enum.TextXAlignment.Left
favoriteHelperText.TextYAlignment = Enum.TextYAlignment.Center
favoriteHelperText.TextWrapped = false
favoriteHelperText.Size = UDim2.new(0.5, -10, 1, 0)
favoriteHelperText.Position = UDim2.fromOffset(10, 0)
favoriteHelperText.ZIndex = 2
favoriteHelperText.Parent = favoritesControlPanel

local v25 = false
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ToggleContainer"
toggleContainer.BackgroundTransparency = 1
toggleContainer.Size = UDim2.fromOffset(180, 32)
toggleContainer.Position = UDim2.new(1, -190, 0.5, -16)
toggleContainer.Parent = favoritesControlPanel

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.BorderSizePixel = 0
toggleButton.Text = ""
toggleButton.Size = UDim2.fromOffset(120, 24)
toggleButton.Position = UDim2.new(0, 50, 0.5, -15)
toggleButton.Parent = toggleContainer

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0.5, 0)
uiCorner2.Parent = toggleButton

local glow = Instance.new("UIStroke")
glow.Name = "Glow"
glow.Thickness = 1
glow.Color = Color3.fromRGB(100, 100, 100)
glow.Transparency = 0.5
glow.Parent = toggleButton

local slider = Instance.new("Frame")
slider.Name = "Slider"
slider.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
slider.BorderSizePixel = 0
slider.Size = UDim2.fromOffset(20, 20)
slider.Position = UDim2.new(0, 2, 0.5, -10)
slider.ZIndex = 2
slider.Parent = toggleButton

local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(1, 0)
uiCorner3.Parent = slider

local innerGlow = Instance.new("UIStroke")
innerGlow.Name = "InnerGlow"
innerGlow.Thickness = 2
innerGlow.Color = Color3.fromRGB(255, 255, 255)
innerGlow.Transparency = 0.5
innerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
innerGlow.Parent = slider

local stateText = Instance.new("TextLabel")
stateText.Name = "StateText"
stateText.BackgroundTransparency = 1
stateText.Text = "All"
stateText.TextColor3 = Color3.fromRGB(150, 150, 150)
stateText.TextSize = 10
stateText.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
stateText.TextXAlignment = Enum.TextXAlignment.Center
stateText.Size = UDim2.fromScale(1, 1)
stateText.ZIndex = 1
stateText.Parent = toggleButton

local function updateFilterDisplay()
	for i = v18 + 1, #slots do
		local v26 = slots[i]

		if not (v26 and v26.Frame) then
			continue
		end

		if v25 then
			v26.Frame.Visible = v26:IsFavorited()
		else
			v26.Frame.Visible = true
		end
	end
end

v21 = updateFilterDisplay

toggleButton.MouseButton1Click:Connect(function()
	v25 = not v25

	local TweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if v25 then
		local tween = TweenService:Create(slider, tweenInfo, {
			Position = UDim2.new(1, -22, 0.5, -10)
		})

		local tween2 = TweenService:Create(toggleButton, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(80, 70, 40)
		})

		local tween3 = TweenService:Create(glow, tweenInfo, { Color = Color3.fromRGB(255, 215, 0) })

		local tween4 = TweenService:Create(slider, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		})

		tween:Play()
		tween2:Play()
		tween3:Play()
		tween4:Play()
		stateText.Text = "⭐ Favorites"
		stateText.TextColor3 = Color3.fromRGB(255, 215, 0)
	else
		local tween = TweenService:Create(slider, tweenInfo, {
			Position = UDim2.new(0, 2, 0.5, -10)
		})

		local tween2 = TweenService:Create(toggleButton, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		})

		local tween3 = TweenService:Create(glow, tweenInfo, {
			Color = Color3.fromRGB(100, 100, 100)
		})

		local tween4 = TweenService:Create(slider, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(180, 180, 180)
		})

		tween:Play()
		tween2:Play()
		tween3:Play()
		tween4:Play()
		stateText.Text = "All"
		stateText.TextColor3 = Color3.fromRGB(150, 150, 150)
	end

	updateFilterDisplay()
end)

local function search2()
	local set3 = {}

	for k in textBox.Text:gmatch("%S+") do
		set3[k:lower()] = true
	end

	local v26 = {}

	for i = v18 + 1, #slots do
		local v27 = slots[i]
		table.insert(v26, { v27, (v27:CheckTerms(set3)) })
		v27.Frame.Visible = false
		v27.Frame.Parent = inventory
	end

	table.sort(v26, function(a, b): boolean
		return a[2] > b[2]
	end)

	flag = true
	local count = 0

	for _, v27 in ipairs(v26) do
		local v28 = v27[1]

		if not (v27[2] > 0) then
			continue
		end

		v28.Frame.Visible = true
		v28.Frame.Parent = uiGridFrame
		v28.Frame.LayoutOrder = v18 + count
		count += 1
	end

	scrollingFrame.CanvasPosition = Vector2.new(0, 0)
	UpdateScrollingFrameCanvasSize() -- inferred equivalent call
	x.ZIndex = 3
end

local function clearResults()
	if x.ZIndex > 0 then
		flag = false

		for i = v18 + 1, #slots do
			local v26 = slots[i]
			v26.Frame.LayoutOrder = v26.Index
			v26.Frame.Parent = uiGridFrame
			v26.Frame.Visible = true
		end

		x.ZIndex = 0
	end

	UpdateScrollingFrameCanvasSize() -- inferred equivalent call
end

local function reset() -- 2 equivalent calls inferred from this helper
	clearResults()
	textBox.Text = ""
end

local function onChanged(p: string)
	if p == "Text" then
		local text = textBox.Text

		if text == "" then
			textBox.TextTransparency = textStrokeTransparency
			clearResults()
		elseif text ~= "" then
			textBox.TextTransparency = 0
			search2()
		end

		x.Visible = text ~= "" and text ~= ""
	end
end

local function focusLost(flag3: boolean)
	if flag3 then
		search2()
	end
end

x.MouseButton1Click:Connect(reset)
textBox.Changed:Connect(onChanged)
textBox.FocusLost:Connect(focusLost)

Satchel.StateChanged.Event:Connect(function(flag3: boolean)
	if not flag3 then
		reset() -- inferred equivalent call
	end
end)

v11[Enum.KeyCode.Escape.Value] = function(p)
	if p then
		reset() -- inferred equivalent call
	end
end
local function detectGamepad(p)
	if p == Enum.UserInputType.Gamepad1 and not UserInputService.VREnabled then
		search.Visible = false
	else
		search.Visible = true
	end
end
UserInputService.LastInputTypeChanged:Connect(detectGamepad)

GuiService.MenuOpened:Connect(function()
	backpackGui.Enabled = false
	v3:setEnabled(false)
end)

GuiService.MenuClosed:Connect(function()
	backpackGui.Enabled = true
	v3:setEnabled(true)
end)

local function fn3(_: string, p, _)
	if not (p == Enum.UserInputState.Begin and GuiService.SelectedObject) then
		return
	end

	for i = 1, v18 do
		if slots[i].Frame == GuiService.SelectedObject and slots[i].Tool then
			slots[i]:MoveToInventory()
			break
		end
	end
end

local function openClose()
	if not next(v12) then
		inventory.Visible = not inventory.Visible
		local visible = inventory.Visible
		AdjustHotbarFrames()
		hotbar.Active = not hotbar.Active

		for i = 1, v18 do
			slots[i]:SetClickability(not visible)
		end
	end

	if inventory.Visible then
		if flag2 then
			if set2[UserInputService:GetLastInputType()] then
				resizeGamepadHintsFrame()
				gamepadHintsFrame.Visible = not UserInputService.VREnabled
			end

			enableGamepadInventoryControl()
		end
	else
		if flag2 then
			gamepadHintsFrame.Visible = false
		end

		disableGamepadInventoryControl()
	end

	if inventory.Visible then
		ContextActionService:BindAction("BackpackRemoveSlot", fn3, false, Enum.KeyCode.ButtonX)
	else
		ContextActionService:UnbindAction("BackpackRemoveSlot")
	end

	Satchel.IsOpen = inventory.Visible
	Satchel.StateChanged:Fire(inventory.Visible)
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
Satchel.OpenClose = openClose

while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end

task.spawn(function()
	task.wait(1)

	local success, result = pcall(function()
		return script.Parent.Parent.Parent.Parent:WaitForChild("BackpackFavorites", 5)
	end)

	if not (success and result) then
		warn("[ClientFavorites] BackpackFavorites folder not found in ReplicatedStorage - favorites will not persist")

		return
	end

	v22 = result
	saveFavorite = v22:FindFirstChild("SaveFavorite")
	requestFavorites = v22:FindFirstChild("RequestFavorites")

	if not requestFavorites then
		warn("[ClientFavorites] RequestFavorites RemoteFunction not found")
		return
	end

	local success2, result2 = pcall(function()
		return requestFavorites:InvokeServer()
	end)

	if not (success2 and result2) then
		warn("[ClientFavorites] Failed to load favorites from server:", result2)
		return
	end

	print("[ClientFavorites] Loaded favorites from server")

	for _, v26 in pairs(v10) do
		if not (v26.Tool and CanBeFavorited(v26.Tool)) then -- inferred equivalent call
			continue
		end

		local name = v26.Tool.Name

		local v27 = v26.Tool:GetAttribute("FavoriteID")

		if not v27 then
			v27 = HttpService:GenerateGUID(false)
			v26.Tool:SetAttribute("FavoriteID", v27)
		end

		for _, v28 in pairs(result2) do
			if v28.ToolName == name and v28.IsFavorited then
				v26.Tool:SetAttribute("IsFavorited", true)
				v26.Tool:SetAttribute("FavoritedTime", v28.FavoritedTime)

				v23[v27] = {
					ToolName = name,
					IsFavorited = true,
					FavoritedTime = v28.FavoritedTime
				}

				if v26.Frame and v26.Frame:FindFirstChild("FavoriteIcon") then
					v26.Frame.FavoriteIcon.Visible = true
				end

				break
			end
		end
	end

	SortInventorySlots()
end)

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

if LocalPlayer.Character then
	OnCharacterAdded(LocalPlayer.Character)
end

UserInputService.InputBegan:Connect(OnInputBegan)

UserInputService.TextBoxFocused:Connect(function()
	v17 = true
end)
UserInputService.TextBoxFocusReleased:Connect(function()
	v17 = false
end)

v11[value] = function()
	if v14 then
		UnequipAllTools() -- inferred equivalent call
	end
end

UserInputService.LastInputTypeChanged:Connect(OnUISChanged)
OnUISChanged()

if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
	gamepadConnected()
end

UserInputService.GamepadConnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadConnected()
	end
end)
UserInputService.GamepadDisconnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadDisconnected()
	end
end)

function Satchel.SetBackpackEnabled(_, flag3: boolean)
	v2 = flag3
end

function Satchel.IsOpened(_)
	return Satchel.IsOpen
end

function Satchel.IsBackpackEnabled(_)
	return v2
end

function Satchel.SetFavorite(_, tool, visible: boolean)
	if tool and tool:IsA("Tool") and CanBeFavorited(tool) then -- inferred equivalent call
		tool:SetAttribute("IsFavorited", visible)

		local v26 = v10[tool]

		if v26 and v26.Frame and v26.Frame:FindFirstChild("FavoriteIcon") then
			v26.Frame.FavoriteIcon.Visible = visible
		end
	end
end

function Satchel:IsFavorited(tool): boolean
	if tool and tool:IsA("Tool") and CanBeFavorited(tool) then -- inferred equivalent call
		return tool:GetAttribute("IsFavorited") == true
	end

	return false
end

function Satchel.GetFavoritedTools(_)
	local tools = {}

	if Backpack then
		for _, tool in pairs(Backpack:GetChildren()) do
			if not (tool:IsA("Tool") and CanBeFavorited(tool) and tool:GetAttribute("IsFavorited") == true) then -- inferred equivalent call
				continue
			end

			table.insert(tools, tool)
		end
	end

	if not v7 then
		return tools
	end

	for _, tool in pairs(v7:GetChildren()) do
		if not (tool:IsA("Tool") and CanBeFavorited(tool) and tool:GetAttribute("IsFavorited") == true) then -- inferred equivalent call
			continue
		end

		table.insert(tools, tool)
	end

	return tools
end

function Satchel.GetStateChangedEvent(_)
	return Satchel.StateChanged
end

RunService.Heartbeat:Connect(function()
	OnIconChanged(v2)
end)

local function OnPreferredTransparencyChanged()
	local preferredTransparency2 = GuiService.PreferredTransparency

	backgroundTransparency3 = backgroundTransparency * preferredTransparency2
	inventory.BackgroundTransparency = backgroundTransparency3

	backgroundTransparency4 = backgroundTransparency2 * preferredTransparency2

	for _, v26 in ipairs(slots) do
		v26.Frame.BackgroundTransparency = backgroundTransparency4
	end

	backgroundTransparency5 = preferredTransparency2 * 0.2
	search.BackgroundTransparency = backgroundTransparency5
end
GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(OnPreferredTransparencyChanged)

return Satchel