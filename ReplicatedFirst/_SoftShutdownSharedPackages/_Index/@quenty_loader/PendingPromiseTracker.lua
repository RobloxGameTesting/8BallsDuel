local PendingPromiseTracker = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "PendingPromiseTracker"
}

PendingPromiseTracker.__index = PendingPromiseTracker

function PendingPromiseTracker.new()
	local self = setmetatable({}, PendingPromiseTracker)

	self._pendingPromises = {}

	return self
end

function PendingPromiseTracker:Add(object)
	if object:IsPending() then
		self._pendingPromises[object] = true
		object:Finally(function()
			self._pendingPromises[object] = nil
		end)
	end
end

function PendingPromiseTracker:GetAll()
	local all = {}

	for k, _ in pairs(self._pendingPromises) do
		table.insert(all, k)
	end

	return all
end

return PendingPromiseTracker