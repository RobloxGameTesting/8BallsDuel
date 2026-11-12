game:GetService("LocalizationService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
game:GetService("LocalizationService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local script = script
local TopbarPlusReference = require(script.TopbarPlusReference)
local object = TopbarPlusReference.getObject()
local value = object and object.Value

if value and value ~= script then
	return require(value)
end

if not object then
	TopbarPlusReference.addToReplicatedStorage()
end

local Icon = {}
Icon.__index = Icon
local IconController = require(script.IconController)
local Signal = require(script.Signal)
local Maid = require(script.Maid)
local TopbarPlusGui = require(script.TopbarPlusGui)
local Themes = require(script.Themes)
local ActiveItems = TopbarPlusGui.ActiveItems
local TopbarContainer = TopbarPlusGui.TopbarContainer
local IconContainer = TopbarContainer.IconContainer
local new_ui = Themes.new_ui

local v = {}

function Icon.new()
	local class = {}
	setmetatable(class, Icon)

	local maid = Maid.new()
	class._maid = maid
	class._hoveringMaid = maid:give(Maid.new())
	class._dropdownClippingMaid = maid:give(Maid.new())
	class._menuClippingMaid = maid:give(Maid.new())

	local instances = {}
	class.instances = instances
	local iconContainer = maid:give(IconContainer:Clone())
	iconContainer.Visible = true
	iconContainer.Parent = TopbarContainer
	instances.iconContainer = iconContainer
	instances.iconButton = iconContainer.IconButton
	instances.iconImage = instances.iconButton.IconImage
	instances.iconLabel = instances.iconButton.IconLabel
	instances.fakeIconLabel = instances.iconButton.FakeIconLabel
	instances.iconGradient = instances.iconButton.IconGradient
	instances.iconCorner = instances.iconButton.IconCorner
	instances.iconOverlay = iconContainer.IconOverlay
	instances.iconOverlayCorner = instances.iconOverlay.IconOverlayCorner
	instances.noticeFrame = instances.iconButton.NoticeFrame
	instances.noticeLabel = instances.noticeFrame.NoticeLabel
	instances.captionContainer = iconContainer.CaptionContainer
	instances.captionFrame = instances.captionContainer.CaptionFrame
	instances.captionLabel = instances.captionContainer.CaptionLabel
	instances.captionCorner = instances.captionFrame.CaptionCorner
	instances.captionOverlineContainer = instances.captionContainer.CaptionOverlineContainer
	instances.captionOverline = instances.captionOverlineContainer.CaptionOverline
	instances.captionOverlineCorner = instances.captionOverline.CaptionOverlineCorner
	instances.captionVisibilityBlocker = instances.captionFrame.CaptionVisibilityBlocker
	instances.captionVisibilityCorner = instances.captionVisibilityBlocker.CaptionVisibilityCorner
	instances.tipFrame = iconContainer.TipFrame
	instances.tipLabel = instances.tipFrame.TipLabel
	instances.tipCorner = instances.tipFrame.TipCorner
	instances.dropdownContainer = iconContainer.DropdownContainer
	instances.dropdownFrame = instances.dropdownContainer.DropdownFrame
	instances.dropdownList = instances.dropdownFrame.DropdownList
	instances.menuContainer = iconContainer.MenuContainer
	instances.menuFrame = instances.menuContainer.MenuFrame
	instances.menuList = instances.menuFrame.MenuList
	instances.clickSound = iconContainer.ClickSound

	class._settings = {
		action = {
			toggleTransitionInfo = {},
			resizeInfo = {},
			repositionInfo = {},
			captionFadeInfo = {},
			tipFadeInfo = {},
			dropdownSlideInfo = {},
			menuSlideInfo = {}
		},
		toggleable = {
			iconBackgroundColor = {
				instanceNames = { "iconButton" },
				propertyName = "BackgroundColor3"
			},
			iconBackgroundTransparency = {
				instanceNames = { "iconButton" },
				propertyName = "BackgroundTransparency"
			},
			iconCornerRadius = {
				instanceNames = { "iconCorner", "iconOverlayCorner" },
				propertyName = "CornerRadius"
			},
			iconGradientColor = {
				instanceNames = { "iconGradient" },
				propertyName = "Color"
			},
			iconGradientRotation = {
				instanceNames = { "iconGradient" },
				propertyName = "Rotation"
			},
			iconImage = {
				callMethods = { class._updateIconSize },
				instanceNames = { "iconImage" },
				propertyName = "Image"
			},
			iconImageColor = {
				instanceNames = { "iconImage" },
				propertyName = "ImageColor3"
			},
			iconImageTransparency = {
				instanceNames = { "iconImage" },
				propertyName = "ImageTransparency"
			},
			iconScale = {
				instanceNames = { "iconButton" },
				propertyName = "Size"
			},
			forcedIconSizeX = {},
			forcedIconSizeY = {},
			iconSize = {
				callSignals = { class.updated },
				callMethods = { class._updateIconSize },
				instanceNames = { "iconContainer" },
				propertyName = "Size",
				tweenAction = "resizeInfo"
			},
			iconOffset = {
				instanceNames = { "iconButton" },
				propertyName = "Position"
			},
			iconText = {
				callMethods = { class._updateIconSize },
				instanceNames = { "iconLabel" },
				propertyName = "Text"
			},
			iconTextColor = {
				instanceNames = { "iconLabel" },
				propertyName = "TextColor3"
			},
			iconFont = {
				callMethods = { class._updateIconSize },
				instanceNames = { "iconLabel" },
				propertyName = "Font"
			},
			iconImageYScale = {
				callMethods = { class._updateIconSize }
			},
			iconImageRatio = {
				callMethods = { class._updateIconSize }
			},
			iconLabelYScale = {
				callMethods = { class._updateIconSize }
			},
			noticeCircleColor = {
				instanceNames = { "noticeFrame" },
				propertyName = "ImageColor3"
			},
			noticeCircleImage = {
				instanceNames = { "noticeFrame" },
				propertyName = "Image"
			},
			noticeTextColor = {
				instanceNames = { "noticeLabel" },
				propertyName = "TextColor3"
			},
			noticeImageTransparency = {
				instanceNames = { "noticeFrame" },
				propertyName = "ImageTransparency"
			},
			noticeTextTransparency = {
				instanceNames = { "noticeLabel" },
				propertyName = "TextTransparency"
			},
			baseZIndex = {
				callMethods = { class._updateBaseZIndex }
			},
			order = {
				callSignals = { class.updated },
				instanceNames = { "iconContainer" },
				propertyName = "LayoutOrder"
			},
			alignment = {
				callSignals = { class.updated },
				callMethods = { class._updateDropdown }
			},
			iconImageVisible = {
				instanceNames = { "iconImage" },
				propertyName = "Visible"
			},
			iconImageAnchorPoint = {
				instanceNames = { "iconImage" },
				propertyName = "AnchorPoint"
			},
			iconImagePosition = {
				instanceNames = { "iconImage" },
				propertyName = "Position",
				tweenAction = "resizeInfo"
			},
			iconImageSize = {
				instanceNames = { "iconImage" },
				propertyName = "Size",
				tweenAction = "resizeInfo"
			},
			iconImageTextXAlignment = {
				instanceNames = { "iconImage" },
				propertyName = "TextXAlignment"
			},
			iconLabelVisible = {
				instanceNames = { "iconLabel" },
				propertyName = "Visible"
			},
			iconLabelAnchorPoint = {
				instanceNames = { "iconLabel" },
				propertyName = "AnchorPoint"
			},
			iconLabelPosition = {
				instanceNames = { "iconLabel" },
				propertyName = "Position",
				tweenAction = "resizeInfo"
			},
			iconLabelSize = {
				instanceNames = { "iconLabel" },
				propertyName = "Size",
				tweenAction = "resizeInfo"
			},
			iconLabelTextXAlignment = {
				instanceNames = { "iconLabel" },
				propertyName = "TextXAlignment"
			},
			iconLabelTextSize = {
				instanceNames = { "iconLabel" },
				propertyName = "TextSize"
			},
			noticeFramePosition = {
				instanceNames = { "noticeFrame" },
				propertyName = "Position"
			},
			clickSoundId = {
				instanceNames = { "clickSound" },
				propertyName = "SoundId"
			},
			clickVolume = {
				instanceNames = { "clickSound" },
				propertyName = "Volume"
			},
			clickPlaybackSpeed = {
				instanceNames = { "clickSound" },
				propertyName = "PlaybackSpeed"
			},
			clickTimePosition = {
				instanceNames = { "clickSound" },
				propertyName = "TimePosition"
			}
		},
		other = {
			captionBackgroundColor = {
				instanceNames = { "captionFrame" },
				propertyName = "BackgroundColor3"
			},
			captionBackgroundTransparency = {
				instanceNames = { "captionFrame" },
				propertyName = "BackgroundTransparency",
				group = "caption"
			},
			captionBlockerTransparency = {
				instanceNames = { "captionVisibilityBlocker" },
				propertyName = "BackgroundTransparency",
				group = "caption"
			},
			captionOverlineColor = {
				instanceNames = { "captionOverline" },
				propertyName = "BackgroundColor3"
			},
			captionOverlineTransparency = {
				instanceNames = { "captionOverline" },
				propertyName = "BackgroundTransparency",
				group = "caption"
			},
			captionTextColor = {
				instanceNames = { "captionLabel" },
				propertyName = "TextColor3"
			},
			captionTextTransparency = {
				instanceNames = { "captionLabel" },
				propertyName = "TextTransparency",
				group = "caption"
			},
			captionFont = {
				instanceNames = { "captionLabel" },
				propertyName = "Font"
			},
			captionCornerRadius = {
				instanceNames = { "captionCorner", "captionOverlineCorner", "captionVisibilityCorner" },
				propertyName = "CornerRadius"
			},
			tipBackgroundColor = {
				instanceNames = { "tipFrame" },
				propertyName = "BackgroundColor3"
			},
			tipBackgroundTransparency = {
				instanceNames = { "tipFrame" },
				propertyName = "BackgroundTransparency",
				group = "tip"
			},
			tipTextColor = {
				instanceNames = { "tipLabel" },
				propertyName = "TextColor3"
			},
			tipTextTransparency = {
				instanceNames = { "tipLabel" },
				propertyName = "TextTransparency",
				group = "tip"
			},
			tipFont = {
				instanceNames = { "tipLabel" },
				propertyName = "Font"
			},
			tipCornerRadius = {
				instanceNames = { "tipCorner" },
				propertyName = "CornerRadius"
			},
			dropdownSize = {
				instanceNames = { "dropdownContainer" },
				propertyName = "Size",
				unique = "dropdown"
			},
			dropdownCanvasSize = {
				instanceNames = { "dropdownFrame" },
				propertyName = "CanvasSize"
			},
			dropdownMaxIconsBeforeScroll = {
				callMethods = { class._updateDropdown }
			},
			dropdownMinWidth = {
				callMethods = { class._updateDropdown }
			},
			dropdownSquareCorners = {
				callMethods = { class._updateDropdown }
			},
			dropdownBindToggleToIcon = {},
			dropdownToggleOnLongPress = {},
			dropdownToggleOnRightClick = {},
			dropdownCloseOnTapAway = {},
			dropdownHidePlayerlistOnOverlap = {},
			dropdownListPadding = {
				callMethods = { class._updateDropdown },
				instanceNames = { "dropdownList" },
				propertyName = "Padding"
			},
			dropdownAlignment = {
				callMethods = { class._updateDropdown }
			},
			dropdownScrollBarColor = {
				instanceNames = { "dropdownFrame" },
				propertyName = "ScrollBarImageColor3"
			},
			dropdownScrollBarTransparency = {
				instanceNames = { "dropdownFrame" },
				propertyName = "ScrollBarImageTransparency"
			},
			dropdownScrollBarThickness = {
				instanceNames = { "dropdownFrame" },
				propertyName = "ScrollBarThickness"
			},
			dropdownIgnoreClipping = {
				callMethods = { class._dropdownIgnoreClipping }
			},
			menuSize = {
				instanceNames = { "menuContainer" },
				propertyName = "Size",
				unique = "menu"
			},
			menuCanvasSize = {
				instanceNames = { "menuFrame" },
				propertyName = "CanvasSize"
			},
			menuMaxIconsBeforeScroll = {
				callMethods = { class._updateMenu }
			},
			menuBindToggleToIcon = {},
			menuToggleOnLongPress = {},
			menuToggleOnRightClick = {},
			menuCloseOnTapAway = {},
			menuListPadding = {
				callMethods = { class._updateMenu },
				instanceNames = { "menuList" },
				propertyName = "Padding"
			},
			menuDirection = {
				callMethods = { class._updateMenu }
			},
			menuScrollBarColor = {
				instanceNames = { "menuFrame" },
				propertyName = "ScrollBarImageColor3"
			},
			menuScrollBarTransparency = {
				instanceNames = { "menuFrame" },
				propertyName = "ScrollBarImageTransparency"
			},
			menuScrollBarThickness = {
				instanceNames = { "menuFrame" },
				propertyName = "ScrollBarThickness"
			},
			menuIgnoreClipping = {
				callMethods = { class._menuIgnoreClipping }
			}
		}
	}

	class._groupSettings = {}

	for _, setting in pairs(class._settings) do
		for k, v2 in pairs(setting) do
			local group = v2.group

			if not group then
				continue
			end

			local v3 = class._groupSettings[group]

			if not v3 then
				v3 = {}
				class._groupSettings[group] = v3
			end

			table.insert(v3, k)
			v2.forcedGroupValue = v[group]
			v2.useForcedGroupValue = true
		end
	end

	class._settingsDictionary = {}

	class._uniqueSettings = {}
	class._uniqueSettingsDictionary = {}
	class.uniqueValues = {}
	local v2 = {
		dropdown = function(_, instance, p, p2)
			local dropdownSlideInfo = class:get("dropdownSlideInfo")
			local dropdownBindToggleToIcon = class:get("dropdownBindToggleToIcon")
			local v2

			if class:get("dropdownHidePlayerlistOnOverlap") == true then
				v2 = class:get("alignment") == "right"
			else
				v2 = false
			end

			local _dropdownContainer = class.instances.dropdownContainer
			local dropdownFrame = class.instances.dropdownFrame

			local v3 = true
			local v4 = not class.isSelected

			if dropdownBindToggleToIcon == false then
				v4 = not class.dropdownOpen
			end

			local longPressing = class._longPressing or class._rightClicking

			if class._tappingAway or v4 and not longPressing or longPressing and class.dropdownOpen then
				local dropdownSize = class:get("dropdownSize")
				local v5 = dropdownSize and dropdownSize.X.Offset / 1 or 0
				p2 = UDim2.new(0, v5, 0, 0)
				v3 = false
			end

			if #class.dropdownIcons > 0 and v3 and v2 then
				if StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
					IconController._bringBackPlayerlist = IconController._bringBackPlayerlist
						and IconController._bringBackPlayerlist + 1
						or 1
					class._bringBackPlayerlist = true
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				end
			elseif class._bringBackPlayerlist and not v3 and IconController._bringBackPlayerlist then
				IconController._bringBackPlayerlist -= 1

				if IconController._bringBackPlayerlist <= 0 then
					IconController._bringBackPlayerlist = nil
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				end

				class._bringBackPlayerlist = nil
			end

			local tween = TweenService:Create(instance, dropdownSlideInfo, { [p] = p2 })
			local completedConnection = nil
			completedConnection = tween.Completed:Connect(function()
				completedConnection:Disconnect()
			end)
			tween:Play()

			if not v3 then
				class._dropdownCanvasPos = dropdownFrame.CanvasPosition
			end

			dropdownFrame.ScrollingEnabled = v3
			class.dropdownOpen = v3
			class:_decideToCallSignal("dropdown")
		end,
		menu = function(_, instance, p, p2)
			local v2 = class:get("menuSlideInfo")
			local menuBindToggleToIcon = class:get("menuBindToggleToIcon")
			local _menuContainer = class.instances.menuContainer
			local menuFrame = class.instances.menuFrame

			local flag = true
			local v3 = not class.isSelected

			if menuBindToggleToIcon == false then
				v3 = not class.menuOpen
			end

			local longPressing = class._longPressing or class._rightClicking

			if class._tappingAway or v3 and not longPressing or longPressing and class.menuOpen then
				local menuSize = class:get("menuSize")
				local v4 = menuSize and menuSize.Y.Offset / 1 or 0
				p2 = UDim2.new(0, 0, 0, v4)
				flag = false
			end

			if flag ~= class.menuOpen then
				class.updated:Fire()
			end

			if flag and v2.EasingDirection == Enum.EasingDirection.Out then
				v2 = TweenInfo.new(v2.Time, v2.EasingStyle, Enum.EasingDirection.In)
			end

			local tween = TweenService:Create(instance, v2, { [p] = p2 })
			local completedConnection = nil
			completedConnection = tween.Completed:Connect(function()
				completedConnection:Disconnect()
			end)
			tween:Play()

			if flag then
				if class._menuCanvasPos then
					menuFrame.CanvasPosition = class._menuCanvasPos
				end
			else
				class._menuCanvasPos = menuFrame.CanvasPosition
			end

			menuFrame.ScrollingEnabled = flag
			class.menuOpen = flag
			class:_decideToCallSignal("menu")
		end
	}

	for k, setting in pairs(class._settings) do
		for k2, v3 in pairs(setting) do
			if k == "toggleable" then
				v3.values = v3.values or { deselected = nil, selected = nil }
			else
				v3.value = nil
			end

			v3.additionalValues = {}
			v3.type = k
			class._settingsDictionary[k2] = v3

			local unique = v3.unique

			if not unique then
				continue
			end

			local v4 = class._uniqueSettings[unique] or {}
			table.insert(v4, k2)
			class._uniqueSettings[unique] = v4
			class._uniqueSettingsDictionary[k2] = v2[unique]
		end
	end

	class.updated = maid:give(Signal.new())
	class.selected = maid:give(Signal.new())
	class.deselected = maid:give(Signal.new())
	class.toggled = maid:give(Signal.new())
	class.userSelected = maid:give(Signal.new())
	class.userDeselected = maid:give(Signal.new())
	class.userToggled = maid:give(Signal.new())
	class.hoverStarted = maid:give(Signal.new())
	class.hoverEnded = maid:give(Signal.new())
	class.dropdownOpened = maid:give(Signal.new())
	class.dropdownClosed = maid:give(Signal.new())
	class.menuOpened = maid:give(Signal.new())
	class.menuClosed = maid:give(Signal.new())
	class.notified = maid:give(Signal.new())
	class._endNotices = maid:give(Signal.new())
	class._ignoreClippingChanged = maid:give(Signal.new())

	local function setFeatureChange(p, p2) -- 2 equivalent calls inferred from this helper
		local parentIcon = class._parentIcon
		class:set(p .. "IgnoreClipping", p2)

		if p2 == true and parentIcon then
			local connection = parentIcon._ignoreClippingChanged:Connect(function(_, p3)
				class:set(p .. "IgnoreClipping", p3)
			end)
			local connection2 = nil
			connection2 = class[p .. "Closed"]:Connect(function()
				connection2:Disconnect()
				connection:Disconnect()
			end)
		end
	end
	class.dropdownOpened:Connect(function()
		setFeatureChange("dropdown", true)
	end)
	class.dropdownClosed:Connect(function()
		setFeatureChange("dropdown", false) -- inferred equivalent call
	end)
	class.menuOpened:Connect(function()
		setFeatureChange("menu", true)
	end)
	class.menuClosed:Connect(function()
		setFeatureChange("menu", false) -- inferred equivalent call
	end)

	class.deselectWhenOtherIconSelected = true
	class.name = ""
	class.isSelected = false
	class.presentOnTopbar = true
	class.accountForWhenDisabled = false
	class.enabled = true
	class.hovering = false
	class.tipText = nil
	class.captionText = nil
	class.totalNotices = 0
	class.notices = {}
	class.dropdownIcons = {}
	class.menuIcons = {}
	class.dropdownOpen = false
	class.menuOpen = false
	class.locked = false
	class.topPadding = UDim.new(0.5, 0)
	class.targetPosition = nil
	class.toggleItems = {}
	class.lockedSettings = {}
	class.UID = HttpService:GenerateGUID(true)
	class.blockBackBehaviourChecks = {}

	class._draggingFinger = false
	class._updatingIconSize = true
	class._previousDropdownOpen = false
	class._previousMenuOpen = false
	class._bindedToggleKeys = {}
	class._bindedEvents = {}

	class:setName("UnnamedIcon")
	class:setTheme(new_ui, true)

	instances.iconButton.MouseButton1Click:Connect(function()
		if class.locked then
			return
		end

		if class.isSelected then
			class:deselect()
			class.userDeselected:Fire()
			class.userToggled:Fire(false)
			return true
		end

		class:select()
		class.userSelected:Fire()
		class.userToggled:Fire(true)
	end)
	instances.iconButton.MouseButton2Click:Connect(function()
		class._rightClicking = true

		if class:get("dropdownToggleOnRightClick") == true then
			class:_update("dropdownSize")
		end

		if class:get("menuToggleOnRightClick") == true then
			class:_update("menuSize")
		end

		class._rightClicking = false
	end)

	instances.iconButton.MouseButton1Down:Connect(function()
		if class.locked then
			return
		end

		class:_updateStateOverlay(0.7, Color3.new(0, 0, 0))
	end)
	instances.iconButton.MouseButton1Up:Connect(function()
		if class.overlayLocked then
			return
		end

		class:_updateStateOverlay(0.9, Color3.new(1, 1, 1))
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local set = {
			[Enum.UserInputType.MouseButton1] = true,
			[Enum.UserInputType.MouseButton2] = true,
			[Enum.UserInputType.MouseButton3] = true,
			[Enum.UserInputType.Touch] = true
		}

		if not gameProcessed and set[input.UserInputType] then
			class._tappingAway = true

			if class.dropdownOpen and class:get("dropdownCloseOnTapAway") == true then
				class:_update("dropdownSize")
			end

			if class.menuOpen and class:get("menuCloseOnTapAway") == true then
				class:_update("menuSize")
			end

			class._tappingAway = false
		end

		if class._bindedToggleKeys[input.KeyCode] and not (gameProcessed or class.locked) then
			if class.isSelected then
				class:deselect()
				class.userDeselected:Fire()
				class.userToggled:Fire(false)
			else
				class:select()
				class.userSelected:Fire()
				class.userToggled:Fire(true)
			end
		end
	end)

	class.hoverStarted:Connect(function(_, _)
		class.hovering = true

		if not class.locked then
			class:_updateStateOverlay(0.9, Color3.fromRGB(255, 255, 255))
		end

		class:_updateHovering()
	end)
	class.hoverEnded:Connect(function()
		class.hovering = false
		class:_updateStateOverlay(1)
		class._hoveringMaid:clean()
		class:_updateHovering()
	end)
	instances.iconButton.MouseEnter:Connect(function(p, p2)
		class.hoverStarted:Fire(p, p2)
	end)
	instances.iconButton.MouseLeave:Connect(function()
		class.hoverEnded:Fire()
	end)
	instances.iconButton.SelectionGained:Connect(function()
		class.hoverStarted:Fire()
	end)
	instances.iconButton.SelectionLost:Connect(function()
		class.hoverEnded:Fire()
	end)
	instances.iconButton.MouseButton1Down:Connect(function()
		if class._draggingFinger then
			class.hoverStarted:Fire()
		end

		local heartbeatConnection = nil
		local mouseButton1UpConnection = nil

		local v3 = tick() + 0.7
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if v3 <= tick() then
				mouseButton1UpConnection:Disconnect()
				heartbeatConnection:Disconnect()
				class._longPressing = true

				if class:get("dropdownToggleOnLongPress") == true then
					class:_update("dropdownSize")
				end

				if class:get("menuToggleOnLongPress") == true then
					class:_update("menuSize")
				end

				class._longPressing = false
			end
		end)
		mouseButton1UpConnection = instances.iconButton.MouseButton1Up:Connect(function()
			mouseButton1UpConnection:Disconnect()
			heartbeatConnection:Disconnect()
		end)
	end)

	if UserInputService.TouchEnabled then
		instances.iconButton.MouseButton1Up:Connect(function()
			if class.hovering then
				class.hoverEnded:Fire()
			end
		end)

		UserInputService.TouchMoved:Connect(function(_, p)
			if p then
				return
			end

			class._draggingFinger = true
		end)
		UserInputService.TouchEnded:Connect(function()
			class._draggingFinger = false
		end)
	end

	class._updatingIconSize = false
	class:_updateIconSize()
	IconController.iconAdded:Fire(class)

	return class
end

function Icon.mimic(p)
	local v2 = p .. "Mimic"
	local icon = IconController.getIcon(v2)

	if icon then
		return icon
	end

	local v3 = Icon.new()
	v3:setName(v2)

	if p ~= "Chat" then
		return v3
	end

	v3:setOrder(-1)
	v3:setImage("rbxasset://textures/ui/TopBar/chatOff.png", "deselected")
	v3:setImage("rbxasset://textures/ui/TopBar/chatOn.png", "selected")
	v3:setImageYScale(0.625)

	return v3
end

function Icon:set(p, hoveringValue, value2, value3)
	local v2 = self._settingsDictionary[p]
	assert(v2 ~= nil, ("setting '%s' does not exist"):format(p))

	if type(value2) == "string" then
		value2 = value2:lower()
	end

	local previous = self:get(p, value2)

	if value2 == "hovering" then
		v2.hoveringValue = hoveringValue

		if value3 ~= "_ignorePrevious" then
			v2.additionalValues["previous_" .. "hovering"] = previous
		end

		if type(value3) == "string" then
			v2.additionalValues[value3 .. "_" .. "hovering"] = previous
		end

		self:_update(p)
	else
		local v3

		if v2.type == "toggleable" then
			local v4 = {}

			if value2 == "deselected" or value2 == "selected" then
				table.insert(v4, value2)
				v3 = value2
			else
				table.insert(v4, "deselected")
				table.insert(v4, "selected")
			end

			for _, v5 in pairs(v4) do
				v2.values[v5] = hoveringValue

				if value3 ~= "_ignorePrevious" then
					v2.additionalValues["previous_" .. v5] = previous
				end

				if type(value3) == "string" then
					v2.additionalValues[value3 .. "_" .. v5] = previous
				end
			end
		else
			v2.value = hoveringValue

			if type(value3) == "string" then
				if value3 ~= "_ignorePrevious" then
					v2.additionalValues.previous = previous
				end

				v2.additionalValues[value3] = previous
			end

			v3 = value2
		end

		if previous == hoveringValue then
			return self, "Value was already set"
		end

		local toggleState = self:getToggleState()

		if not self._updateAfterSettingAll and v2.instanceNames and (toggleState == v3 or v3 == nil) then
			local v4 = p == "iconSize" and previous and previous.X.Scale == 1
			self:_update(p, toggleState, v2.tweenAction and not v4 and self:get(v2.tweenAction) or TweenInfo.new(0))
		end
	end

	if v2.callMethods then
		for _, callMethod in pairs(v2.callMethods) do
			callMethod(self, hoveringValue, value2)
		end
	end

	if v2.callSignals then
		for _, callSignal in pairs(v2.callSignals) do
			callSignal:Fire()
		end
	end

	return self
end

function Icon:setAdditionalValue(p, p2, p3, p4)
	local v2 = self._settingsDictionary[p]
	assert(v2 ~= nil, ("setting '%s' does not exist"):format(p))
	local v3 = p2 .. "_"

	if p4 then
		v3 ..= p4
	end

	for k, _ in pairs(v2.additionalValues) do
		if string.match(k, v3) then
			v2.additionalValues[k] = p3
		end
	end
end

function Icon:get(p, value2, value3)
	local v2 = self._settingsDictionary[p]
	assert(v2 ~= nil, ("setting '%s' does not exist"):format(p))
	local v3 = nil
	local v4 = nil

	if typeof(value2) == "string" then
		value2 = value2:lower()
	end

	if value2 == "hovering" and value3 == nil then
		v3 = v2.hoveringValue

		if (type)(nil) == "string" then
			v4 = v2.additionalValues[nil .. "_" .. "hovering"]
		else
			v4 = false
		end
	end

	if v2.type == "toggleable" then
		local v5 = (value2 == "deselected" or value2 == "selected") and value2 or self:getToggleState()

		if v4 == nil then
			if type(value3) == "string" then
				v4 = v2.additionalValues[value3 .. "_" .. v5]
			else
				v4 = false
			end
		end

		if v3 == nil then
			return v2.values[v5], v4
		end

		return v3, v4
	end

	if v4 == nil then
		if type(value3) == "string" then
			v4 = v2.additionalValues[value3]
		else
			v4 = false
		end
	end

	if v3 == nil then
		v3 = v2.value
	end

	return v3, v4
end

function Icon:getHovering(p)
	local v2 = self._settingsDictionary[p]
	assert(v2 ~= nil, ("setting '%s' does not exist"):format(p))
	return v2.hoveringValue
end

function Icon:getToggleState(p): string
	return if p or self.isSelected then "selected" else "deselected"
end

function Icon:getIconState()
	if self.hovering then
		return "hovering"
	end

	return self:getToggleState()
end

function Icon:_update(p, p2, p3)
	local v2 = self._settingsDictionary[p]
	assert(v2 ~= nil, ("setting '%s' does not exist"):format(p))
	local v3 = p2 or self:getToggleState()
	local v4 = v2.value or v2.values and v2.values[v3]

	if self.hovering and v2.hoveringValue then
		v4 = v2.hoveringValue
	end

	if v4 == nil then
		return
	end

	local v5 = p3
		or v2.tweenAction and v2.tweenAction ~= "" and self:get(v2.tweenAction)
		or self:get("toggleTransitionInfo")
		or TweenInfo.new(0.15)
	local propertyName = v2.propertyName
	local v6 = {
		string = true,
		NumberSequence = true,
		Text = true,
		EnumItem = true,
		ColorSequence = true
	}

	local v7 = self._uniqueSettingsDictionary[p]
	local v8

	if v2.useForcedGroupValue then
		v8 = v2.forcedGroupValue
	else
		v8 = v4
	end

	if v2.instanceNames then
		for _, instanceName in pairs(v2.instanceNames) do
			local instance = self.instances[instanceName]
			local v9 = v6[typeof(instance[propertyName])] or typeof(instance) == "table"

			if v7 then
				v7(p, instance, propertyName, v8)
			elseif v9 then
				instance[propertyName] = v4
			else
				TweenService:Create(instance, v5, { [propertyName] = v8 }):Play()
			end

			if p == "iconSize" and instance[propertyName] ~= v8 then
				self.updated:Fire()
			end
		end
	end
end

function Icon:_updateAll(p, p2)
	for k, v2 in pairs(self._settingsDictionary) do
		if v2.instanceNames then
			self:_update(k, p, p2)
		end
	end

	self:_updateIconSize()
	self:_updateCaptionSize()
	self:_updateTipSize()
end

function Icon:_updateHovering(p)
	for k, v2 in pairs(self._settingsDictionary) do
		if v2.instanceNames and v2.hoveringValue ~= nil then
			self:_update(k, nil, p)
		end
	end
end

function Icon:_updateStateOverlay(value2, p)
	local iconOverlay = self.instances.iconOverlay
	iconOverlay.BackgroundTransparency = value2 or 1
	iconOverlay.BackgroundColor3 = p or Color3.new(1, 1, 1)
end

function Icon:setTheme(items, updateAfterSettingAll)
	self._updateAfterSettingAll = updateAfterSettingAll

	for k, item in pairs(items) do
		if k == "toggleable" then
			for k2, v2 in pairs(item.deselected) do
				if not self.lockedSettings[k2] then
					self:set(k2, v2, "both")
				end
			end

			for k2, v2 in pairs(item.selected) do
				if not self.lockedSettings[k2] then
					self:set(k2, v2, "selected")
				end
			end
		else
			for k2, v2 in pairs(item) do
				if self.lockedSettings[k2] then
					continue
				end

				local v3 = self._settingsDictionary[k2]

				if k == "action" and v3 == nil then
					self._settingsDictionary[k2] = {}
				end

				self:set(k2, v2)
			end
		end
	end

	self._updateAfterSettingAll = nil

	if updateAfterSettingAll then
		self:_updateAll()
	end

	return self
end

function Icon:getInstance(p)
	return self.instances[p]
end

function Icon:setInstance(p, p2)
	local instance = self.instances[p]
	self.instances[p] = p2

	if instance then
		instance:Destroy()
	end

	return self
end

function Icon:getSettingDetail(p)
	for _, setting in pairs(self._settings) do
		for k, v2 in pairs(setting) do
			if k == p then
				return v2
			end
		end
	end

	return false
end

function Icon:modifySetting(p, items)
	local settingDetail = self:getSettingDetail(p)

	for k, item in pairs(items) do
		settingDetail[k] = item
	end

	return self
end

function Icon:convertLabelToNumberSpinner(p)
	self:set("iconLabelSize", UDim2.new(1, 0, 1, 0))
	p.Parent = self:getInstance("iconButton")

	local v2 = {}
	setmetatable(v2, {
		__newindex = function(_, p2, p3)
			for _, label in pairs(p.Frame:GetDescendants()) do
				if label:IsA("TextLabel") then
					label[p2] = p3
				end
			end
		end
	})

	local instance = self:getInstance("iconButton")
	instance.ZIndex = 0
	self:setInstance("iconLabel", v2)
	self:modifySetting("iconText", { instanceNames = {} })
	self:setInstance("iconLabelSpinner", p.Frame)

	for _, v3 in pairs({
		"iconLabelVisible",
		"iconLabelAnchorPoint",
		"iconLabelPosition",
		"iconLabelSize"
	}) do
		self:modifySetting(v3, {
			instanceNames = { "iconLabelSpinner" }
		})
	end

	self:_updateAll()
	return self
end

function Icon:setEnabled(p)
	self.enabled = p
	self.instances.iconContainer.Visible = p
	self.updated:Fire()
	return self
end

function Icon:setName(name)
	self.name = name
	self.instances.iconContainer.Name = name
	return self
end

function Icon:setProperty(p, p2)
	self[p] = p2
	return self
end

function Icon:_playClickSound()
	local clickSound = self.instances.clickSound

	if clickSound.SoundId ~= nil and #clickSound.SoundId > 0 and clickSound.Volume > 0 then
		local clone = clickSound:Clone()
		clone.Parent = clickSound.Parent
		clone:Play()
		Debris:AddItem(clone, clickSound.TimeLength)
	end
end

function Icon:select(p)
	self.isSelected = true
	self:_setToggleItemsVisible(true, p)
	self:_updateNotice()
	self:_updateAll()
	self:_playClickSound()

	if #self.dropdownIcons > 0 or #self.menuIcons > 0 then
		IconController:_updateSelectionGroup()
	end

	if UserInputService.GamepadEnabled then
		for _, list in pairs(self.toggleItems) do
			if not (#list > 0) then
				continue
			end

			local v2 = Maid.new()
			GuiService:AddSelectionTuple(self.UID, unpack(list))
			GuiService.SelectedObject = list[1]
			IconController.activeButtonBCallbacks += 1
			v2:give(UserInputService.InputEnded:Connect(function(input, _)
				local v3 = false

				for _, blockBackBehaviourCheck in pairs(self.blockBackBehaviourChecks) do
					if blockBackBehaviourCheck() == true then
						v3 = true
						break
					end
				end

				if input.KeyCode == Enum.KeyCode.ButtonB and not v3 then
					GuiService.SelectedObject = self.instances.iconButton
					self:deselect()
				end
			end))
			v2:give(self.deselected:Connect(function()
				v2:clean()
			end))
			v2:give(function()
				IconController.activeButtonBCallbacks -= 1

				if IconController.activeButtonBCallbacks < 0 then
					IconController.activeButtonBCallbacks = 0
				end
			end)
		end
	end

	self.selected:Fire()
	self.toggled:Fire(self.isSelected)
	return self
end

function Icon:deselect(p)
	self.isSelected = false
	self:_setToggleItemsVisible(false, p)
	self:_updateNotice()
	self:_updateAll()
	self:_playClickSound()

	if #self.dropdownIcons > 0 or #self.menuIcons > 0 then
		IconController:_updateSelectionGroup()
	end

	self.deselected:Fire()
	self.toggled:Fire(self.isSelected)

	if UserInputService.GamepadEnabled then
		GuiService:RemoveSelectionGroup(self.UID)
	end

	return self
end

function Icon:notify(object2, p)
	coroutine.wrap(function()
		if not object2 then
			object2 = self.deselected
		end

		if self._parentIcon then
			self._parentIcon:notify(object2)
		end

		local connection = Signal.new()
		local connection2 = self._endNotices:Connect(function()
			connection:Fire()
		end)
		local connection3 = object2:Connect(function()
			connection:Fire()
		end)

		p = p or HttpService:GenerateGUID(true)
		self.notices[p] = { completeSignal = connection, clearNoticeEvent = object2 }

		self.totalNotices += 1
		self:_updateNotice()

		self.notified:Fire(p)
		connection:Wait()

		connection2:Disconnect()
		connection3:Disconnect()
		connection:Disconnect()

		self.totalNotices -= 1
		self.notices[p] = nil
		self:_updateNotice()
	end)()
	return self
end

function Icon:_updateNotice()
	local v2 = not (self.totalNotices < 1)

	v2 = not self.isSelected and (#self.dropdownIcons > 0 or #self.menuIcons > 0) and self.totalNotices > 0 or v2

	if self.isSelected and (#self.dropdownIcons > 0 or #self.menuIcons > 0) then
		v2 = false
	end

	local v3 = v2 and 0 or 1
	self:set("noticeImageTransparency", v3)
	self:set("noticeTextTransparency", v3)
	self.instances.noticeLabel.Text = self.totalNotices < 100 and self.totalNotices or "99+"
end

function Icon:clearNotices()
	self._endNotices:Fire()
	return self
end

function Icon.disableStateOverlay(p, p2)
	local v2 = p2 == nil or p2

	p.instances.iconOverlay.Visible = not v2
	return p
end

function Icon:setLabel(value2, p)
	self:set("iconText", value2 or "", p)
	return self
end

function Icon:setCornerRadius(p, p2, p3)
	local cornerRadius = self.instances.iconCorner.CornerRadius
	self:set("iconCornerRadius", UDim.new(p or cornerRadius.Scale, p2 or cornerRadius.Offset), p3)
	return self
end

function Icon:setImage(value2, p)
	return self:set("iconImage", tonumber(value2) and "http://www.roblox.com/asset/?id=" .. value2 or value2 or "", p)
end

function Icon:setOrder(p, p2)
	return self:set("order", tonumber(p) or 1, p2)
end

function Icon:setLeft(p)
	return self:set("alignment", "left", p)
end

function Icon:setMid(p)
	return self:set("alignment", "mid", p)
end

function Icon:setRight(p)
	if not self.internalIcon then
		IconController.setupHealthbar()
	end

	return self:set("alignment", "right", p)
end

function Icon:setImageYScale(p, p2)
	return self:set("iconImageYScale", tonumber(p) or 0.63, p2)
end

function Icon:setImageRatio(p, p2)
	return self:set("iconImageRatio", tonumber(p) or 1, p2)
end

function Icon:setLabelYScale(p, p2)
	return self:set("iconLabelYScale", tonumber(p) or 0.45, p2)
end

function Icon:setBaseZIndex(p, p2)
	return self:set("baseZIndex", tonumber(p) or 1, p2)
end

function Icon._updateBaseZIndex(p, p2): boolean | string
	local iconContainer = p.instances.iconContainer
	local v2 = (tonumber(p2) or iconContainer.ZIndex) - iconContainer.ZIndex

	if v2 == 0 then
		return "The baseValue is the same"
	end

	for _, guiObject in pairs(p.instances) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += v2
		end
	end

	return true
end

function Icon:setSize(p, p2, p3)
	if tonumber(p) then
		self.forcefullyAppliedXSize = true
		self:set("forcedIconSizeX", tonumber(p), p3)
	else
		self.forcefullyAppliedXSize = false
		self:set("forcedIconSizeX", 32, p3)
	end

	if tonumber(p2) then
		self.forcefullyAppliedYSize = true
		self:set("forcedIconSizeY", tonumber(p2), p3)
	else
		self.forcefullyAppliedYSize = false
		self:set("forcedIconSizeY", 32, p3)
	end

	local v2 = tonumber(p) or 32
	local v3 = tonumber(p2) or (p2 == "_NIL" or not v2) and 32 or v2
	self:set("iconSize", UDim2.new(0, v2, 0, v3), p3)
	return self
end

function Icon:setXSize(p, p2)
	self:setSize(p, "_NIL", p2)
	return self
end

function Icon:setYSize(p, p2)
	self:setSize("_NIL", p, p2)
	return self
end

function Icon:_getContentText(text)
	self.instances.fakeIconLabel.Text = text
	local contentText = self.instances.fakeIconLabel.ContentText
	local contentText2

	if typeof(self.instances.iconLabel) == "Instance" then
		contentText2 = IconController.translator:Translate(self.instances.iconLabel, contentText)
	else
		contentText2 = false
	end

	if typeof(contentText2) ~= "string" or contentText2 == "" then
		contentText2 = contentText
	end

	self.instances.fakeIconLabel.Text = ""
	return contentText2
end

function Icon:_updateIconSize(_, p)
	if self._destroyed then
		return
	end

	local v2 = {
		iconImage = self:get("iconImage", p) or "_NIL",
		iconText = self:get("iconText", p) or "_NIL",
		iconFont = self:get("iconFont", p) or "_NIL",
		iconSize = self:get("iconSize", p) or "_NIL",
		forcedIconSizeX = self:get("forcedIconSizeX", p) or "_NIL",
		iconImageYScale = self:get("iconImageYScale", p) or "_NIL",
		iconImageRatio = self:get("iconImageRatio", p) or "_NIL",
		iconLabelYScale = self:get("iconLabelYScale", p) or "_NIL"
	}

	for _, v3 in pairs(v2) do
		if v3 == "_NIL" then
			return
		end
	end

	local iconContainer = self.instances.iconContainer

	if not iconContainer.Parent then
		return
	end

	local offset = v2.iconSize.X.Offset
	local scale = v2.iconSize.X.Scale
	local v3 = offset + scale * iconContainer.Parent.AbsoluteSize.X
	local forcedIconSizeX = v2.forcedIconSizeX
	local v4 = scale > 0 and v3 or self.forcefullyAppliedXSize and forcedIconSizeX or 9999
	local v5 = v2.iconSize.Y.Offset + v2.iconSize.Y.Scale * iconContainer.Parent.AbsoluteSize.Y
	local v6 = v5 * v2.iconLabelYScale
	local x = TextService:GetTextSize(self:_getContentText(v2.iconText), v6, v2.iconFont, Vector2.new(10000, v6)).X
	local v7 = v5 * v2.iconImageYScale * v2.iconImageRatio

	local v8 = v2.iconImage ~= ""
	local v9 = v2.iconText ~= ""
	local v10 = 0.5
	local v11 = nil
	local v12 = v6 / 2

	if v8 and not v9 then
		self:set("iconImageVisible", true, p)
		self:set("iconImageAnchorPoint", Vector2.new(0.5, 0.5), p)
		self:set("iconImagePosition", UDim2.new(0.5, 0, 0.5, 0), p)
		self:set("iconImageSize", UDim2.new(v2.iconImageYScale * v2.iconImageRatio, 0, v2.iconImageYScale, 0), p)
		self:set("iconLabelVisible", false, p)
		v11 = 0
		v10 = 0.45
	elseif v8 or not v9 then
		if v8 and v9 then
			local v13 = 12 + v7 + 8
			v11 = v13 + x + 12
			self:set("iconImageVisible", true, p)
			self:set("iconImageAnchorPoint", Vector2.new(0, 0.5), p)
			self:set("iconImagePosition", UDim2.new(0, 12, 0.5, 0), p)
			self:set("iconImageSize", UDim2.new(0, v7, v2.iconImageYScale, 0), p)

			self:set("iconLabelVisible", true, p)
			self:set("iconLabelAnchorPoint", Vector2.new(0, 0.5), p)
			self:set("iconLabelPosition", UDim2.new(0, v13, 0.5, 0), p)
			self:set("iconLabelSize", UDim2.new(1, -v13 - 12, v2.iconLabelYScale, v12), p)
			self:set("iconLabelTextXAlignment", Enum.TextXAlignment.Left, p)
		end
	else
		v11 = x + 24
		self:set("iconLabelVisible", true, p)
		self:set("iconLabelAnchorPoint", Vector2.new(0, 0.5), p)
		self:set("iconLabelPosition", UDim2.new(0, 12, 0.5, 0), p)
		self:set("iconLabelSize", UDim2.new(1, -24, v2.iconLabelYScale, v12), p)
		self:set("iconLabelTextXAlignment", Enum.TextXAlignment.Center, p)
		self:set("iconImageVisible", false, p)
	end

	if v11 and not self._updatingIconSize then
		self._updatingIconSize = true
		local v13 = scale > 0 and scale or 0
		local v14 = scale > 0 and 0 or math.clamp(v11, forcedIconSizeX, v4)
		self:set("iconSize", UDim2.new(v13, v14, v2.iconSize.Y.Scale, v2.iconSize.Y.Offset), p, "_ignorePrevious")

		local parentIcon = self._parentIcon

		if parentIcon then
			local udim = UDim2.new(0, v11, 0, v2.iconSize.Y.Offset)

			if #parentIcon.dropdownIcons > 0 then
				self:setAdditionalValue("iconSize", "beforeDropdown", udim, p)
				parentIcon:_updateDropdown()
			end

			if #parentIcon.menuIcons > 0 then
				self:setAdditionalValue("iconSize", "beforeMenu", udim, p)
				parentIcon:_updateMenu()
			end
		end

		self._updatingIconSize = false
	end

	self:set("iconLabelTextSize", v6, p)
	self:set("noticeFramePosition", UDim2.new(v10, 0, 0, -2), p)

	self._updatingIconSize = false
end

function Icon:bindEvent(p, callback)
	local v2 = self[p]
	local v3

	if v2 then
		v3 = typeof(v2) == "table" and v2.Connect
	else
		v3 = v2
	end

	assert(v3, "argument[1] must be a valid topbarplus icon event name!")
	assert(typeof(callback) == "function", "argument[2] must be a function!")
	self._bindedEvents[p] = v2:Connect(function(...)
		callback(self, ...)
	end)
	return self
end

function Icon:unbindEvent(p)
	local bindedEvent = self._bindedEvents[p]

	if bindedEvent then
		bindedEvent:Disconnect()
		self._bindedEvents[p] = nil
	end

	return self
end

function Icon:bindToggleKey(p)
	assert(typeof(p) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self._bindedToggleKeys[p] = true
	return self
end

function Icon:unbindToggleKey(p)
	assert(typeof(p) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self._bindedToggleKeys[p] = nil
	return self
end

function Icon:lock()
	self.instances.iconButton.Active = false
	self.locked = true
	task.defer(function()
		if self.locked then
			self.overlayLocked = true
		end
	end)
	return self
end

function Icon:unlock()
	self.instances.iconButton.Active = true
	self.locked = false
	self.overlayLocked = false
	return self
end

function Icon:debounce(duration)
	self:lock()
	task.wait(duration)
	self:unlock()
	return self
end

function Icon:autoDeselect(p)
	self.deselectWhenOtherIconSelected = p == nil or p
	return self
end

function Icon:setTopPadding(value2, value3)
	self.topPadding = UDim.new(value3 or 0.5, value2 or 0)
	self.updated:Fire()
	return self
end

function Icon:bindToggleItem(instance)
	if not (instance:IsA("GuiObject") or instance:IsA("LayerCollector")) then
		error("Toggle item must be a GuiObject or LayerCollector!")
	end

	self.toggleItems[instance] = true
	self:updateSelectionInstances()
	return self
end

function Icon:updateSelectionInstances()
	for folder, _ in pairs(self.toggleItems) do
		local buttons = {}

		for _, button in pairs(folder:GetDescendants()) do
			if not ((button:IsA("TextButton") or button:IsA("ImageButton")) and button.Active) then
				continue
			end

			table.insert(buttons, button)
		end

		self.toggleItems[folder] = buttons
	end
end

function Icon.addBackBlocker(p, p2)
	table.insert(p.blockBackBehaviourChecks, p2)
	return p
end

function Icon.unbindToggleItem(p, p2)
	p.toggleItems[p2] = nil
	return p
end

function Icon:_setToggleItemsVisible(p, p2)
	for layerCollector, _ in pairs(self.toggleItems) do
		if not p2 or p2.toggleItems[layerCollector] == nil then
			layerCollector[layerCollector:IsA("LayerCollector") and "Enabled" or "Visible"] = p
		end
	end
end

function Icon.call(p, callback)
	task.spawn(callback, p)
	return p
end

function Icon:give(callback)
	local v2

	if typeof(callback) == "function" then
		v2 = callback(self)

		if typeof(callback) == "function" then
			v2 = nil
		end
	else
		v2 = callback
	end

	if v2 ~= nil then
		self._maid:give(v2)
	end

	return self
end

v.tip = 1

function Icon:setTip(tipText)
	assert(typeof(tipText) == "string" or tipText == nil, "Expected string, got " .. typeof(tipText))
	local text = tipText or ""
	local v2 = text ~= ""
	self.tipText = tipText
	self.instances.tipLabel.Text = text
	self.instances.tipFrame.Parent = v2 and ActiveItems or self.instances.iconContainer
	self._maid.tipFrame = self.instances.tipFrame
	self:_updateTipSize()

	local tipMaid = Maid.new()
	self._maid.tipMaid = tipMaid

	if v2 then
		tipMaid:give(self.hoverStarted:Connect(function()
			if not self.isSelected then
				self:displayTip(true)
			end
		end))
		tipMaid:give(self.hoverEnded:Connect(function()
			self:displayTip(false)
		end))
		tipMaid:give(self.selected:Connect(function()
			if self.hovering then
				self:displayTip(false)
			end
		end))
	end

	self:displayTip(self.hovering and v2)
	return self
end

function Icon:_updateTipSize()
	local tipText = self.tipText or ""
	local v2 = tipText ~= ""
	local textSize = TextService:GetTextSize(
		self:_getContentText(tipText),
		12,
		Enum.Font.GothamSemibold,
		Vector2.new(1000, 14)
	)
	self.instances.tipFrame.Size = v2 and UDim2.new(0, textSize.X + 6, 0, 20) or UDim2.new(0, 0, 0, 0)
end

function Icon:displayTip(p)
	if UserInputService.TouchEnabled and not self._draggingFinger then
		return
	end

	local tipVisible = self.tipVisible or false

	if typeof(p) == "boolean" then
		tipVisible = p
	end

	self.tipVisible = tipVisible

	local tipFrame = self.instances.tipFrame

	if tipVisible then
		local function updateTipPositon(x, y)
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize
			local v2, v3

			if UserInputService.TouchEnabled then
				local v4 = x - tipFrame.Size.X.Offset / 2

				local v5 = viewportSize.X - tipFrame.Size.X.Offset
				local v6 = y + 55 + 60
				local v7 = tipFrame.AbsoluteSize.Y + 55 + 64 + 3
				local v8 = viewportSize.Y - tipFrame.Size.Y.Offset
				v2 = math.clamp(v4, 0, v5)
				v3 = math.clamp(v6, v7, v8)
			elseif IconController.controllerModeEnabled then
				local indicator = TopbarPlusGui.Indicator
				local absolutePosition = indicator.AbsolutePosition
				v2 = absolutePosition.X - tipFrame.Size.X.Offset / 2 + indicator.AbsoluteSize.X / 2
				v3 = absolutePosition.Y + 90
			else
				local v4 = viewportSize.X - tipFrame.Size.X.Offset - 48

				local v5 = tipFrame.Size.Y.Offset + 3
				local y2 = viewportSize.Y
				v2 = math.clamp(x, 0, v4)
				v3 = math.clamp(y, v5, y2)
			end

			tipFrame.Position = UDim2.new(0, v2, 0, v3 - 20)
		end
		local mouseLocation = UserInputService:GetMouseLocation()

		if mouseLocation then
			updateTipPositon(mouseLocation.X, mouseLocation.Y)
		end

		self._hoveringMaid:give(self.instances.iconButton.MouseMoved:Connect(updateTipPositon))
	end

	for _, v2 in pairs(self._groupSettings.tip) do
		self._settingsDictionary[v2].useForcedGroupValue = not tipVisible
		self:_update(v2)
	end
end

v.caption = 1

function Icon:setCaption(captionText)
	assert(typeof(captionText) == "string" or captionText == nil, "Expected string, got " .. typeof(captionText))
	local text = captionText or ""
	local v2 = text ~= ""
	self.captionText = captionText
	self.instances.captionLabel.Text = text
	self.instances.captionContainer.Parent = v2 and ActiveItems or self.instances.iconContainer
	self._maid.captionContainer = self.instances.captionContainer
	self:_updateIconSize(nil, self:getIconState())
	local captionMaid = Maid.new()
	self._maid.captionMaid = captionMaid

	if v2 then
		captionMaid:give(self.hoverStarted:Connect(function()
			if not self.isSelected then
				self:displayCaption(true)
			end
		end))
		captionMaid:give(self.hoverEnded:Connect(function()
			self:displayCaption(false)
		end))
		captionMaid:give(self.selected:Connect(function()
			if self.hovering then
				self:displayCaption(false)
			end
		end))
		local iconContainer = self.instances.iconContainer
		captionMaid:give(iconContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if self.hovering then
				self:displayCaption()
			end
		end))
		captionMaid:give(iconContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if self.hovering then
				self:displayCaption()
			end
		end))
	end

	self:_updateCaptionSize()
	self:displayCaption(self.hovering and v2)
	return self
end

function Icon:_updateCaptionSize()
	local iconSize = self:get("iconSize")
	local captionFont = self:get("captionFont")

	if iconSize and captionFont then
		local offset = iconSize.Y.Offset
		local scale = iconSize.Y.Scale
		local iconContainer = self.instances.iconContainer
		local captionContainer = self.instances.captionContainer

		if (self.captionText or "") ~= "" then
			local v2 = offset + scale * iconContainer.Parent.AbsoluteSize.Y
			local captionLabel = self.instances.captionLabel
			local textSize = v2 * 0.8 * 0.58
			local x = TextService:GetTextSize(
				self:_getContentText(self.captionText),
				textSize,
				captionFont,
				Vector2.new(10000, textSize)
			).X
			captionLabel.TextSize = textSize
			captionLabel.Size = UDim2.new(0, x, 0.58, 0)
			captionContainer.Size = UDim2.new(0, x + 12, 0, v2 * 0.8)
		else
			captionContainer.Size = UDim2.new(0, 0, 0, 0)
		end
	end
end

function Icon:displayCaption(p)
	if UserInputService.TouchEnabled and not self._draggingFinger then
		return
	end

	local total = 8

	if self._draggingFinger then
		total += 55
	end

	local iconContainer = self.instances.iconContainer
	local captionContainer = self.instances.captionContainer
	captionContainer.Position = UDim2.new(
		0,
		iconContainer.AbsolutePosition.X + iconContainer.AbsoluteSize.X / 2 - captionContainer.AbsoluteSize.X / 2,
		0,
		iconContainer.AbsolutePosition.Y + iconContainer.AbsoluteSize.Y * 2 + total
	)

	local captionVisible = self.captionVisible or false

	if typeof(p) == "boolean" then
		captionVisible = p
	end

	self.captionVisible = captionVisible

	self:get("captionFadeInfo")

	for _, v2 in pairs(self._groupSettings.caption) do
		self._settingsDictionary[v2].useForcedGroupValue = not captionVisible
		self:_update(v2)
	end
end

function Icon:join(parentIcon, joinedFeatureName, p)
	if self._parentIcon then
		self:leave()
	end

	local v2 = joinedFeatureName and joinedFeatureName:lower() or "dropdown"
	local v3 = "before" .. joinedFeatureName:sub(1, 1):upper() .. joinedFeatureName:sub(2)
	local instance = parentIcon.instances[joinedFeatureName .. "Frame"]
	self.presentOnTopbar = false
	self.joinedFeatureName = joinedFeatureName
	self._parentIcon = parentIcon
	self.instances.iconContainer.Parent = instance

	for k, notice in pairs(self.notices) do
		parentIcon:notify(notice.clearNoticeEvent, k)
	end

	if joinedFeatureName == "dropdown" then
		local dropdownSquareCorners = parentIcon:get("dropdownSquareCorners")
		self:set("iconSize", UDim2.new(1, 0, 0, self:get("iconSize", "deselected").Y.Offset), "deselected", v3)
		self:set("iconSize", UDim2.new(1, 0, 0, self:get("iconSize", "selected").Y.Offset), "selected", v3)

		if dropdownSquareCorners then
			self:set("iconCornerRadius", UDim.new(0, 0), "deselected", v3)
			self:set("iconCornerRadius", UDim.new(0, 0), "selected", v3)
		end

		self:set("captionBlockerTransparency", 0.4, nil, v3)
	end

	table.insert(parentIcon[v2 .. "Icons"], self)

	if not p then
		if joinedFeatureName == "dropdown" then
			parentIcon:_updateDropdown()
		elseif joinedFeatureName == "menu" then
			parentIcon:_updateMenu()
		end
	end

	parentIcon.deselectWhenOtherIconSelected = false

	IconController:_updateSelectionGroup()
	self:_decideToCallSignal("dropdown")
	self:_decideToCallSignal("menu")

	return self
end

function Icon:leave()
	if self._destroyed or self.instances.iconContainer.Parent == nil then
		return
	end

	local v2 = { "iconSize", "captionBlockerTransparency", "iconCornerRadius" }
	local parentIcon = self._parentIcon
	self.instances.iconContainer.Parent = TopbarContainer
	self.presentOnTopbar = true
	self.joinedFeatureName = nil
	local function scanFeature(list, p, callback)
		for k, item in pairs(list) do
			if item == self then
				for _, v3 in pairs(v2) do
					for _, v4 in pairs({ "deselected", "selected" }) do
						local _, v5 = self:get(v3, v4, p)

						if v5 then
							self:set(v3, v5, v4)
						end
					end
				end

				table.remove(list, k)
				callback(parentIcon)

				if #list ~= 0 then
					break
				end

				self._parentIcon.deselectWhenOtherIconSelected = true
				break
			end
		end
	end
	scanFeature(parentIcon.dropdownIcons, "beforeDropdown", parentIcon._updateDropdown)
	scanFeature(parentIcon.menuIcons, "beforeMenu", parentIcon._updateMenu)

	for k, _ in pairs(self.notices) do
		local notice = parentIcon.notices[k]

		if notice then
			notice.completeSignal:Fire()
		end
	end

	self._parentIcon = nil

	IconController:_updateSelectionGroup()
	self:_decideToCallSignal("dropdown")
	self:_decideToCallSignal("menu")

	return self
end

function Icon:_decideToCallSignal(value2)
	local v2 = self[value2 .. "Open"]
	local v3 = "_previous" .. string.sub(value2, 1, 1):upper() .. value2:sub(2) .. "Open"
	local v4 = self[v3]
	local count = #self[value2 .. "Icons"]

	if v2 and count > 0 and v4 == false then
		self[v3] = true
		self[value2 .. "Opened"]:Fire()
	elseif (not v2 or count == 0) and v4 == true then
		self[v3] = false
		self[value2 .. "Closed"]:Fire()
	end
end

function Icon:_ignoreClipping(p)
	local v2 = self:get(p .. "IgnoreClipping")

	if self._parentIcon then
		local v3 = self["_" .. p .. "ClippingMaid"]
		local instance = self.instances[p .. "Container"]
		v3:clean()

		if v2 then
			local frame = Instance.new("Frame")
			frame.Name = instance.Name .. "FakeFrame"
			frame.ClipsDescendants = true
			frame.BackgroundTransparency = 1
			frame.Size = instance.Size
			frame.Position = instance.Position
			frame.Parent = ActiveItems

			for _, child in pairs(instance:GetChildren()) do
				child.Parent = frame
			end

			local function updateSize() -- 2 equivalent calls inferred from this helper
				local absoluteSize = instance.AbsoluteSize
				frame.Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y)
			end
			v3:give(instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				updateSize() -- inferred equivalent call
			end))
			updateSize() -- inferred equivalent call

			local function updatePos() -- 2 equivalent calls inferred from this helper
				local absolutePosition = instance.absolutePosition
				frame.Position = UDim2.new(0, absolutePosition.X, 0, absolutePosition.Y + 36)
			end
			v3:give(instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				updatePos() -- inferred equivalent call
			end))
			updatePos() -- inferred equivalent call
			v3:give(function()
				for _, child in pairs(frame:GetChildren()) do
					child.Parent = instance
				end

				frame.Name = "Destroying..."
				frame:Destroy()
			end)
		end
	end

	self._ignoreClippingChanged:Fire(p, v2)
end

function Icon:setDropdown(items)
	for _, dropdownIcon in pairs(self.dropdownIcons) do
		dropdownIcon:leave()
	end

	if type(items) == "table" then
		for _, item in pairs(items) do
			item:join(self, "dropdown", true)
		end
	end

	self:_updateDropdown()
	return self
end

function Icon:_updateDropdown()
	local v2 = {
		maxIconsBeforeScroll = self:get("dropdownMaxIconsBeforeScroll") or "_NIL",
		minWidth = self:get("dropdownMinWidth") or "_NIL",
		padding = self:get("dropdownListPadding") or "_NIL",
		dropdownAlignment = self:get("dropdownAlignment") or "_NIL",
		iconAlignment = self:get("alignment") or "_NIL",
		scrollBarThickness = self:get("dropdownScrollBarThickness") or "_NIL"
	}

	for _, v3 in pairs(v2) do
		if v3 == "_NIL" then
			return
		end
	end

	local offset = v2.padding.Offset
	local dropdownContainer = self.instances.dropdownContainer
	local dropdownFrame = self.instances.dropdownFrame
	local _dropdownList = self.instances.dropdownList
	local count = #self.dropdownIcons
	local v3

	if v2.maxIconsBeforeScroll < count then
		v3 = v2.maxIconsBeforeScroll or count
	else
		v3 = count
	end

	local v4 = -offset

	local v5 = v2.minWidth
	table.sort(self.dropdownIcons, function(a, b): boolean
		return a:get("order") < b:get("order")
	end)
	local total = 0

	for i = 1, count do
		local dropdownIcon = self.dropdownIcons[i]
		local _, v6 = dropdownIcon:get("iconSize", nil, "beforeDropdown")
		local v7 = v6.Y.Offset + offset

		if i <= v3 then
			total += v7
		end

		if i == count then
			total += v7 / 4
		end

		v4 += v7
		local offset2 = v6.X.Offset

		if v5 < offset2 then
			v5 = offset2
		end

		local v8 = i == 1 and self or self.dropdownIcons[i - 1]
		local dropdownIcon2 = self.dropdownIcons[i + 1]
		dropdownIcon.instances.iconButton.NextSelectionUp = v8 and v8.instances.iconButton
		dropdownIcon.instances.iconButton.NextSelectionDown = dropdownIcon2 and dropdownIcon2.instances.iconButton
	end

	local v6 = v3 == count and 0 or v4
	self:set("dropdownCanvasSize", UDim2.new(0, 0, 0, v6))
	self:set("dropdownSize", UDim2.new(0, (v5 + 4) * 2, 0, total))

	local dropdownAlignment = v2.dropdownAlignment:lower()
	local v7 = {
		left = { AnchorPoint = Vector2.new(0, 0), PositionXScale = 0, ThicknessMultiplier = 0 },
		mid = { AnchorPoint = Vector2.new(0.5, 0), PositionXScale = 0.5, ThicknessMultiplier = 0.5 },
		right = {
			AnchorPoint = Vector2.new(0.5, 0),
			PositionXScale = 1,
			FrameAnchorPoint = Vector2.new(0, 0),
			FramePositionXScale = 0,
			ThicknessMultiplier = 1
		}
	}

	local v8 = v7[dropdownAlignment] or v7[v2.iconAlignment:lower()]

	dropdownContainer.AnchorPoint = v8.AnchorPoint
	dropdownContainer.Position = UDim2.new(v8.PositionXScale, 0, 1, offset + 0)
	local v9 = v2.scrollBarThickness * v8.ThicknessMultiplier
	local v10 = dropdownFrame.VerticalScrollBarPosition == Enum.VerticalScrollBarPosition.Right and v9 or -v9
	dropdownFrame.AnchorPoint = v8.FrameAnchorPoint or v8.AnchorPoint
	dropdownFrame.Position = UDim2.new(v8.FramePositionXScale or v8.PositionXScale, v10, 0, 0)
	self._dropdownCanvasPos = Vector2.new(0, 0)
end

function Icon:_dropdownIgnoreClipping()
	self:_ignoreClipping("dropdown")
end

function Icon:setMenu(items)
	for _, menuIcon in pairs(self.menuIcons) do
		menuIcon:leave()
	end

	if type(items) == "table" then
		for _, item in pairs(items) do
			item:join(self, "menu", true)
		end
	end

	self:_updateMenu()
	return self
end

function Icon:_getMenuDirection()
	local menuDirection = (self:get("menuDirection") or "_NIL"):lower()
	local alignment = (self:get("alignment") or "_NIL"):lower()

	return menuDirection ~= "left" and menuDirection ~= "right" and (alignment == "left" and "right" or "left")
		or menuDirection
end

function Icon:_updateMenu()
	local v2 = {
		maxIconsBeforeScroll = self:get("menuMaxIconsBeforeScroll") or "_NIL",
		direction = self:get("menuDirection") or "_NIL",
		iconAlignment = self:get("alignment") or "_NIL",
		scrollBarThickness = self:get("menuScrollBarThickness") or "_NIL"
	}

	for _, v3 in pairs(v2) do
		if v3 == "_NIL" then
			return
		end
	end

	local v3 = IconController[v2.iconAlignment .. "Gap"]
	local menuContainer = self.instances.menuContainer
	local menuFrame = self.instances.menuFrame
	local menuList = self.instances.menuList
	local count = #self.menuIcons

	local menuDirection = self:_getMenuDirection()
	local v4

	if v2.maxIconsBeforeScroll < count then
		v4 = v2.maxIconsBeforeScroll or count
	else
		v4 = count
	end

	local v5 = -v3
	local v6 = 0
	local v7 = 0
	local v8

	local function fn(object2, object3): boolean
		return object2:get("order") > object3:get("order")
	end

	if menuDirection == "right" then
		v8 = function(object2, object3): boolean
			return object2:get("order") < object3:get("order")
		end or fn
	else
		v8 = fn
	end

	table.sort(self.menuIcons, v8)

	for i = 1, count do
		local menuIcon = self.menuIcons[i]
		local iconSize = menuIcon:get("iconSize")
		local v9 = iconSize.X.Offset + v3

		if i <= v4 then
			v6 += v9
		end

		if i == v4 and i ~= count then
			v6 -= 2
		end

		v5 += v9
		local offset = iconSize.Y.Offset

		if v7 < offset then
			v7 = offset
		end

		local menuIcon2 = self.menuIcons[i - 1]
		local menuIcon3 = self.menuIcons[i + 1]
		menuIcon.instances.iconButton.NextSelectionRight = menuIcon2 and menuIcon2.instances.iconButton
		menuIcon.instances.iconButton.NextSelectionLeft = menuIcon3 and menuIcon3.instances.iconButton
	end

	local v9 = v4 == count and 0 or v5 + v3
	self:set("menuCanvasSize", UDim2.new(0, v9, 0, 0))
	self:set("menuSize", UDim2.new(0, v6, 0, v7 + v2.scrollBarThickness + 3))

	local v10 = ({
		left = {
			containerAnchorPoint = Vector2.new(1, 0),
			containerPosition = UDim2.new(0, -4, 0, 0),
			canvasPosition = Vector2.new(v9, 0)
		},
		right = {
			containerAnchorPoint = Vector2.new(0, 0),
			containerPosition = UDim2.new(1, v3 - 2, 0, 0),
			canvasPosition = Vector2.new(0, 0)
		}
	})[menuDirection]
	menuContainer.AnchorPoint = v10.containerAnchorPoint
	menuContainer.Position = v10.containerPosition
	menuFrame.CanvasPosition = v10.canvasPosition
	self._menuCanvasPos = v10.canvasPosition

	menuList.Padding = UDim.new(0, v3)
end

function Icon:_menuIgnoreClipping()
	self:_ignoreClipping("menu")
end

function Icon:destroy()
	if self._destroyed then
		return
	end

	IconController.iconRemoved:Fire(self)
	self:clearNotices()

	if self._parentIcon then
		self:leave()
	end

	self:setDropdown()
	self:setMenu()
	self._destroyed = true
	self._maid:clean()
end
Icon.Destroy = Icon.destroy

return Icon