local loader = require(script.Parent.loader)
local v = loader.load(script)("Observable")

local ObservableSubscriptionTable = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "ObservableSubscriptionTable"
}

ObservableSubscriptionTable.__index = ObservableSubscriptionTable

function ObservableSubscriptionTable.new()
	local self = setmetatable({}, ObservableSubscriptionTable)

	self._subMap = {}

	return self
end

function ObservableSubscriptionTable:Fire(p, ...)
	assert(p ~= nil, "Bad key")

	local sub = self._subMap[p]

	if not sub then
		return
	end

	for _, v2 in pairs(table.clone(sub)) do
		task.spawn(v2.Fire, v2, ...)
	end
end

function ObservableSubscriptionTable:Complete(p, ...)
	local sub = self._subMap[p]

	if not sub then
		return
	end

	local clone = table.clone(sub)
	self._subMap[p] = nil

	for _, v2 in pairs(clone) do
		task.spawn(v2.Complete, v2, ...)
	end
end

function ObservableSubscriptionTable:Observe(p, callback)
	assert(p ~= nil, "Bad key")

	return v.new(function(object)
		if self._subMap[p] then
			table.insert(self._subMap[p], object)
		else
			self._subMap[p] = { object }
		end

		if callback then
			callback(object)
		end

		return function()
			if not self._subMap[p] then
				return
			end

			local sub = self._subMap[p]
			local index = table.find(sub, object)

			if not index then
				return
			end

			table.remove(sub, index)

			if #sub == 0 then
				self._subMap[p] = nil
			end

			if object:IsPending() then
				task.spawn(function()
					object:Complete()
				end)
			end
		end
	end)
end

function ObservableSubscriptionTable:Destroy()
	while next(self._subMap) do
		local v2, v3 = next(self._subMap)
		self._subMap[v2] = nil

		for _, v4 in pairs(v3) do
			if not v4:IsPending() then
				continue
			end

			local v5 = v4
			task.spawn(function()
				v5:Complete()
			end)
		end
	end
end

return ObservableSubscriptionTable