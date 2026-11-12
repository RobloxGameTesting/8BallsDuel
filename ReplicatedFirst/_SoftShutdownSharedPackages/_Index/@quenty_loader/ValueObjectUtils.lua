local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Maid")
local v2 = loaded("Brio")
local v3 = loaded("Observable")
local v4 = loaded("ValueObject")
local ValueObjectUtils = {}

function ValueObjectUtils.syncValue(p, p2)
	local maid = v.new()
	p2.Value = p.Value

	maid:GiveTask(p.Changed:Connect(function()
		p2.Value = p.Value
	end))

	return maid
end

function ValueObjectUtils.observeValue(data)
	assert(v4.isValueObject(data), "Bad valueObject")

	return v3.new(function(object)
		if data.Destroy then
			local maid = v.new()

			maid:GiveTask(data.Changed:Connect(function()
				object:Fire(data.Value)
			end))

			object:Fire(data.Value)

			return maid
		end

		warn("[ValueObjectUtils.observeValue] - Connecting to dead ValueObject")

		object:Complete()
	end)
end

function ValueObjectUtils.observeValueBrio(p)
	assert(p, "Bad valueObject")

	return v3.new(function(object)
		local maid = v.new()

		local function refire() -- 1 equivalent call inferred from this helper
			local lastBrio = v2.new(p.Value)
			maid._lastBrio = lastBrio
			object:Fire(lastBrio)
		end

		maid:GiveTask(p.Changed:Connect(refire))
		refire() -- inferred equivalent call
		return maid
	end)
end

return ValueObjectUtils