local loader = require(script.Parent.loader)
local v = loader.load(script)("Maid")

local BaseObject = { ["ClassName"] = nil, ["ClassName"] = nil, ClassName = "BaseObject" }

BaseObject.__index = BaseObject

function BaseObject.new(obj)
	local self = setmetatable({}, BaseObject)

	self._maid = v.new()
	self._obj = obj

	return self
end

function BaseObject:Destroy()
	self._maid:DoCleaning()
	setmetatable(self, nil)
end

return BaseObject