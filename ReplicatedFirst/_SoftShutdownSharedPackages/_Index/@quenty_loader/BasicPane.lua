local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Signal")
local v2 = loaded("Maid")
local v3 = loaded("Observable")

local BasicPane = {}
BasicPane.__index = BasicPane
BasicPane.ClassName = "BasicPane"

function BasicPane:isBasicPane()
	local v4

	if type(self) == "table" then
		v4 = v2.isMaid(self._maid) and v.isSignal(self.VisibleChanged)

		if v4 then
			if
				type(self.SetVisible) == "function"
				and type(self.IsVisible) == "function"
				and type(self.Show) == "function"
				and type(self.ObserveVisible) == "function"
				and type(self.Hide) == "function"
				and type(self.Toggle) == "function"
			then
				return type(self.Destroy) == "function"
			end

			return false
		end
	else
		return false
	end

	return v4
end

function BasicPane.new(gui)
	local self = setmetatable({}, BasicPane)

	self._maid = v2.new()
	self.Maid = self._maid

	self._visible = false

	self.VisibleChanged = self._maid:Add(v.new())

	if gui then
		self._gui = gui
		self.Gui = gui
		self._maid:GiveTask(gui)
	end

	return self
end

function BasicPane:SetVisible(visible, p)
	assert(type(visible) == "boolean", "Bad isVisible")

	if self._visible ~= visible then
		self._visible = visible

		local paneVisibleMaid = v2.new()
		self._maid._paneVisibleMaid = paneVisibleMaid
		self.VisibleChanged:Fire(self._visible, p, paneVisibleMaid)
	end
end

function BasicPane:ObserveVisible()
	return v3.new(function(object)
		local maid = v2.new()

		maid:GiveTask(self.VisibleChanged:Connect(function(p, p2)
			object:Fire(p, p2)
		end))
		object:Fire(self:IsVisible())

		return maid
	end)
end

function BasicPane:Show(p)
	self:SetVisible(true, p)
end

function BasicPane:Hide(p)
	self:SetVisible(false, p)
end

function BasicPane:Toggle(p)
	self:SetVisible(not self._visible, p)
end

function BasicPane:IsVisible()
	return self._visible
end

function BasicPane:Destroy()
	self._maid:DoCleaning()
	self._maid = nil
	setmetatable(self, nil)
end

return BasicPane