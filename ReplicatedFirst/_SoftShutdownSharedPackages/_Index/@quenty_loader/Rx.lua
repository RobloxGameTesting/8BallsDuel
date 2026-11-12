local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Maid")
local v2 = loaded("Observable")
local v3 = loaded("Promise")
local v4 = loaded("Symbol")
local v5 = loaded("ThrottledFunction")
local v6 = loaded("cancellableDelay")
local v7 = loaded("CancelToken")

local named = v4.named("unsetValue")

local Rx = {
	EMPTY = v2.new(function(object)
		object:Complete()
	end),
	NEVER = v2.new(function(_) end)
}

function Rx.pipe(items)
	assert(type(items) == "table", "Bad transformers")

	for k, item in pairs(items) do
		if type(item) ~= "function" then
			error(("[Rx.pipe] Bad pipe value of type %q at index %q, expected function"):format(
				type(item),
				(tostring(k))
			))
		end
	end

	return function(instance)
		assert(instance, "Bad source")

		for k, item in pairs(items) do
			instance = item(instance)

			if type(instance) ~= "table" or instance.ClassName ~= "Observable" then
				error(("[Rx.pipe] - Failed to transform %q in pipe, made %q (%s)"):format(
					tostring(k),
					tostring(instance),
					(tostring(type(instance) == "table" and instance.ClassName or ""))
				))
			end
		end

		return instance
	end
end

function Rx.of(...)
	local v8 = table.pack(...)

	return v2.new(function(object)
		for i = 1, v8.n do
			object:Fire(v8[i])
		end

		object:Complete()
	end)
end

function Rx.failed(...)
	local v8 = table.pack(...)

	return v2.new(function(object)
		object:Fail(table.unpack(v8, 1, v8.n))
	end)
end

function Rx.from(list)
	if v3.isPromise(list) then
		return Rx.fromPromise(list)
	end

	if type(list) == "table" then
		return Rx.of(unpack(list))
	end

	error("[Rx.from] - cannot convert")
end

function Rx.toPromise(object, object2)
	local maid = v.new()

	local v8 = v7.new(function(onCancelled)
		maid:GiveTask(onCancelled)

		if object2 then
			if object2:IsCancelled() then
				onCancelled()
			else
				maid:GiveTask(object2.Cancelled:Connect(onCancelled))
			end
		end
	end)

	local promise = v3.new(function(p, callback)
		if v8:IsCancelled() then
			callback()
			return
		end

		maid:GiveTask(v8.Cancelled:Connect(function()
			callback()
		end))

		maid:GiveTask(object:Subscribe(p, callback, callback))
	end)

	promise:Finally(function()
		maid:DoCleaning()
	end)

	return promise
end

function Rx.merge(items)
	assert(type(items) == "table", "Bad observables")
	local count = 0

	for _, item in pairs(items) do
		assert(v2.isObservable(item), "Not an observable")
		count += 1
	end

	return v2.new(function(object)
		local maid = v.new()
		local v8 = count

		for _, item in pairs(items) do
			maid:GiveTask(item:Subscribe(function(...)
				object:Fire(...)
			end, function(...)
				v8 -= 1
				object:Fail(...)
			end, function()
				v8 -= 1

				if v8 == 0 then
					object:Complete()
				end
			end))
		end

		return maid
	end)
end

function Rx.fromSignal(object)
	return v2.new(function(object2)
		return object:Connect(function(...)
			object2:Fire(...)
		end)
	end)
end

function Rx.fromPromise(object)
	assert(v3.isPromise(object), "Bad promise")

	return v2.new(function(object2)
		if object:IsFulfilled() then
			object2:Fire(object:Wait())
			object2:Complete()
			return nil
		else
			local maid = v.new()

			local flag = true
			maid:GiveTask(function()
				flag = false
			end)

			object:Then(function(...)
				if flag then
					object2:Fire(...)
					object2:Complete()
				end
			end, function(...)
				if flag then
					object2:Fail(...)
					object2:Complete()
				end
			end)

			return maid
		end
	end)
end

function Rx.tap(callback, callback2, callback3)
	assert(type(callback) == "function" or callback == nil, "Bad onFire")
	assert(type(callback2) == "function" or callback2 == nil, "Bad onError")
	assert(type(callback3) == "function" or callback3 == nil, "Bad onComplete")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			return object:Subscribe(function(...)
				if callback then
					callback(...)
				end

				if object2:IsPending() then
					object2:Fire(...)
				end
			end, function(...)
				if callback2 then
					callback2(...)
				end

				object2:Error(...)
			end, function(...)
				if callback3 then
					callback3(...)
				end

				object2:Complete(...)
			end)
		end)
	end
end

function Rx.start(callback)
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			object2:Fire(callback())

			return object:Subscribe(object2:GetFireFailComplete())
		end)
	end
end

function Rx.share()
	return function(object)
		local v8 = v.new()
		local v9 = {}

		local v10 = named
		local v11 = named

		local function connectToSourceIfNeeded()
			if not v8._currentSub then
				v10 = named
				v11 = named

				v8._currentSub = object:Subscribe(function(...)
					for _, v12 in pairs(v9) do
						v12:Fire(...)
					end
				end, function(...)
					v10 = table.pack(...)

					for _, v12 in pairs(v9) do
						v12:Fail(...)
					end
				end, function(...)
					v11 = table.pack(...)

					for _, v12 in pairs(v9) do
						v12:Complete(...)
					end
				end)
			end
		end

		local function disconnectFromSource() -- 1 equivalent call inferred from this helper
			v8._currentSub = nil

			v10 = named
			v11 = named
		end

		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			if v10 ~= named then
				object2:Fail(table.unpack(v10, 1, v10.n))
				return
			end

			if v11 ~= named then
				object2:Fail(table.unpack(v11, 1, v11.n))
				return
			end

			table.insert(v9, object2)
			connectToSourceIfNeeded()

			return function()
				local index = table.find(v9, object2)

				if index then
					table.remove(v9, index)

					if #v9 == 0 then
						disconnectFromSource() -- inferred equivalent call
					end
				end
			end
		end)
	end
end

function Rx.shareReplay(value, value2)
	assert(type(value) == "number" or value == nil, "Bad bufferSize")
	assert(type(value2) == "number" or value2 == nil, "Bad windowTimeSeconds")

	local v8 = value or 1e999
	local v9 = value2 or 1e999

	return function(object)
		local v10 = v.new()
		local v11 = {}

		local v12 = {}
		local v13 = named
		local v14 = named

		local function getEventsCopy()
			local now = os.clock()
			local eventsCopy = {}

			for _, v15 in pairs(v12) do
				if now - v15.timestamp <= v9 then
					table.insert(eventsCopy, v15)
				end
			end

			return eventsCopy
		end

		local function connectToSourceIfNeeded()
			if not v10._currentSub then
				v12 = {}
				v13 = named
				v14 = named

				v10._currentSub = object:Subscribe(function(...)
					if v8 < #v12 + 1 then
						table.remove(v12, 1)
					end

					local v15 = table.pack(...)
					v15.timestamp = os.clock()
					table.insert(v12, v15)

					for _, v16 in pairs(table.clone(v11)) do
						if v16:IsPending() then
							v16:Fire(table.unpack(v15, 1, v15.n))
						end
					end
				end, function(...)
					v13 = table.pack(...)

					for _, v15 in pairs(table.clone(v11)) do
						if v15:IsPending() then
							v15:Fail(...)
						end
					end
				end, function(...)
					v14 = table.pack(...)

					for _, v15 in pairs(table.clone(v11)) do
						if v15:IsPending() then
							v15:Complete(...)
						end
					end
				end)
			end
		end

		local function disconnectFromSource() -- 1 equivalent call inferred from this helper
			v10._currentSub = nil

			v12 = {}
			v13 = named
			v14 = named
		end

		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			if v13 ~= named then
				object2:Fail(table.unpack(v13, 1, v13.n))
				return
			end

			if v14 ~= named then
				object2:Fail(table.unpack(v14, 1, v14.n))
				return
			end

			table.insert(v11, object2)

			for _, list in pairs(getEventsCopy()) do
				object2:Fire(table.unpack(list, 1, list.n))
			end

			connectToSourceIfNeeded()

			return function()
				local index = table.find(v11, object2)

				if index then
					table.remove(v11, index)

					if #v11 == 0 then
						disconnectFromSource() -- inferred equivalent call
					end
				end
			end
		end)
	end
end

function Rx.cache()
	return Rx.shareReplay(1)
end

function Rx.startFrom(callback)
	assert(type(callback) == "function", "Bad callback")
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			for _, v8 in pairs(callback()) do
				object2:Fire(v8)
			end

			return object:Subscribe(object2:GetFireFailComplete())
		end)
	end
end

function Rx.startWith(items)
	assert(type(items) == "table", "Bad values")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			for _, item in pairs(items) do
				object2:Fire(item)
			end

			return object:Subscribe(object2:GetFireFailComplete())
		end)
	end
end

function Rx.scan(callback, p)
	assert(type(callback) == "function", "Bad accumulator")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local v8 = p

			return object:Subscribe(function(...)
				v8 = callback(v8, ...)
				object2:Fire(v8)
			end, object2:GetFailComplete())
		end)
	end
end

function Rx.reduce(callback, p)
	assert(type(callback) == "function", "Bad reducer")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()
			local v8 = p

			maid:GiveTask(object:Subscribe(function(...)
				v8 = callback(v8, ...)
			end, function(...)
				object2:Fail(...)
			end), function()
				object2:Fire(v8)
			end)

			return maid
		end)
	end
end

function Rx.defaultsTo(p)
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = false

			maid:GiveTask(object:Subscribe(function(...)
				v8 = true
				object2:Fire(...)
			end, object2:GetFailComplete()))

			if not v8 then
				object2:Fire(p)
			end

			return maid
		end)
	end
end

Rx.defaultsToNil = Rx.defaultsTo(nil)

function Rx.endWith(items)
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			maid:GiveTask(object:Subscribe(function(...)
				object2:Fire(...)
			end, function(...)
				for _, item in pairs(items) do
					object2:Fire(item)
				end

				object2:Fail(...)
			end), function()
				for _, item in pairs(items) do
					object2:Fire(item)
				end

				object2:Complete()
			end)

			return maid
		end)
	end
end

function Rx.where(callback)
	assert(type(callback) == "function", "Bad predicate callback")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			return object:Subscribe(function(...)
				if callback(...) then
					object2:Fire(...)
				end
			end, object2:GetFailComplete())
		end)
	end
end

function Rx.distinct()
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local v8 = named

			return object:Subscribe(function(p)
				if v8 == p then
					return
				end

				v8 = p
				object2:Fire(v8)
			end, object2:GetFailComplete())
		end)
	end
end

function Rx.mapTo(...)
	local v8 = table.pack(...)
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			return object:Subscribe(function()
				object2:Fire(table.unpack(v8, 1, v8.n))
			end, object2:GetFailComplete())
		end)
	end
end

function Rx.map(callback)
	assert(type(callback) == "function", "Bad project callback")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			return object:Subscribe(function(...)
				object2:Fire(callback(...))
			end, object2:GetFailComplete())
		end)
	end
end

function Rx.mergeAll()
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = 0
			local v9 = false

			maid:GiveTask(object:Subscribe(function(object3)
				assert(v2.isObservable(object3), "Not an observable")

				v8 += 1

				local maid2 = v.new()

				maid2:GiveTask(object3:Subscribe(function(...)
					object2:Fire(...)
				end, function(...)
					object2:Fail(...)
				end, function()
					maid2:DoCleaning()
					v8 -= 1

					if v8 == 0 and v9 then
						object2:Complete()
						maid:DoCleaning()
					end
				end))

				local v10 = maid:GiveTask(maid2)

				maid2:GiveTask(function()
					maid[v10] = nil
				end)
			end, function(...)
				object2:Fail(...)
				maid:DoCleaning()
			end, function()
				v9 = true

				if v8 == 0 then
					object2:Complete()
					maid:DoCleaning()
				end
			end))

			return maid
		end)
	end
end

function Rx.switchAll()
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()
			local v8 = false
			local v9 = false
			local v10 = nil

			maid:GiveTask(function()
				maid._innerSub = nil
				maid._outerSuber = nil
			end)

			maid._outerSuber = object:Subscribe(function(object3)
				assert(v2.isObservable(object3), "Bad observable")

				v9 = false
				v10 = object3
				maid._innerSub = nil

				local innerSub = object3:Subscribe(function(...)
					if v10 == object3 then
						object2:Fire(...)
					else
						warn(string.format(
							"[Rx.switchAll] - Observable is still firing despite disconnect (%q)",
							object3._source
						))
					end
				end, function(...)
					if v10 == object3 then
						object2:Fail(...)
					end
				end, function()
					if v10 == object3 then
						v9 = true

						if v9 and v8 then
							object2:Complete()
							maid:DoCleaning()
						end
					end
				end)

				if v10 == object3 then
					maid._innerSub = innerSub
				else
					innerSub:Destroy()
				end
			end, function(...)
				object2:Fail(...)
				maid:DoCleaning()
			end, function()
				v8 = true

				if v9 and v8 then
					object2:Complete()
					maid:DoCleaning()
				end
			end)

			return maid
		end)
	end
end

function Rx.flatMap(callback, callback2)
	assert(type(callback) == "function", "Bad project")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = 0
			local v9 = false

			maid:GiveTask(object:Subscribe(function(...)
				local v10 = ...

				local v11 = callback(...)
				assert(v2.isObservable(v11), "Bad observable from project")

				v8 += 1

				local maid2 = v.new()

				local v12 = maid2:Add(v11:Subscribe(function(...)
					if callback2 then
						object2:Fire(callback2(v10, ...))
					else
						object2:Fire(...)
					end
				end, function(...)
					object2:Fail(...)
				end, function()
					maid2:DoCleaning()
					v8 -= 1

					if v8 == 0 and v9 then
						object2:Complete()
						maid:DoCleaning()
					end
				end))

				if not v12:IsPending() then
					v12:Destroy()

					return
				end

				local v13 = maid:GiveTask(maid2)

				maid2:GiveTask(function()
					maid[v13] = nil
				end)
			end, function(...)
				object2:Fail(...)
				maid:DoCleaning()
			end, function()
				v9 = true

				if v8 == 0 then
					object2:Complete()
					maid:DoCleaning()
				end
			end))

			return maid
		end)
	end
end

function Rx.switchMap(p)
	return Rx.pipe({ Rx.map(p), Rx.switchAll() })
end

function Rx.takeUntil(object)
	assert(v2.isObservable(object))

	return function(object2)
		assert(v2.isObservable(object2), "Bad observable")

		return v2.new(function(object3)
			local maid = v.new()
			local flag = false

			local function cancel()
				maid:DoCleaning()
				flag = true
			end

			maid:GiveTask(object:Subscribe(cancel, cancel, nil))

			if flag then
				maid:DoCleaning()
				return nil
			end

			maid:GiveTask(object2:Subscribe(object3:GetFireFailComplete()))

			return maid
		end)
	end
end

function Rx.packed(...)
	local v8 = table.pack(...)

	return v2.new(function(object)
		object:Fire(unpack(v8, 1, v8.n))
		object:Complete()
	end)
end

function Rx.unpacked(object)
	assert(v2.isObservable(object), "Bad observable")

	return v2.new(function(object2)
		return object:Subscribe(function(list)
			if type(list) == "table" then
				object2:Fire(unpack(list))
			else
				warn(("[Rx.unpacked] - Observable didn't return a table got type %q"):format((type(list))))
			end
		end, object2:GetFailComplete())
	end)
end

function Rx.finalize(callback)
	assert(type(callback) == "function", "Bad finalizerCallback")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			maid:GiveTask(object:Subscribe(object2:GetFireFailComplete()))
			maid:GiveTask(callback)

			return maid
		end)
	end
end

function Rx.combineLatestAll()
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local v8 = {}
			local maid = v.new()

			local v9 = true
			maid:GiveTask(function()
				v9 = false
			end)

			maid:GiveTask(object:Subscribe(function(p)
				assert(v2.isObservable(p))

				table.insert(v8, p)
			end, function(...)
				object2:Fail(...)
			end), function()
				if not v9 then
					return
				end

				maid:GiveTask(Rx.combineLatest(v8)):Subscribe(object2:GetFireFailComplete())
			end)

			return maid
		end)
	end
end

Rx.combineAll = Rx.combineLatestAll

function Rx.catchError(callback)
	assert(type(callback) == "function", "Bad callback")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = true
			maid:GiveTask(function()
				v8 = false
			end)

			maid:GiveTask(object:Subscribe(function(...)
				object2:Fire(...)
			end, function(...)
				if not v8 then
					return
				end

				local v9 = callback(...)
				assert(v2.isObservable(v9), "Bad observable")

				maid:GiveTask(v9:Subscribe(object2:GetFireFailComplete()))
			end, function()
				object2:Complete()
			end))

			return maid
		end)
	end
end

function Rx.combineLatest(items)
	assert(type(items) == "table", "Bad observables")
	local count = 0
	local v8 = {}

	for k, item in pairs(items) do
		if v2.isObservable(item) then
			count += 1
			v8[k] = named
		else
			v8[k] = item
		end
	end

	return v2.new(function(object)
		local v9 = count
		local clone = table.clone(v8)

		if v9 == 0 then
			object:Fire(clone)
			object:Complete()
		else
			local maid = v.new()

			local function fireIfAllSet() -- 1 equivalent call inferred from this helper
				for _, v10 in pairs(clone) do
					if v10 == named then
						return
					end
				end

				object:Fire(table.clone(clone))
			end

			for k, item in pairs(items) do
				if v2.isObservable(item) then
					maid:GiveTask(item:Subscribe(function(p)
						clone[k] = p
						fireIfAllSet() -- inferred equivalent call
					end, function(...)
						v9 -= 1
						object:Fail(...)
					end, function()
						v9 -= 1

						if v9 == 0 then
							object:Complete()
						end
					end))
				end
			end

			return maid
		end
	end)
end

function Rx.using(callback, callback2)
	return v2.new(function(object)
		local maid = v.new()

		local v8 = callback()
		maid:GiveTask(v8)

		local v9 = callback2(v8)
		assert(v2.isObservable(v9), "Bad observable")

		maid:GiveTask(v9:Subscribe(object:GetFireFailComplete()))

		return maid
	end)
end

function Rx.first()
	return Rx.take(1)
end

function Rx.take(value)
	assert(type(value) == "number", "Bad number")
	assert(value > 0, "Bad number")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local count = 0
			local v8 = v.new()

			v8._sub = object:Subscribe(function(...)
				if value <= count then
					warn("[Rx.take] - Still getting values past subscription")
					return
				end

				count += 1
				object2:Fire(...)

				if value <= count then
					object2:Complete()

					v8._sub = nil
				end
			end, object2:GetFailComplete())

			return v8
		end)
	end
end

function Rx.skip(value)
	assert(type(value) == "number", "Bad toSkip")
	assert(value > 0, "Bad toSkip")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local count = 0
			local maid = v.new()

			maid:GiveTask(object:Subscribe(function(...)
				if count < value then
					count += 1
				else
					object2:Fire(...)
				end
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

function Rx.defer(callback)
	return v2.new(function(object)
		local v8 = nil
		local success, result = pcall(function()
			v8 = callback()
		end)

		if not success then
			object:Fail(result)
			return
		end

		if v2.isObservable(v8) then
			return v8:Subscribe(object:GetFireFailComplete())
		end

		object:Fail("Not an observable")
	end)
end

function Rx.delay(value)
	assert(type(value) == "number", "Bad seconds")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			maid:GiveTask(object:Subscribe(function(...)
				local v8 = table.pack(...)

				maid[v8] = v6(value, function()
					maid[v8] = nil
					object2:Fire(table.unpack(v8, 1, v8.n))
				end)
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

function Rx.delayed(duration)
	assert(type(duration) == "number", "Bad seconds")

	return v2.new(function(object)
		return task.delay(duration, function()
			object:Fire()
		end)
	end)
end

function Rx.timer(duration, duration2)
	assert(type(duration) == "number" or duration == nil, "Bad initialDelaySeconds")
	assert(type(duration2) == "number", "Bad seconds")

	return v2.new(function(object)
		local maid = v.new()

		local v8 = -1

		maid:GiveTask(task.spawn(function()
			if duration and duration > 0 then
				task.wait(duration)
			end

			while true do
				v8 += 1
				object:Fire(v8)
				task.wait(duration2)
			end
		end))

		return maid
	end)
end

function Rx.interval(value)
	assert(type(value) == "number", "Bad seconds")

	return Rx.timer(0, value)
end

function Rx.withLatestFrom(items)
	assert(items, "Bad inputObservables")

	for _, item in pairs(items) do
		assert(v2.isObservable(item), "Bad observable")
	end

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = {}

			for k, item in pairs(items) do
				v8[k] = named

				maid:GiveTask(item:Subscribe(function(p)
					v8[k] = p
				end, nil, nil))
			end

			maid:GiveTask(object:Subscribe(function(p)
				for _, v9 in pairs(v8) do
					if v9 == named then
						return
					end
				end

				object2:Fire({ p, unpack(v8) })
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

function Rx.throttleTime(value, p)
	assert(type(value) == "number", "Bad duration")
	assert(type(p) == "table" or p == nil, "Bad throttleConfig")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = v5.new(value, function(...)
				object2:Fire(...)
			end, p)

			maid:GiveTask(v8)
			maid:GiveTask(object:Subscribe(function(...)
				v8:Call(...)
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

function Rx.onlyAfterDefer()
	return function(object)
		return v2.new(function(object2)
			local flag = false
			task.defer(function()
				flag = true
			end)

			return object:Subscribe(function(...)
				if flag then
					object2:Fire(...)
				end
			end, object2:GetFailComplete())
		end)
	end
end

function Rx.throttleDefer()
	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = nil

			maid:GiveTask(object:Subscribe(function(...)
				if v8 then
					v8 = table.pack(...)

					return
				end

				v8 = table.pack(...)

				maid._currentQueue = task.defer(function()
					local v9 = v8
					v8 = nil

					if object2:IsPending() then
						object2:Fire(table.unpack(v9, 1, v9.n))
					end
				end)
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

function Rx.throttle(callback)
	assert(type(callback) == "function", "Bad durationSelector")

	return function(object)
		assert(v2.isObservable(object), "Bad observable")

		return v2.new(function(object2)
			local maid = v.new()

			local v8 = nil

			maid:GiveTask(object:Subscribe(function(...)
				if v8 then
					v8 = table.pack(...)

					return
				end

				v8 = table.pack(...)

				local maid2 = v.new()

				maid2:GiveTask(callback(v8):Subscribe(function()
					local v9 = v8
					v8 = nil

					if object2:IsPending() then
						object2:Fire(table.unpack(v9, 1, v9.n))
					end

					if maid._currentQueue == maid2 then
						maid._currentQueue = nil
					end
				end))

				maid._currentQueue = maid2
			end, object2:GetFailComplete()))

			return maid
		end)
	end
end

return Rx