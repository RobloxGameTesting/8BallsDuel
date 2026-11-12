local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local v = loaded("AttributeValue")
local v2 = loaded("Maid")
local v3 = loaded("PlayerGuiUtils")
local v4 = loaded("Rx")
local v5 = loaded("SoftShutdownConstants")
local v6 = loaded("SoftShutdownTranslator")
local v7 = loaded("SoftShutdownUI")
local v8 = loaded("ValueObject")
local v9 = loaded("CoreGuiEnabler")

local v10 = {
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.EmotesMenu,
	Enum.CoreGuiType.All
}
local SoftShutdownServiceClient = {}
SoftShutdownServiceClient.ServiceName = "SoftShutdownServiceClient"

function SoftShutdownServiceClient:Init(p)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(p, "No serviceBag")

	self._maid = v2.new()
	self._translator = self._serviceBag:GetService(v6)

	self._isLobby = v.new(Workspace, v5.IS_SOFT_SHUTDOWN_LOBBY_ATTRIBUTE, false)
	self._isUpdating = v.new(Workspace, v5.IS_SOFT_SHUTDOWN_UPDATING_ATTRIBUTE, false)

	self._localTeleportDataSaysIsLobby = self._maid:Add(v8.new(false, "boolean"))
	self._isArrivingAfterShutdown = self._maid:Add(v8.new(false, "boolean"))

	task.spawn(function()
		if self:_queryLocalTeleportInfo() then
			self._localTeleportDataSaysIsLobby.Value = true
		end

		if self:_queryIsArrivingAfterShutdown() then
			self._isArrivingAfterShutdown.Value = true
		end
	end)

	self._maid:GiveTask(v4.combineLatest({
		isLobby = self._isLobby:Observe(),
		isShuttingDown = self._isUpdating:Observe(),
		localTeleportDataSaysIsLobby = self._localTeleportDataSaysIsLobby:Observe(),
		isArrivingAfterShutdown = self._isArrivingAfterShutdown:Observe()
	}):Subscribe(function(data)
		if data.isLobby or data.localTeleportDataSaysIsLobby then
			self._maid._shutdownUI = nil

			if not self._maid._lobbyUI then
				local maid = self._maid
				local lobbyUI, v11 = self:_showSoftShutdownUI("shutdown.lobby.title", "shutdown.lobby.subtitle", true)
				maid._lobbyUI = lobbyUI

				TeleportService:SetTeleportGui(v11)
			end
		elseif data.isShuttingDown then
			local maid = self._maid
			local shutdownUI, v11 = self:_showSoftShutdownUI("shutdown.restart.title", "shutdown.restart.subtitle")
			maid._shutdownUI = shutdownUI

			TeleportService:SetTeleportGui(v11)

			self._maid._lobbyUI = nil
		elseif data.isArrivingAfterShutdown then
			local shutdownUI = self:_showSoftShutdownUI("shutdown.complete.title", "shutdown.complete.subtitle", true)
			self._maid._shutdownUI = shutdownUI
			self._maid._lobbyUI = nil

			task.delay(1, function()
				if self._maid._shutdownUI == shutdownUI then
					self._maid._shutdownUI = nil
				end
			end)
		else
			self._maid._shutdownUI = nil
			self._maid._lobbyUI = nil
		end
	end))
end

function SoftShutdownServiceClient:_queryIsArrivingAfterShutdown(): boolean
	local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

	if type(localPlayerTeleportData) == "table" and localPlayerTeleportData.isSoftShutdownArrivingIntoUpdatedServer then
		return true
	end

	return false
end

function SoftShutdownServiceClient:_queryLocalTeleportInfo(): boolean
	local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

	if type(localPlayerTeleportData) == "table" and localPlayerTeleportData.isSoftShutdownReserveServer then
		return true
	end

	return false
end

function SoftShutdownServiceClient:_showSoftShutdownUI(p, p2, p3)
	local maid = v2.new()

	local maid2 = v2.new()

	local softShutdownScreenGui = Instance.new("ScreenGui")
	softShutdownScreenGui.Name = "SoftShutdownScreenGui"
	softShutdownScreenGui.ResetOnSpawn = false
	softShutdownScreenGui.AutoLocalize = false
	softShutdownScreenGui.IgnoreGuiInset = true
	softShutdownScreenGui.DisplayOrder = 1000000000
	softShutdownScreenGui.Parent = v3.getPlayerGui()
	softShutdownScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	maid2:GiveTask(softShutdownScreenGui)

	local v11 = v7.new()
	maid2:GiveTask(v11)

	maid:GiveTask(function()
		v11:Hide()

		task.delay(1, function()
			maid2:Destroy()
		end)
	end)

	self:_hideCoreGuiUI(maid2, softShutdownScreenGui)

	maid:GiveTask(self._translator:ObserveFormatByKey(p2):Subscribe(function(p4)
		v11:SetSubtitle(p4)
	end))

	maid:GiveTask(self._translator:ObserveFormatByKey(p):Subscribe(function(p4)
		v11:SetTitle(p4)
	end))

	v11:Show(p3)

	v11.Gui.Parent = softShutdownScreenGui

	return maid, softShutdownScreenGui
end

function SoftShutdownServiceClient:_hideCoreGuiUI(maid, p)
	if not UserInputService.ModalEnabled then
		UserInputService.ModalEnabled = true
		maid:GiveTask(function()
			UserInputService.ModalEnabled = false
		end)
	end

	local playerGui = v3.getPlayerGui()

	local v11 = {}

	local function handleChild(screenGui) -- 2 equivalent calls inferred from this helper
		if screenGui:IsA("ScreenGui") and screenGui ~= p and screenGui.Enabled then
			v11[screenGui] = screenGui
			screenGui.Enabled = false
		end
	end

	for _, child in pairs(playerGui:GetChildren()) do
		handleChild(child) -- inferred equivalent call
	end

	maid:GiveTask(playerGui.ChildAdded:Connect(function(child)
		handleChild(child) -- inferred equivalent call
	end))

	maid:GiveTask(playerGui.ChildRemoved:Connect(function(child)
		v11[child] = nil
	end))

	maid:GiveTask(function()
		for k, _ in pairs(v11) do
			k.Enabled = true
		end
	end)

	for _, v12 in pairs(v10) do
		maid:GiveTask(v9:Disable(self, v12))
	end
end

function SoftShutdownServiceClient:Destroy()
	self._maid:DoCleaning()
end

return SoftShutdownServiceClient