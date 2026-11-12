local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Brio")
local v2 = loaded("Maid")
local v3 = loaded("Observable")
local v4 = loaded("RxBrioUtils")
local v5 = loaded("RxInstanceUtils")

local RxCharacterUtils = {}

function RxCharacterUtils.observeLastCharacterBrio(p)
	return v5.observePropertyBrio(p, "Character", function(p2): boolean
		return p2 ~= nil
	end)
end

function RxCharacterUtils.observeCharacter(p)
	return v5.observeProperty(p, "Character")
end

function RxCharacterUtils.observeLastHumanoidBrio(p)
	return RxCharacterUtils.observeLastCharacterBrio(p):Pipe({ v4.switchMapBrio(function(p2)
			return v5.observeLastNamedChildBrio(p2, "Humanoid", "Humanoid")
		end) })
end

local function observeHumanoidLifetimeAsBrio(p)
	return v3.new(function(object)
		local function onDeath() -- 1 equivalent call inferred from this helper
			object:Complete()
		end

		if not (p.Health > 0) then
			onDeath() -- inferred equivalent call
			return
		end

		local maid = v2.new()

		maid._brio = v.new(p)
		object:Fire(maid._brio)

		maid:GiveTask(p.Died:Connect(onDeath))

		return maid
	end)
end

function RxCharacterUtils.observeLastAliveHumanoidBrio(p)
	return RxCharacterUtils.observeLastHumanoidBrio(p):Pipe({ v4.switchMapBrio(function(p2)
			return observeHumanoidLifetimeAsBrio(p2)
		end) })
end

return RxCharacterUtils