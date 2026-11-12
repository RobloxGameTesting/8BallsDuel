local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminController = require(ReplicatedStorage.Libraries.Modules.AdminController)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
local Players = game:GetService("Players")
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

AdminController.Init()

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)
local background = PlayerGui:WaitForChild("AdminUI").Background
local Assets = ReplicatedStorage.Assets
local content = background.Content
local header = background.Header
local exit = header.Exit
local back = header.Back
local label = header.Label
local commands = content.Commands
local options = content.Options
local Commands = Assets.InterfaceAssets.Admin.Commands
local Category = Assets.InterfaceAssets.Admin.Category
local Command = Assets.InterfaceAssets.Admin.Command
local Option = Assets.InterfaceAssets.Admin.Option
local label2 = options.Label
local textInput = options.TextInput
local messageBar = background.MessageBar
local textBox = header.SearchBar.TextBox
local v = {
	["0"] = "Free",
	["3477243200"] = "Admin+",
	["3477243291"] = "Troll",
	["3477243440"] = "Owner"
}

local v2 = { ["0"] = 1, ["3477243200"] = 20, ["3477243291"] = 40, ["3477243440"] = 60 }

local clones = {}
local count = 0
local v3 = nil
local values = {}
local bindableEvent = Instance.new("BindableEvent")
local buttons = Maid.new()

local function createButton(p: number, p2: string, p3)
	local clone = Option:Clone()
	local label = clone:FindFirstChild("Content"):FindFirstChild("Label")
	label.Text = `{p2}`
	clone.Parent = options

	Button.Create(clone, function()
		if not p3 then
			return
		end

		values[p] = p3
		bindableEvent:Fire()
	end)

	return clone
end

local function setOption(k: number?, option)
	buttons:Destroy()

	if not k then
		bindableEvent:Fire()
		return
	end

	print(option)

	if
		option.optionType == "PlayerList"
		or option.optionType == "List"
		or option.optionType == "PlayerListNoEveryone"
		or option.optionType == "MultiplePlayerList"
	then
		label2.Visible = true

		if option.optionType == "List" then
			label2.Text = option.header or "Select Option"

			for _, v4 in option.extra do
				buttons[v4] = createButton(k, v4, v4)
			end
		else
			label2.Text = option.header or "Select Player"

			if option.optionType == "PlayerList" then
				buttons.Everyone = createButton(k, "Everyone", "Everyone")
			end

			local userIds = {}

			if option.optionType == "MultiplePlayerList" then
				local button = createButton(k, "Confirm", nil)
				local uiGradient = button:FindFirstChild("Content"):FindFirstChild("Background"):FindFirstChild("UIGradient")
				uiGradient.Color = Rarities.GetRarityData("Tier2").colour
				button.LayoutOrder = 2147483647
				buttons.Confirm = button

				Button.Create(button, function()
					values[k] = userIds
					bindableEvent:Fire()
				end)
			end

			for _, v4 in Players:GetPlayers(), nil, nil do
				local userId2 = tostring(v4.UserId)
				local v5

				if not (option.optionType == "MultiplePlayerList" or not userId2) then
					v5 = userId2
				end

				local button = createButton(k, PlayerHelpers.GetName(v4), v5)
				local uiGradient = button:FindFirstChild("Content"):FindFirstChild("Background"):FindFirstChild("UIGradient")
				button.LayoutOrder = math.abs(v4.UserId)
				print("Created button yes ")

				if option.optionType == "MultiplePlayerList" then
					Button.Create(button, function()
						local index = table.find(userIds, userId2)

						if index then
							table.remove(userIds, index)
							uiGradient.Color = Rarities.GetRarityData("Option").colour
						else
							table.insert(userIds, userId2)
							uiGradient.Color = Rarities.GetRarityData("Tier3").colour
						end
					end)
				end

				buttons[userId2] = button
			end
		end
	elseif option.optionType == "TextBox" then
		label2.Visible = false
		textInput.Visible = true
		textInput.TextBox.Text = ""
		textInput.TextBox.PlaceholderText = "type here"

		Button.Create(textInput.Confirm, function()
			values[k] = textInput.TextBox.Text
			bindableEvent:Fire()
		end)

		function buttons.textBox()
			textInput.Visible = false
			Button.Destroy(textInput.Confirm)
		end
	elseif option.optionType == "UsernameTextBox" then
		label2.Visible = false
		textInput.Visible = true
		textInput.TextBox.Text = ""
		textInput.TextBox.PlaceholderText = "WARNING: UsernameTextBox isn't filtered"

		Button.Create(textInput.Confirm, function()
			local v4 = LocalPlayer.HasVerifiedBadge and utf8.char(57344)
			local v5

			if LocalPlayer.MembershipType == Enum.MembershipType.Premium then
				v5 = utf8.char(57345)
			else
				v5 = false
			end

			local formatted = `<font color="#{PlayerHelpers.GetChatColour(LocalPlayer.Name):ToHex()}">{LocalPlayer.DisplayName}{v4 or v5 or ""}:</font> {textInput.TextBox.Text}`

			values[k] = formatted
			bindableEvent:Fire()
		end)

		function buttons.textBox()
			textInput.Visible = false
			Button.Destroy(textInput.Confirm)
		end
	end

	bindableEvent.Event:Wait()
end

local function setCommand(p: string?)
	count += 1
	local v4 = count
	v3 = p
	values = {}
	buttons:Destroy()

	if v3 then
		if not AdminController.CanUse(userId, v3, nil) then
			warn("Can't use command")
			return
		end

		label.Text = `:{string.lower(v3)}`
		exit.Visible = false
		back.Visible = true
		commands.Visible = false
		options.Visible = true

		local v5 = AdminController.GetModules()[v3]

		for k, option in v5.options do
			if v4 ~= count then
				break
			end

			setOption(k, option)
		end

		if #values == #v5.options then
			AdminController.Request(userId, v3, values)
		end

		setCommand(nil)
	else
		buttons:Destroy()

		bindableEvent:Fire()

		label.Text = "ADMIN PANEL"
		commands.Visible = true
		options.Visible = false
		exit.Visible = true
		back.Visible = false
	end
end

local clones2 = {}

for k, v4 in AdminController.GetModules(), nil, nil do
	local clone = Command:Clone()
	local content2 = clone:FindFirstChild("Content")
	local icon = content2:FindFirstChild("Icon")
	local label3 = content2:FindFirstChild("Label")
	local price = content2:FindFirstChild("Price")
	local currencyIcon = content2:FindFirstChild("CurrencyIcon")

	clone.LayoutOrder = v4.layoutOrder or 1e999
	icon.Image = v4.icon
	label3.Text = `:{string.lower(v4.command)}`
	price.Visible = v4.cost ~= 0
	price.Text = `{v4.cost}`
	currencyIcon.Visible = v4.cost ~= 0

	local v5 = tostring(#v4.robuxIds == 0 and 0 or v4.robuxIds[1])

	if not clones[v5] then
		local clone2 = Category:Clone()
		local label4 = clone2:FindFirstChild("Content"):FindFirstChild("Label")
		clone2.LayoutOrder = v2[v5]
		label4.Text = v[v5]
		clone2.Parent = commands

		local clone3 = Commands:Clone()
		clone3.LayoutOrder = v2[v5] + 1
		clone3.Parent = commands

		clones[v5] = clone3
	end

	clones2[k] = clone
	clone.Parent = clones[v5]

	Button.Create(clone, function()
		setCommand(k)
	end)
end

UserInterfaceHelper:FitScrollingFrame(commands, "Y", UDim2.fromOffset(0, 10))
UserInterfaceHelper:FitScrollingFrame(options, "Y", UDim2.fromOffset(0, 10))

Button.Create(back, function()
	setCommand(nil)
end)

Menu.Opened:Connect(function(p)
	if p == "Admin" then
		setCommand(nil)
	end
end)

for _, frame in background.LeftPanel:GetChildren(), nil, nil do
	local name = tonumber(frame.Name)

	if frame:IsA("Frame") and frame:FindFirstChildWhichIsA("GuiButton") and name then
		Button.Create(frame, function()
			Sales.Prompt(userId, name, Enum.InfoType.Product)
		end)
	end
end

Button.Create(messageBar.Send, function()
	local v4 = LocalPlayer.HasVerifiedBadge and utf8.char(57344)
	local v5

	if LocalPlayer.MembershipType == Enum.MembershipType.Premium then
		v5 = utf8.char(57345)
	else
		v5 = false
	end

	local formatted = `<font color="#{PlayerHelpers.GetChatColour(LocalPlayer.Name):ToHex()}">{LocalPlayer.DisplayName}{v4 or v5 or ""}:</font> {messageBar.TextBox.Text}`
	messageBar.TextBox.Text = ""

	AdminController.Request(userId, "Global Message", { formatted })
end)

Scheduler.BindHeartbeat(function(_)
	for k, _ in AdminController.GetModules(), nil, nil do
		local isCooldown = AdminController.IsCooldown(userId, k)
		local cooldown = clones2[k]:FindFirstChild("Cooldown")

		cooldown.Visible = isCooldown
	end
end)

local function normalize(value: string) -- 3 equivalent calls inferred from this helper
	local v4 = string.lower(value)
	return (string.gsub(v4, "[%s%p]", ""))
end

local function isEditDistanceOne(value: string, value2: string): boolean
	local count2 = #value
	local count3 = #value2

	if math.abs(count2 - count3) > 1 then
		return false
	end

	local v4 = 1
	local v5 = 1
	local count4 = 0

	while v4 <= count2 and v5 <= count3 do
		if string.sub(value, v4, v4) == string.sub(value2, v5, v5) then
			v4 += 1
			v5 += 1
		else
			count4 += 1

			if count4 > 1 then
				return false
			end

			if count3 < count2 then
				v4 += 1
			else
				if not (count2 < count3) then
					v4 += 1
				end

				v5 += 1
			end
		end
	end

	return true
end

local result = {}

for _, moduleScript in AdminController.GetModuleScripts(), nil, nil do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local success, result2 = pcall(require, moduleScript)

	if not (success and type(result2) == "table" and type(result2.searchTerms) == "table") then
		continue
	end

	local v4 = {}
	local v5 = {}

	if type(result2.command) == "string" then
		v4[#v4 + 1] = string.lower(result2.command)
		local v6 = #v5 + 1
		v5[v6] = normalize(result2.command) -- inferred equivalent call
	end

	for _, searchTerm in ipairs(result2.searchTerms) do
		if type(searchTerm) ~= "string" then
			continue
		end

		v4[#v4 + 1] = string.lower(searchTerm)
		local v6 = #v5 + 1
		v5[v6] = normalize(searchTerm) -- inferred equivalent call
	end

	result[#result + 1] = {
		module = moduleScript,
		searchBlob = table.concat(v4, "\n"),
		normalizedBlob = table.concat(v5, "\n")
	}
end

local function search(text: string)
	local v4 = string.lower(text)
	local v5 = normalize(v4) -- inferred equivalent call

	if v5 == "" then
		return result
	end

	local v6 = {}

	for _, cmd in ipairs(result) do
		local score = 0

		if string.find(cmd.normalizedBlob, v5, 1, true) then
			score = 100
		elseif string.find(cmd.searchBlob, v4, 1, true) then
			score = 75
		elseif #v5 > 3 then
			for k in string.gmatch(cmd.normalizedBlob, "[^\n]+") do
				if isEditDistanceOne(v5, k) then
					score = 50
					break
				end
			end
		end

		if score > 0 then
			v6[#v6 + 1] = { cmd = cmd, score = score }
		end
	end

	table.sort(v6, function(a, b): boolean
		return a.score > b.score
	end)

	local cmds = {}

	for _, v7 in ipairs(v6) do
		cmds[#cmds + 1] = v7.cmd
	end

	return cmds
end

local function renderResults(items)
	for _, v4 in clones2 do
		v4.Visible = false
	end

	for _, item in items do
		clones2[item.module.Name].Visible = true
	end

	for k, _ in v do
		local count2 = 0

		for _, guiObject in clones[k]:GetChildren(), nil, nil do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				count2 += 1
			end
		end

		local uiAspectRatioConstraint = clones[k]:FindFirstChild("UIAspectRatioConstraint")
		uiAspectRatioConstraint.AspectRatio = 10 / math.ceil(count2 / 2)
	end
end

textBox:GetPropertyChangedSignal("Text"):Connect(function()
	renderResults(search(textBox.Text))
end)
renderResults(result)