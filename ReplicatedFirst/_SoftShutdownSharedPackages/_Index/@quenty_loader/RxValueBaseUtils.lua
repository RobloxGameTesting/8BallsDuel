local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("RxInstanceUtils")
local v2 = loaded("RxBrioUtils")

local RxValueBaseUtils = {}

function RxValueBaseUtils.observeBrio(instance, value, value2, p)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(value) == "string", "Bad className")
	assert(type(value2) == "string", "Bad naem")

	return v.observeLastNamedChildBrio(instance, value, value2):Pipe({
		v2.switchMapBrio(function(p2)
			return RxValueBaseUtils.observeValue(p2)
		end),
		v2.onlyLastBrioSurvives(),
		p and v2.where(p) or nil
	})
end

function RxValueBaseUtils.observe(instance, value, value2, p)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(value) == "string", "Bad className")
	assert(type(value2) == "string", "Bad name")

	return RxValueBaseUtils.observeBrio(instance, value, value2):Pipe({ v2.emitOnDeath(p) })
end

function RxValueBaseUtils.observeValue(p)
	return v.observeProperty(p, "Value")
end

return RxValueBaseUtils