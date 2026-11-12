local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolTrickshotTypes = require(Pool.PoolTrickshotTypes)
local PoolTrickshotCodes = require(Pool.PoolTrickshotCodes)
local PoolTrickshotStyle = require(Pool.PoolTrickshotStyle)

local PoolTrickshotSaves = {}

local Panel = PoolTrickshotStyle.Panel
Color3.fromRGB(52, 60, 70)
local Border = PoolTrickshotStyle.Border
local Text = PoolTrickshotStyle.Text
Color3.fromRGB(160, 172, 186)
Color3.fromRGB(120, 220, 255)
local Go = PoolTrickshotStyle.Go
local Danger = PoolTrickshotStyle.Danger

local NormaliseZ = PoolTrickshotStyle.NormaliseZ

local function corner(parent, p: number)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = parent
end

local function stroke(parent, color: Color3, thickness: number)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = thickness
	uiStroke.Parent = parent
end

local function label(parent, text: string, maxTextSize: number, textColor: Color3)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	textLabel.TextScaled = true
	textLabel.Parent = parent

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = maxTextSize
	uiTextSizeConstraint.Parent = textLabel

	return textLabel
end

local function button(p, name: string, caption: string, colour: Color3, zIndex: number)
	return PoolTrickshotStyle.Button(p, {
		Name = name,
		Caption = caption,
		Colour = colour,
		ZIndex = zIndex
	})
end

local function getAuthoredTree() -- 1 equivalent call inferred from this helper
	local frame = PoolTrickshotStyle.Authored("PoolTrickshotUI", "Saves")

	assert(frame:IsA("Frame"), "[Trickshot] PoolTrickshotUI.Saves must be a Frame")

	return frame
end

local function bindPrompt(p)
	local prompt = p.Root:FindFirstChild("Prompt")
	local cancel = prompt:FindFirstChild("Box"):FindFirstChild("Cancel")

	prompt.Visible = false

	p.Maid:GiveTask(cancel.Activated:Connect(function()
		prompt.Visible = false
	end))

	return prompt
end

local function ask(p, text: string, visible: boolean, value: string?, fn)
	local prompt = p.Prompt
	local box = prompt:FindFirstChild("Box")
	local field = box:FindFirstChild("Field")
	local confirm = box:FindFirstChild("Confirm")

	local promptMaid = p.PromptMaid
	promptMaid:DoCleaning()

	local question = box:FindFirstChild("Question")
	question.Text = text
	field.Visible = visible
	field.Text = value or ""
	prompt.Visible = true

	promptMaid:GiveTask(confirm.Activated:Connect(function()
		prompt.Visible = false
		fn(field.Text)
	end))
end

local function sortedSlots(items)
	local result = {}

	for k, item in items do
		if not (typeof(item) == "table" and typeof(item.Balls) == "table") then
			continue
		end

		table.insert(result, { Id = k, Scene = item })
	end

	table.sort(result, function(a, b): boolean
		local v = typeof(a.Scene.Saved) ~= "number" and 0 or a.Scene.Saved
		local v2 = typeof(b.Scene.Saved) ~= "number" and 0 or b.Scene.Saved

		if v == v2 then
			return (tonumber(a.Id) or 0) > (tonumber(b.Id) or 0)
		end

		return v2 < v
	end)

	return result
end

local function formatSaved(saved) -- 1 equivalent call inferred from this helper
	if typeof(saved) ~= "number" or saved <= 0 then
		return "—"
	end

	local success, result = pcall(function()
		local dateTime = DateTime.fromUnixTimestamp(saved)
		local formatLocalTime = DateTime.now():FormatLocalTime("YYYY", "en-us")

		if dateTime:FormatLocalTime("YYYY", "en-us") == formatLocalTime then
			return dateTime:FormatLocalTime("D MMM, HH:mm", "en-us")
		end

		return dateTime:FormatLocalTime("D MMM YYYY", "en-us")
	end)
	return if success then result else "—"
end

function PoolTrickshotSaves.Refresh(data, options)
	for _, guiObject in data.List:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v = sortedSlots(options or {})
	local v2 = data.Mode == "Save"

	local empty = data.Root:FindFirstChild("Empty")
	empty.Visible = #v == 0

	for k, v3 in v do
		local clone = data.Template:Clone()
		clone.Name = "Slot" .. v3.Id
		clone.LayoutOrder = k
		clone.Visible = true
		clone.Parent = data.List

		local pick = clone:FindFirstChild("Pick")
		local delete = clone:FindFirstChild("Delete")
		local play = clone:FindFirstChild("Play")

		local slotName = pick:FindFirstChild("SlotName")
		slotName.Text = v3.Scene.Name or "Untitled"
		local count = 0
		local count2 = 0

		for _, ball in v3.Scene.Balls do
			if typeof(ball) == "table" and ball.N == PoolConstants.CueBallNumber then
				count2 += 1
			else
				count += 1
			end
		end

		local v4 = typeof(v3.Scene.Mods) == "table" and #v3.Scene.Mods or 0

		local text = string.format(
			"%d shot%s  •  %d ball%s",
			count2,
			count2 == 1 and "" or "s",
			count,
			count == 1 and "" or "s"
		)

		if v4 > 0 then
			text ..= string.format("  •  %d pad%s", v4, v4 == 1 and "" or "s")
		end

		local v5 = PoolTrickshotTypes.CleanTableScale(v3.Scene.TL)
		local v6 = PoolTrickshotTypes.CleanTableScale(v3.Scene.TH)

		if v5 ~= 1 or v6 ~= 1 then
			text ..= string.format("  •  %g×%g table", v5, v6)
		end

		local detail = pick:FindFirstChild("Detail")
		detail.Text = text

		local code = pick:FindFirstChild("Code")

		if code then
			local code2 = v3.Scene.Code

			code.Text = typeof(code2) ~= "string" and "…" or PoolTrickshotCodes.Format(code2)
		end

		local saved = pick:FindFirstChild("Saved")

		if saved then
			saved.Text = formatSaved(v3.Scene.Saved) -- inferred equivalent call
		end

		local id = v3.Id
		local name = v3.Scene.Name or "Untitled"
		local scene = v3.Scene

		data.Maid:GiveTask(pick.Activated:Connect(function()
			if v2 then
				ask(data, string.format("Overwrite %q?", name), false, nil, function()
					data.saveOverEvent:Fire(id)
				end)
			else
				data.loadEvent:Fire(id, scene)
			end
		end))

		data.Maid:GiveTask(delete.Activated:Connect(function()
			ask(data, string.format("Delete %q? This cannot be undone.", name), false, nil, function()
				data.deleteEvent:Fire(id)
			end)
		end))

		data.Maid:GiveTask(play.Activated:Connect(function()
			data.playEvent:Fire(id, scene)
		end))
	end

	NormaliseZ(data.Root)
end

function PoolTrickshotSaves.ShowShare(p, p2: string)
	local code = p.Share:FindFirstChild("Box"):FindFirstChild("Code")

	code.Text = PoolTrickshotCodes.Format(p2)
	p.Share.Visible = true
	p.Root.Visible = false
end

function PoolTrickshotSaves:Open(mode: string, p)
	self.Mode = mode
	self.Header.Text = mode == "Save" and "SAVE TRICKSHOT" or "LOAD TRICKSHOT"

	local saveNew = self.Root:FindFirstChild("SaveNew")
	saveNew.Visible = mode == "Save"

	local codeEntry = self.Root:FindFirstChild("CodeEntry")

	if codeEntry then
		codeEntry.Visible = mode == "Load"

		local field = codeEntry:FindFirstChild("Field")

		if field then
			field.Text = ""
		end
	end

	self.Prompt.Visible = false

	PoolTrickshotSaves.Refresh(self, p)
	self.Root.Visible = true
end

function PoolTrickshotSaves.Close(p)
	p.Root.Visible = false
	p.Prompt.Visible = false
end

function PoolTrickshotSaves.new(parent)
	local maid = Maid.new()

	local trickshotSaves = getAuthoredTree():Clone() -- inferred equivalent call
	trickshotSaves.Name = "TrickshotSaves"
	trickshotSaves.Visible = false
	trickshotSaves.Parent = parent
	maid:GiveTask(trickshotSaves)

	local v = {}

	for _, v2 in { "saveNew", "saveOver", "load", "play", "delete", "closed", "code" } do
		local bindableEvent = Instance.new("BindableEvent")
		maid:GiveTask(bindableEvent)
		v[v2] = bindableEvent
	end

	local slotTemplate = trickshotSaves:FindFirstChild("SlotTemplate")
	assert(slotTemplate, "[Trickshot] the authored Saves panel has no SlotTemplate")
	slotTemplate.Parent = nil
	slotTemplate.Visible = true

	local v2 = {
		Root = trickshotSaves,
		List = trickshotSaves:FindFirstChild("List"),
		Header = trickshotSaves:FindFirstChild("Header"),
		Template = slotTemplate,
		Prompt = nil,
		PromptMaid = Maid.new(),
		Mode = "Save",
		SaveNew = v.saveNew.Event,
		SaveOver = v.saveOver.Event,
		LoadSlot = v.load.Event,
		PlaySlot = v.play.Event,
		CodeRequested = v.code.Event,
		Share = nil,
		DeleteSlot = v.delete.Event,
		Closed = v.closed.Event,
		Maid = maid
	}

	v2.saveNewEvent = v.saveNew
	v2.saveOverEvent = v.saveOver
	v2.loadEvent = v.load
	v2.playEvent = v.play
	v2.codeEvent = v.code
	v2.deleteEvent = v.delete
	v2.closedEvent = v.closed

	maid:GiveTask(slotTemplate)
	maid:GiveTask(v2.PromptMaid)

	v2.Prompt = bindPrompt(v2)

	local trickshotShare = PoolTrickshotStyle.Authored("PoolTrickshotUI", "Share"):Clone()

	trickshotShare.Name = "TrickshotShare"
	trickshotShare.Visible = false
	trickshotShare.Parent = parent
	maid:GiveTask(trickshotShare)

	v2.Share = trickshotShare

	local done = trickshotShare:FindFirstChild("Box") and trickshotShare.Box:FindFirstChild("Done")

	if done then
		maid:GiveTask(done.Activated:Connect(function()
			trickshotShare.Visible = false
		end))
	end

	NormaliseZ(trickshotShare)

	local codeEntry = trickshotSaves:FindFirstChild("CodeEntry")

	if codeEntry then
		local field = codeEntry:FindFirstChild("Field")

		local function submit() -- 1 equivalent call inferred from this helper
			local text = field.Text

			local normalise = PoolTrickshotCodes.Normalise(text)

			if not normalise then
				return
			end

			field.Text = ""
			v2.codeEvent:Fire(normalise)
		end

		maid:GiveTask(codeEntry:FindFirstChild("Open").Activated:Connect(submit))

		maid:GiveTask(field.FocusLost:Connect(function(flag: boolean)
			if flag then
				submit() -- inferred equivalent call
			end
		end))
	end

	local close = trickshotSaves:FindFirstChild("Close")
	local saveNew = trickshotSaves:FindFirstChild("SaveNew")

	maid:GiveTask(close.Activated:Connect(function()
		PoolTrickshotSaves.Close(v2)
		v2.closedEvent:Fire()
	end))

	maid:GiveTask(saveNew.Activated:Connect(function()
		ask(v2, "Name this trickshot", true, "", function(p: string)
			local v3 = PoolTrickshotTypes.CleanName(p)

			if v3 then
				v2.saveNewEvent:Fire(v3)
			else
				ask(v2, "That name is empty. Try again.", true, p, function(p2: string)
					local v4 = PoolTrickshotTypes.CleanName(p2)

					if v4 then
						v2.saveNewEvent:Fire(v4)
					end
				end)
			end
		end)
	end))

	NormaliseZ(trickshotSaves)

	return v2
end

function PoolTrickshotSaves:Destroy()
	self.Maid:DoCleaning()
end

return PoolTrickshotSaves