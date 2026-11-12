local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("RxInstanceUtils")
local v2 = loaded("RxBrioUtils")

local RxRootPartUtils = {}

function RxRootPartUtils.observeHumanoidRootPartBrio(p)
	return v.observeLastNamedChildBrio(p, "BasePart", "HumanoidRootPart")
end

function RxRootPartUtils.observeHumanoidRootPartBrioFromHumanoid(p)
	return v.observePropertyBrio(p, "Parent", function(p2): boolean
		return p2 ~= nil
	end):Pipe({ v2.switchMapBrio(function(p2)
			return RxRootPartUtils.observeHumanoidRootPartBrio(p2)
		end) })
end

return RxRootPartUtils