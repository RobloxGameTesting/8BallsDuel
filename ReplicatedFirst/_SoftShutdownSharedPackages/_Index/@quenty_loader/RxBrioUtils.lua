local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Brio")
local v2 = loaded("BrioUtils")
local v3 = loaded("Maid")
local v4 = loaded("Observable")
local v5 = loaded("Rx")

local RxBrioUtils = {}

function RxBrioUtils.ofBrio(callback)
	return v4.new(function(object)
		local maid = v3.new()

		if type(callback) == "function" then
			object:Fire((maid:Add(v.new(callback(maid)))))
			return maid
		end

		object:Fire((maid:Add(v.new(callback))))

		return maid
	end)
end

function RxBrioUtils.toBrio()
	return v5.map(function(p)
		if v.isBrio(p) then
			return p
		end

		return v.new(p)
	end)
end

function RxBrioUtils.of(...)
	return v5.of(...):Pipe({ RxBrioUtils.toBrio() })
end

function RxBrioUtils.completeOnDeath(object, object2)
	assert(v.isBrio(object))
	assert(v4.isObservable(object2))

	return v4.new(function(object3)
		if object:IsDead() then
			object3:Complete()
			return
		end

		local maid = object:ToMaid()

		maid:GiveTask(function()
			object3:Complete()
		end)
		maid:GiveTask(object2:Subscribe(object3:GetFireFailComplete()))

		return maid
	end)
end

function RxBrioUtils.emitWhileAllDead(p)
	return function(object)
		return v4.new(function(object2)
			local maid = v3.new()

			local v6 = true
			maid:GiveTask(function()
				v6 = false
			end)
			local v7 = {}
			local v8 = false

			local function updateBrios()
				if not v6 then
					return
				end

				v7 = v2.aliveOnly(v7)

				if next(v7) then
					maid._lastBrio = nil
				else
					local lastBrio = v.new(p)
					maid._lastBrio = lastBrio
					object2:Fire(lastBrio)
				end

				v8 = true
			end

			local function handleNewBrio(object3)
				if object3:IsDead() then
					return
				end

				local maid2 = v3.new()
				maid[maid2] = maid2

				maid2:GiveTask(function()
					maid[maid2] = nil

					if not v6 then
						return
					end

					v7 = v2.aliveOnly(v7)

					if next(v7) then
						maid._lastBrio = nil
					else
						local lastBrio = v.new(p)
						maid._lastBrio = lastBrio
						object2:Fire(lastBrio)
					end

					v8 = true
				end)
				maid2:GiveTask(object3:GetDiedSignal():Connect(function()
					maid[maid2] = nil
				end))

				table.insert(v7, object3)

				if not v6 then
					return
				end

				v7 = v2.aliveOnly(v7)

				if next(v7) then
					maid._lastBrio = nil
				else
					local lastBrio = v.new(p)
					maid._lastBrio = lastBrio
					object2:Fire(lastBrio)
				end

				v8 = true
			end

			maid:GiveTask(object:Subscribe(function(p2)
				if v.isBrio(p2) then
					handleNewBrio(p2)
					return
				end

				warn(("[RxBrioUtils.emitWhileAllDead] - Not a brio, %q"):format((tostring(p2))))
				maid._lastBrio = nil
				object2:Fail("Not a brio")
			end, function(...)
				object2:Fail(...)
			end, function(...)
				object2:Complete(...)
			end))

			if not v8 and v6 then
				v7 = v2.aliveOnly(v7)

				if next(v7) then
					maid._lastBrio = nil
				else
					local lastBrio = v.new(p)
					maid._lastBrio = lastBrio
					object2:Fire(lastBrio)
				end

				v8 = true
			end

			return maid
		end)
	end
end

function RxBrioUtils.reduceToAliveList(callback)
	assert(type(callback) == "function" or callback == nil, "Bad selectFromBrio")

	return function(object)
		return v4.new(function(object2)
			local maid = v3.new()

			local v6 = true
			maid:GiveTask(function()
				v6 = false
			end)
			local v7 = {}
			local v8 = false

			local function updateBrios()
				if not v6 then
					return
				end

				v7 = v2.aliveOnly(v7)
				local v9 = {}

				if callback then
					for _, v10 in pairs(v7) do
						local v11 = callback(v10:GetValue())
						assert(v11 ~= nil, "Bad value")

						table.insert(v9, v11)
					end
				else
					for _, v10 in pairs(v7) do
						local value = v10:GetValue()
						assert(value ~= nil, "Bad value")

						table.insert(v9, value)
					end
				end

				local first = v2.first(v7, v9)
				maid._lastBrio = first

				v8 = true
				object2:Fire(first)
			end

			local function handleNewBrio(object3)
				if object3:IsDead() then
					return
				end

				local maid2 = v3.new()
				maid[maid2] = maid2

				maid2:GiveTask(function()
					maid[maid2] = nil
					updateBrios()
				end)
				maid2:GiveTask(object3:GetDiedSignal():Connect(function()
					maid[maid2] = nil
				end))

				table.insert(v7, object3)
				updateBrios()
			end

			maid:GiveTask(object:Subscribe(function(p)
				if v.isBrio(p) then
					handleNewBrio(p)
					return
				end

				warn(("[RxBrioUtils.mergeToAliveList] - Not a brio, %q"):format((tostring(p))))
				maid._lastBrio = nil
				object2:Fail("Not a brio")
			end, function(...)
				object2:Fail(...)
			end, function(...)
				object2:Complete(...)
			end))

			if not v8 then
				updateBrios()
			end

			return maid
		end)
	end
end

function RxBrioUtils.reemitLastBrioOnDeath()
	return function(object)
		return v4.new(function(object2)
			local maid = v3.new()

			maid:GiveTask(object:Subscribe(function(object3)
				maid._conn = nil

				if v.isBrio(object3) then
					if object3:IsDead() then
						object2:Fire(object3)
						return
					end

					maid._conn = object3:GetDiedSignal():Connect(function()
						object2:Fire(object3)
					end)

					object2:Fire(object3)
				else
					warn(("[RxBrioUtils.reemitLastBrioOnDeath] - Not a brio, %q"):format((tostring(object3))))
					object2:Fail("Not a brio")
				end
			end, function(...)
				object2:Fail(...)
			end, function(...)
				object2:Complete(...)
			end))

			return maid
		end)
	end
end

function RxBrioUtils.where(callback)
	assert(type(callback) == "function", "Bad predicate")
	return function(object)
		return v4.new(function(object2)
			local maid = v3.new()

			maid:GiveTask(object:Subscribe(function(object3)
				assert(v.isBrio(object3), "Not a brio")

				if object3:IsDead() then
					return
				end

				if callback(object3:GetValue()) then
					object2:Fire(object3)
				end
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

RxBrioUtils.filter = RxBrioUtils.where

function RxBrioUtils.combineLatest(p)
	assert(type(p) == "table", "Bad observables")

	warn("[RxBrioUtils.combineLatest] - Deprecated since 3.6.0. Use RxBrioUtils.flatCombineLatest")

	return v5.combineLatest(p):Pipe({ v5.map(v2.flatten), RxBrioUtils.onlyLastBrioSurvives() })
end

function RxBrioUtils.flatCombineLatestBrio(p, p2)
	assert(type(p) == "table", "Bad observables")

	return RxBrioUtils.flatCombineLatest(p):Pipe({ RxBrioUtils.switchToBrio(), p2 and RxBrioUtils.where(p2) or nil })
end

function RxBrioUtils.flatMap(callback, p)
	assert(type(callback) == "function", "Bad project")

	warn("[RxBrioUtils.flatMap] - Deprecated since 3.6.0. Use RxBrioUtils.flatMapBrio")

	return v5.flatMap(RxBrioUtils.mapBrio(callback), p)
end

function RxBrioUtils.flatMapBrio(p)
	return v5.flatMap(RxBrioUtils.mapBrioBrio(p))
end

function RxBrioUtils.switchMap(callback)
	assert(type(callback) == "function", "Bad project")

	warn("[RxBrioUtils.switchMap] - Deprecated since 3.6.0. Use RxBrioUtils.switchMapBrio")

	return v5.switchMap(RxBrioUtils.mapBrio(callback))
end

function RxBrioUtils.switchMapBrio(callback)
	assert(type(callback) == "function", "Bad project")

	return v5.switchMap(RxBrioUtils.mapBrioBrio(callback))
end

function RxBrioUtils.flatCombineLatest(items)
	assert(type(items) == "table", "Bad observables")

	local v6 = {}

	for k, item in pairs(items) do
		if v4.isObservable(item) then
			v6[k] = RxBrioUtils.flattenToValueAndNil(item)
		else
			v6[k] = item
		end
	end

	return v5.combineLatest(v6)
end

function RxBrioUtils.mapBrio(callback)
	assert(type(callback) == "function", "Bad project")

	warn("[RxBrioUtils.mapBrio] - Deprecated since 3.6.0. Use RxBrioUtils.mapBrioBrio")

	return function(object)
		assert(v.isBrio(object), "Not a brio")

		if object:IsDead() then
			return v5.EMPTY
		end

		local v6 = callback(object:GetValue())
		assert(v4.isObservable(v6), "Not an observable")

		return RxBrioUtils.completeOnDeath(object, v6)
	end
end

function RxBrioUtils.prepend(...)
	local v6 = table.pack(...)

	return v5.map(function(p)
		assert(v.isBrio(p), "Bad brio")

		return v2.prepend(p, table.unpack(v6, 1, v6.n))
	end)
end

function RxBrioUtils.extend(...)
	local v6 = table.pack(...)

	return v5.map(function(p)
		assert(v.isBrio(p), "Bad brio")

		return v2.extend(p, table.unpack(v6, 1, v6.n))
	end)
end

function RxBrioUtils.map(callback)
	return v5.map(function(...)
		local v6 = select("#", ...)
		local v7 = {}
		local v8

		if v6 == 1 then
			if v.isBrio(...) then
				table.insert(v7, (...))
				v8 = (...):GetPackedValues()
			else
				v8 = { (...) }
			end
		else
			v8 = {}

			for k, v9 in pairs({ ... }) do
				if v.isBrio(v9) then
					table.insert(v7, v9)
					v8[k] = v9:GetValue()
				else
					v8[k] = v9
				end
			end

			v8.n = v6
		end

		local v9 = table.pack(callback(table.unpack(v8, 1, v8.n)))
		local v10 = {}

		for i = 1, v9.n do
			local v11 = v9[i]

			if v.isBrio(v11) then
				table.insert(v7, v11)
				v10[i] = v11:GetValue()
			else
				v10[i] = v11
			end
		end

		return v2.first(v7, table.unpack(v10, 1, v10.n))
	end)
end

function RxBrioUtils._mapResult(p)
	return function(...)
		local v6 = select("#", ...)

		if v6 == 0 then
			return v2.withOtherValues(p)
		end

		if v6 == 1 then
			if v.isBrio(...) then
				return v2.first({ p, (...) }, (...):GetValue())
			end

			return v2.withOtherValues(p, ...)
		else
			local v7 = { p }
			local v8 = {}

			for k, v9 in pairs({ ... }) do
				if v.isBrio(v9) then
					table.insert(v7, v9)
					v8[k] = v9:GetValue()
				else
					v8[k] = v9
				end
			end

			return v2.first(v7, unpack(v8, 1, v6))
		end
	end
end

function RxBrioUtils.mapBrioBrio(callback)
	assert(type(callback) == "function", "Bad project")

	return function(object)
		assert(v.isBrio(object), "Not a brio")

		if object:IsDead() then
			return v5.EMPTY
		end

		local v6 = callback(object:GetValue())
		assert(v4.isObservable(v6), "Not an observable")

		return RxBrioUtils.completeOnDeath(object, v6):Pipe({ v5.map(RxBrioUtils._mapResult(object)) })
	end
end

function RxBrioUtils.toEmitOnDeathObservable(object, p)
	if v.isBrio(object) then
		return v4.new(function(object2)
			if not object:IsDead() then
				object2:Fire(object:GetValue())

				if not object2:IsPending() then
					return
				end

				if not object:IsDead() then
					return object:GetDiedSignal():Connect(function()
						object2:Fire(p)
						object2:Complete()
					end)
				end
			end

			object2:Fire(p)
			object2:Complete()
		end)
	end

	return v5.of(object)
end

function RxBrioUtils.mapBrioToEmitOnDeathObservable(p)
	return function(p2)
		return RxBrioUtils.toEmitOnDeathObservable(p2, p)
	end
end

function RxBrioUtils.emitOnDeath(p)
	return v5.switchMap(function(p2)
		return RxBrioUtils.toEmitOnDeathObservable(p2, p)
	end)
end

RxBrioUtils.flattenToValueAndNil = RxBrioUtils.emitOnDeath(nil)

function RxBrioUtils.onlyLastBrioSurvives()
	return function(object)
		return v4.new(function(object2)
			local maid = v3.new()

			maid:GiveTask(object:Subscribe(function(p)
				if v.isBrio(p) then
					local clone = v2.clone(p)
					maid._lastBrio = clone

					object2:Fire(clone)
				else
					warn(("[RxBrioUtils.onlyLastBrioSurvives] - Not a brio, %q"):format((tostring(p))))
					maid._lastBrio = nil
					object2:Fail("Not a brio")
				end
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

function RxBrioUtils.switchToBrio()
	return function(object)
		return v4.new(function(object2)
			local maid = v3.new()

			maid:GiveTask(object:Subscribe(function(object3, ...)
				if v.isBrio(object3) then
					if object3:IsDead() then
						maid._last = nil
						return
					end

					local maid2 = object3:ToMaid()
					local v6 = v.new(object3:GetValue())
					maid2:GiveTask(v6)

					maid._last = maid2
					object2:Fire(v6)
				else
					local last = v.new(object3, ...)

					maid._last = last
					object2:Fire(last)
				end
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

return RxBrioUtils