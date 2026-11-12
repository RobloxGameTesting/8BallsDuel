local util = {
	["pack"] = table.pack or function(...)
		return {
			n = select("#", ...),
			...
		}
	end,
	unpack = table.unpack or unpack,
	eq = function(p, p2): boolean
		return p == p2
	end,
	noop = function() end,
	identity = function(p)
		return p
	end,
	constant = function(p)
		return function()
			return p
		end
	end,
	isa = function(p, p2): boolean
		return type(p) == "table" and getmetatable(p).__index == p2
	end,
	tryWithObserver = function(object, callback, ...)
		local success, result = pcall(callback, ...)

		if not success then
			object:onError(result)
		end

		return success, result
	end
}

local class = {}
class.__index = class
class.__tostring = util.constant("Subscription")

function class.create(p)
	return (setmetatable({
		action = p or util.noop,
		unsubscribed = false
	}, class))
end

function class:unsubscribe()
	if self.unsubscribed then
		return
	end

	self.action(self)
	self.unsubscribed = true
end

local class2 = {}
class2.__index = class2
class2.__tostring = util.constant("Observer")

function class2.create(p, p2, p3)
	return (setmetatable({
		_onNext = p or util.noop,
		_onError = p2 or error,
		_onCompleted = p3 or util.noop,
		stopped = false
	}, class2))
end

function class2:onNext(...)
	if not self.stopped then
		self._onNext(...)
	end
end

function class2:onError(p)
	if not self.stopped then
		self.stopped = true
		self._onError(p)
	end
end

function class2:onCompleted()
	if not self.stopped then
		self.stopped = true
		self._onCompleted()
	end
end

local class3 = {}
class3.__index = class3
class3.__tostring = util.constant("Observable")

function class3.create(subscribe)
	return (setmetatable({ _subscribe = subscribe }, class3))
end

function class3:subscribe(p, p2, p3)
	if type(p) == "table" then
		return self._subscribe(p)
	end

	return self._subscribe(class2.create(p, p2, p3))
end

function class3.empty()
	return class3.create(function(object)
		object:onCompleted()
	end)
end

function class3.never()
	return class3.create(function(_) end)
end

function class3.throw(p)
	return class3.create(function(object)
		object:onError(p)
	end)
end

function class3.of(...)
	local v = { ... }
	local v2 = select("#", ...)
	return class3.create(function(object)
		for i = 1, v2 do
			object:onNext(v[i])
		end

		object:onCompleted()
	end)
end

function class3.fromRange(p, p2, value)
	if not (p2 or value) then
		p2 = p
		p = 1
	end

	local v = value or 1

	return class3.create(function(object)
		for i = p, p2, v do
			object:onNext(i)
		end

		object:onCompleted()
	end)
end

function class3.fromTable(p, p2, p3)
	local v = p2 or pairs
	return class3.create(function(object)
		for k, v2 in v(p) do
			object:onNext(v2, p3 and k or nil)
		end

		object:onCompleted()
	end)
end

function class3.fromCoroutine(callback, object)
	return class3.create(function(object2)
		local thread = type(callback) == "function" and coroutine.create(callback) or callback
		return object:schedule(function()
			while not object2.stopped do
				local v, v2 = coroutine.resume(thread)

				if not v then
					return object2:onError(v2)
				end

				object2:onNext(v2)

				if coroutine.status(thread) == "dead" then
					return object2:onCompleted()
				end

				coroutine.yield()
			end
		end)
	end)
end

function class3.fromFileByLine(p)
	return class3.create(function(object)
		local v = io.open(p, "r")

		if not v then
			return object:onError(p)
		end

		v:close()

		for k in io.lines(p) do
			object:onNext(k)
		end

		return object:onCompleted()
	end)
end

function class3.defer(callback)
	if not callback or type(callback) ~= "function" then
		error("Expected a function")
	end

	return (setmetatable({
		subscribe = function(_, ...)
			return callback():subscribe(...)
		end
	}, class3))
end

function class3.replicate(p, p2)
	return class3.create(function(object)
		while p2 == nil or p2 > 0 do
			object:onNext(p)

			if p2 then
				p2 -= 1
			end
		end

		object:onCompleted()
	end)
end

function class3:dump(p, p2)
	local v = p and p .. " " or ""
	local v2 = p2 or tostring

	return self:subscribe(function(...)
		print(v .. "onNext: " .. v2(...))
	end, function(p3)
		print(v .. "onError: " .. p3)
	end, function()
		print(v .. "onCompleted")
	end)
end

function class3:all(p)
	local v = p or util.identity

	return class3.create(function(object)
		local function onNext(...)
			util.tryWithObserver(object, function(...)
				if not v(...) then
					object:onNext(false)
					object:onCompleted()
				end
			end, ...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			object:onNext(true)
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:amb(object, ...)
	if self and object then
		return class3.create(function(object2)
			local v = nil
			local v2 = nil

			local function onNextA(...)
				if v2 then
					v2:unsubscribe()
				end

				object2:onNext(...)
			end

			local function onErrorA(p)
				if v2 then
					v2:unsubscribe()
				end

				object2:onError(p)
			end

			local function onCompletedA()
				if v2 then
					v2:unsubscribe()
				end

				object2:onCompleted()
			end

			local function onNextB(...)
				if v then
					v:unsubscribe()
				end

				object2:onNext(...)
			end

			local function onErrorB(p)
				if v then
					v:unsubscribe()
				end

				object2:onError(p)
			end

			local function onCompletedB()
				if v then
					v:unsubscribe()
				end

				object2:onCompleted()
			end

			v = self:subscribe(onNextA, onErrorA, onCompletedA)
			v2 = object:subscribe(onNextB, onErrorB, onCompletedB)

			return class.create(function()
				v:unsubscribe()
				v2:unsubscribe()
			end)
		end):amb(...)
	end

	return self
end

function class3:average()
	return class3.create(function(object)
		local total = 0
		local count = 0

		local function onNext(p)
			total += p
			count += 1
		end

		local function onError(p)
			object:onError(p)
		end

		local function onCompleted()
			if count > 0 then
				object:onNext(total / count)
			end

			object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:buffer(value)
	if not value or type(value) ~= "number" then
		error("Expected a number")
	end

	return class3.create(function(object)
		local v = {}

		local function emit() -- 3 equivalent calls inferred from this helper
			if #v > 0 then
				object:onNext(util.unpack(v))
				v = {}
			end
		end

		local function onNext(...)
			local v2 = { ... }

			for i = 1, #v2 do
				table.insert(v, v2[i])

				if value <= #v then
					emit() -- inferred equivalent call
				end
			end
		end

		local function onError(p)
			emit() -- inferred equivalent call
			return object:onError(p)
		end

		local function onCompleted()
			emit() -- inferred equivalent call
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:catch(callback)
	local v = callback and (type(callback) == "function" and callback or util.constant(callback))

	return class3.create(function(object)
		local v2 = nil

		local function onNext(...)
			return object:onNext(...)
		end

		local function onError(p)
			if not v then
				return object:onCompleted()
			end

			local success, result = pcall(v, p)

			if success and result then
				if v2 then
					v2:unsubscribe()
				end

				result:subscribe(object)
			else
				result = success and p or result
				object:onError(result)
			end
		end

		local function onCompleted()
			object:onCompleted()
		end

		v2 = self:subscribe(onNext, onError, onCompleted)
		return v2
	end)
end

function class3.combineLatest(p, ...)
	local v = { ... }
	local v2 = table.remove(v)

	if type(v2) ~= "function" then
		table.insert(v, v2)
		v2 = function(...)
			return ...
		end
	end

	table.insert(v, 1, p)

	return class3.create(function(object)
		local v3 = {}
		local v4 = { util.unpack(v) }
		local v5 = {}

		local function onNext(i) -- 1 equivalent call inferred from this helper
			return function(p2)
				v3[i] = p2
				v4[i] = nil

				if not next(v4) then
					util.tryWithObserver(object, function()
						object:onNext(v2(util.unpack(v3)))
					end)
				end
			end
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted(i) -- 1 equivalent call inferred from this helper
			return function()
				table.insert(v5, i)

				if #v5 == #v then
					object:onCompleted()
				end
			end
		end

		local v6 = {}

		for i = 1, #v do
			v6[i] = v[i]:subscribe(onNext(i), onError, onCompleted(i)) -- inferred equivalent call
		end

		return class.create(function()
			for i = 1, #v do
				if v6[i] then
					v6[i]:unsubscribe()
				end
			end
		end)
	end)
end

function class3:compact()
	return self:filter(util.identity)
end

function class3:concat(object, ...)
	if not object then
		return self
	end

	local v = { ... }

	return class3.create(function(object2)
		local function onNext(...)
			return object2:onNext(...)
		end

		local function onError(p)
			return object2:onError(p)
		end

		local function onCompleted()
			return object2:onCompleted()
		end

		local function chain()
			return object:concat(util.unpack(v)):subscribe(onNext, onError, onCompleted)
		end

		return self:subscribe(onNext, onError, chain)
	end)
end

function class3:contains(p)
	return class3.create(function(object)
		local v = nil

		local function onNext(...)
			local pack = util.pack(...)

			if #pack == 0 and p == nil then
				object:onNext(true)

				if v then
					v:unsubscribe()
				end

				return object:onCompleted()
			end

			for i = 1, #pack do
				if pack[i] == p then
					object:onNext(true)

					if v then
						v:unsubscribe()
					end

					return object:onCompleted()
				end
			end
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			object:onNext(false)
			return object:onCompleted()
		end

		v = self:subscribe(onNext, onError, onCompleted)
		return v
	end)
end

function class3:count(p)
	local v = p or util.constant(true)

	return class3.create(function(object)
		local count = 0

		local function onNext(...)
			util.tryWithObserver(object, function(...)
				if v(...) then
					count += 1
				end
			end, ...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			object:onNext(count)
			object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:debounce(value, object)
	local v = value or 0

	return class3.create(function(p)
		local v2 = {}

		local function wrap(p2) -- 3 equivalent calls inferred from this helper
			return function(...)
				util.pack(...)

				if v2[p2] then
					v2[p2]:unsubscribe()
				end

				local pack = util.pack(...)

				v2[p2] = object:schedule(function()
					return p[p2](p, util.unpack(pack))
				end, v)
			end
		end

		local v3 = self:subscribe(wrap("onNext"), wrap("onError"), wrap("onCompleted")) -- inferred equivalent call

		return class.create(function()
			if v3 then
				v3:unsubscribe()
			end

			for _, v4 in pairs(v2) do
				v4:unsubscribe()
			end
		end)
	end)
end

function class3:defaultIfEmpty(...)
	local pack = util.pack(...)

	return class3.create(function(object)
		local v = false

		local function onNext(...)
			v = true
			object:onNext(...)
		end

		local function onError(p)
			object:onError(p)
		end

		local function onCompleted()
			if not v then
				object:onNext(util.unpack(pack))
			end

			object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:delay(callback, object)
	callback = type(callback) ~= "function" and util.constant(callback) or callback

	return class3.create(function(p)
		local v = {}

		local function delay(p2) -- 3 equivalent calls inferred from this helper
			return function(...)
				local pack = util.pack(...)
				local v2 = object:schedule(function()
					p[p2](p, util.unpack(pack))
				end, callback())
				table.insert(v, v2)
			end
		end

		local v2 = self:subscribe(delay("onNext"), delay("onError"), delay("onCompleted")) -- inferred equivalent call

		return class.create(function()
			if v2 then
				v2:unsubscribe()
			end

			for i = 1, #v do
				v[i]:unsubscribe()
			end
		end)
	end)
end

function class3:distinct()
	return class3.create(function(object)
		local set = {}

		local function onNext(p)
			if not set[p] then
				object:onNext(p)
			end

			set[p] = true
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:distinctUntilChanged(p)
	local v = p or util.eq

	return class3.create(function(object)
		local v2 = true
		local v3 = nil

		local function onNext(p2, ...)
			local pack = util.pack(...)
			util.tryWithObserver(object, function()
				if v2 or not v(p2, v3) then
					object:onNext(p2, util.unpack(pack))
					v3 = p2
					v2 = false
				end
			end)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:elementAt(value)
	if not value or type(value) ~= "number" then
		error("Expected a number")
	end

	return class3.create(function(object)
		local v = nil
		local v2 = 1

		local function onNext(...)
			if v2 == value then
				object:onNext(...)
				object:onCompleted()

				if v then
					v:unsubscribe()
				end
			else
				v2 += 1
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		v = self:subscribe(onNext, onError, onCompleted)
		return v
	end)
end

function class3:filter(p)
	local v = p or util.identity

	return class3.create(function(object)
		local function onNext(...)
			util.tryWithObserver(object, function(...)
				if v(...) then
					return object:onNext(...)
				end
			end, ...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:find(p)
	local v = p or util.identity

	return class3.create(function(object)
		local function onNext(...)
			util.tryWithObserver(object, function(...)
				if not v(...) then
					return
				end

				object:onNext(...)
				return object:onCompleted()
			end, ...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:first()
	return self:take(1)
end

function class3:flatMap(p)
	return self:map(p or util.identity):flatten()
end

function class3:flatMapLatest(p)
	local v = p or util.identity
	return class3.create(function(object)
		local v2 = nil

		local function onNext(...)
			object:onNext(...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		local function subscribeInner(...)
			if v2 then
				v2:unsubscribe()
			end

			return util.tryWithObserver(object, function(...)
				v2 = v(...):subscribe(onNext, onError)
			end, ...)
		end

		local v3 = self:subscribe(subscribeInner, onError, onCompleted)
		return class.create(function()
			if v2 then
				v2:unsubscribe()
			end

			if v3 then
				v3:unsubscribe()
			end
		end)
	end)
end

function class3:flatten()
	return class3.create(function(object)
		local v = {}
		local v2 = 1

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			v2 -= 1

			if v2 == 0 then
				return object:onCompleted()
			end
		end

		local function onNext(object2)
			local function innerOnNext(...)
				object:onNext(...)
			end

			v2 += 1
			local v3 = object2:subscribe(innerOnNext, onError, onCompleted)
			v[#v + 1] = v3
		end

		v[#v + 1] = self:subscribe(onNext, onError, onCompleted)
		return class.create(function()
			for i = 1, #v do
				v[i]:unsubscribe()
			end
		end)
	end)
end

function class3:ignoreElements()
	return class3.create(function(object)
		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(nil, onError, onCompleted)
	end)
end

function class3:last()
	return class3.create(function(object)
		local v = nil
		local v2 = true

		local function onNext(...)
			v = { ... }
			v2 = false
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			if not v2 then
				object:onNext(util.unpack(v or {}))
			end

			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:map(callback)
	return class3.create(function(object)
		callback = callback or util.identity

		local function onNext(...)
			return util.tryWithObserver(object, function(...)
				return object:onNext(callback(...))
			end, ...)
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:max()
	return self:reduce(math.max)
end

function class3.merge(p, ...)
	local v = { ... }
	table.insert(v, 1, p)

	return class3.create(function(object)
		local v2 = {}

		local function onNext(...)
			return object:onNext(...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted(i) -- 1 equivalent call inferred from this helper
			return function()
				table.insert(v2, i)

				if #v2 == #v then
					object:onCompleted()
				end
			end
		end

		local v3 = {}

		for i = 1, #v do
			v3[i] = v[i]:subscribe(onNext, onError, onCompleted(i)) -- inferred equivalent call
		end

		return class.create(function()
			for i = 1, #v do
				if v3[i] then
					v3[i]:unsubscribe()
				end
			end
		end)
	end)
end

function class3:min()
	return self:reduce(math.min)
end

function class3:pack()
	return self:map(util.pack)
end

function class3:partition(p)
	return self:filter(p), self:reject(p)
end

function class3:pluck(value, ...)
	if not value then
		return self
	end

	if type(value) == "string" or type(value) == "number" then
		return class3.create(function(object)
			local function onNext(p)
				return object:onNext(p[value])
			end

			local function onError(p)
				return object:onError(p)
			end

			local function onCompleted()
				return object:onCompleted()
			end

			return self:subscribe(onNext, onError, onCompleted)
		end):pluck(...)
	end

	return class3.throw("pluck key must be a string")
end

function class3:reduce(callback, p)
	return class3.create(function(object)
		local v = p
		local v2 = true

		local function onNext(...)
			if not v2 or p ~= nil then
				return util.tryWithObserver(object, function(...)
					v = callback(v, ...)
				end, ...)
			end

			v = ...
			v2 = false
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			object:onNext(v)
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:reject(p)
	local v = p or util.identity

	return class3.create(function(object)
		local function onNext(...)
			util.tryWithObserver(object, function(...)
				if v(...) then
					return
				end

				return object:onNext(...)
			end, ...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:retry(p)
	return class3.create(function(object)
		local v = nil
		local count = 0

		local function onNext(...)
			return object:onNext(...)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		local function onError(p2)
			if v then
				v:unsubscribe()
			end

			count += 1

			if p and p < count then
				return object:onError(p2)
			end

			v = self:subscribe(onNext, onError, onCompleted)
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:sample(object)
	if not object then
		error("Expected an Observable")
	end

	return class3.create(function(object2)
		local v = {}

		local function setLatest(...)
			v = util.pack(...)
		end

		local function onNext()
			if #v > 0 then
				return object2:onNext(util.unpack(v))
			end
		end

		local function onError(p)
			return object2:onError(p)
		end

		local function onCompleted()
			return object2:onCompleted()
		end

		local v2 = self:subscribe(setLatest, onError)
		local v3 = object:subscribe(onNext, onError, onCompleted)

		return class.create(function()
			if v2 then
				v2:unsubscribe()
			end

			if v3 then
				v3:unsubscribe()
			end
		end)
	end)
end

function class3:scan(callback, p)
	return class3.create(function(object)
		local v = p
		local v2 = true

		local function onNext(...)
			if not v2 or p ~= nil then
				return util.tryWithObserver(object, function(...)
					v = callback(v, ...)
					object:onNext(v)
				end, ...)
			end

			v = ...
			v2 = false
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:skip(value)
	local v = value or 1

	return class3.create(function(object)
		local v2 = 1

		local function onNext(...)
			if v < v2 then
				object:onNext(...)
			else
				v2 += 1
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:skipLast(value)
	if not value or type(value) ~= "number" then
		error("Expected a number")
	end

	local v = {}
	return class3.create(function(object)
		local function emit() -- 2 equivalent calls inferred from this helper
			if value < #v and v[1] then
				local v2 = table.remove(v, 1)
				object:onNext(util.unpack(v2))
			end
		end

		local function onNext(...)
			emit() -- inferred equivalent call
			table.insert(v, util.pack(...))
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			emit() -- inferred equivalent call
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:skipUntil(object)
	return class3.create(function(object2)
		local flag = false
		local function trigger()
			flag = true
		end

		object:subscribe(trigger, trigger, trigger)

		local function onNext(...)
			if flag then
				object2:onNext(...)
			end
		end

		local function onError()
			if flag then
				object2:onError()
			end
		end

		local function onCompleted()
			if flag then
				object2:onCompleted()
			end
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:skipWhile(p)
	local v = p or util.identity

	return class3.create(function(object)
		local v2 = true

		local function onNext(...)
			if v2 then
				util.tryWithObserver(object, function(...)
					v2 = v(...)
				end, ...)
			end

			if v2 then
				return
			end

			return object:onNext(...)
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:startWith(...)
	local pack = util.pack(...)
	return class3.create(function(object)
		object:onNext(util.unpack(pack))
		return self:subscribe(object)
	end)
end

function class3:sum()
	return self:reduce(function(p, p2)
		return p + p2
	end, 0)
end

function class3:switch()
	return class3.create(function(object)
		local v = nil

		local function onNext(...)
			return object:onNext(...)
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		local function switch(object2)
			if v then
				v:unsubscribe()
			end

			v = object2:subscribe(onNext, onError, nil)
		end

		local v2 = self:subscribe(switch, onError, onCompleted)
		return class.create(function()
			if v then
				v:unsubscribe()
			end

			if v2 then
				v2:unsubscribe()
			end
		end)
	end)
end

function class3:take(value)
	local v = value or 1

	return class3.create(function(object)
		if v <= 0 then
			object:onCompleted()
			return
		end

		local v2 = 1

		local function onNext(...)
			object:onNext(...)

			v2 += 1

			if v < v2 then
				object:onCompleted()
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:takeLast(value)
	if not value or type(value) ~= "number" then
		error("Expected a number")
	end

	return class3.create(function(object)
		local v = {}

		local function onNext(...)
			table.insert(v, util.pack(...))

			if value < #v then
				table.remove(v, 1)
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			for i = 1, #v do
				object:onNext(util.unpack(v[i]))
			end

			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:takeUntil(object)
	return class3.create(function(object2)
		local function onNext(...)
			return object2:onNext(...)
		end

		local function onError(p)
			return object2:onError(p)
		end

		local function onCompleted()
			return object2:onCompleted()
		end

		object:subscribe(onCompleted, onCompleted, onCompleted)

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:takeWhile(p)
	local v = p or util.identity

	return class3.create(function(object)
		local v2 = true

		local function onNext(...)
			if not v2 then
				return
			end

			util.tryWithObserver(object, function(...)
				v2 = v(...)
			end, ...)

			if v2 then
				return object:onNext(...)
			end

			return object:onCompleted()
		end

		local function onError(p2)
			return object:onError(p2)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:tap(p, p2, p3)
	local v = p or util.noop
	local v2 = p2 or util.noop
	local v3 = p3 or util.noop

	return class3.create(function(object)
		local function onNext(...)
			util.tryWithObserver(object, function(...)
				v(...)
			end, ...)

			return object:onNext(...)
		end

		local function onError(p4)
			util.tryWithObserver(object, function()
				v2(p4)
			end)

			return object:onError(p4)
		end

		local function onCompleted()
			util.tryWithObserver(object, function()
				v3()
			end)

			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:unpack()
	return self:map(util.unpack)
end

function class3:unwrap()
	return class3.create(function(object)
		local function onNext(...)
			local v = { ... }

			for i = 1, #v do
				object:onNext(v[i])
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:window(value)
	if not value or type(value) ~= "number" then
		error("Expected a number")
	end

	return class3.create(function(object)
		local v = {}

		local function onNext(p)
			table.insert(v, p)

			if value <= #v then
				object:onNext(util.unpack(v))
				table.remove(v, 1)
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		return self:subscribe(onNext, onError, onCompleted)
	end)
end

function class3:with(...)
	local v = { ... }

	return class3.create(function(object)
		local object2 = setmetatable({}, {
			__len = util.constant(#v)
		})

		local function setLatest(i) -- 1 equivalent call inferred from this helper
			return function(p)
				object2[i] = p
			end
		end

		local function onNext(p)
			return object:onNext(p, util.unpack(object2))
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted()
			return object:onCompleted()
		end

		local v2 = {}

		for i = 1, #v do
			v2[i] = v[i]:subscribe(setLatest(i), util.noop, util.noop) -- inferred equivalent call
		end

		v2[#v + 1] = self:subscribe(onNext, onError, onCompleted)
		return class.create(function()
			for i = 1, #v + 1 do
				if v2[i] then
					v2[i]:unsubscribe()
				end
			end
		end)
	end)
end

function class3.zip(...)
	local pack = util.pack(...)
	local count = #pack

	return class3.create(function(object)
		local v = {}
		local v2 = {}
		local v3 = {}

		for i = 1, count do
			v[i] = { n = 0 }
			v2[i] = true
		end

		local function onNext(i) -- 1 equivalent call inferred from this helper
			return function(p)
				table.insert(v[i], p)
				v[i].n = v[i].n + 1
				local flag = true

				for j = 1, count do
					if v[j].n == 0 then
						flag = false
						break
					end
				end

				if flag then
					local v4 = {}

					for j = 1, count do
						v4[j] = table.remove(v[j], 1)
						v[j].n = v[j].n - 1
					end

					object:onNext(util.unpack(v4))
				end
			end
		end

		local function onError(p)
			return object:onError(p)
		end

		local function onCompleted(i) -- 1 equivalent call inferred from this helper
			return function()
				v2[i] = nil

				if next(v2) and v[i].n ~= 0 then
					return
				end

				return object:onCompleted()
			end
		end

		for i = 1, count do
			v3[i] = pack[i]:subscribe(onNext(i), onError, onCompleted(i)) -- inferred equivalent call
		end

		return class.create(function()
			for i = 1, count do
				if v3[i] then
					v3[i]:unsubscribe()
				end
			end
		end)
	end)
end

local class4 = {}
class4.__index = class4
class4.__tostring = util.constant("ImmediateScheduler")

function class4.create()
	return (setmetatable({}, class4))
end

function class4:schedule(callback)
	callback()
end

local class5 = {}
class5.__index = class5
class5.__tostring = util.constant("CooperativeScheduler")

function class5.create(value)
	return (setmetatable({
		tasks = {},
		currentTime = value or 0
	}, class5))
end

function class5:schedule(callback, value)
	local v = {
		thread = coroutine.create(callback),
		due = self.currentTime + (value or 0)
	}

	table.insert(self.tasks, v)

	return class.create(function()
		return self:unschedule(v)
	end)
end

function class5:unschedule(p)
	for i = 1, #self.tasks do
		if self.tasks[i] == p then
			table.remove(self.tasks, i)
		end
	end
end

function class5:update(value)
	self.currentTime += value or 0
	local v = 1

	while v <= #self.tasks do
		local task = self.tasks[v]

		if self.currentTime >= task.due then
			local v2, v3 = coroutine.resume(task.thread)

			if coroutine.status(task.thread) == "dead" then
				table.remove(self.tasks, v)
			else
				task.due = math.max(task.due + (v3 or 0), self.currentTime)
				v += 1
			end

			if not v2 then
				error(v3)
			end
		else
			v += 1
		end
	end
end

function class5.isEmpty(p): boolean
	return not next(p.tasks)
end

local class6 = {}
class6.__index = class6
class6.__tostring = util.constant("TimeoutScheduler")

function class6.create()
	return (setmetatable({}, class6))
end

function class6:schedule(p, p2, ...)
	local module = require("timer")

	local v = module.setTimeout(p2, p, ...)
	return class.create(function()
		module.clearTimeout(v)
	end)
end

local object = setmetatable({}, class3)
object.__index = object
object.__tostring = util.constant("Subject")

function object.create()
	return (setmetatable({ observers = {}, stopped = false }, object))
end

function object.subscribe(p, p2, p3, p4)
	if not util.isa(p2, class2) then
		p2 = class2.create(p2, p3, p4)
	end

	table.insert(p.observers, p2)

	return class.create(function()
		for i = 1, #p.observers do
			if p.observers[i] == p2 then
				table.remove(p.observers, i)
				break
			end
		end
	end)
end

function object.onNext(p, ...)
	if not p.stopped then
		for i = #p.observers, 1, -1 do
			p.observers[i]:onNext(...)
		end
	end
end

function object:onError(p)
	if not self.stopped then
		for i = #self.observers, 1, -1 do
			self.observers[i]:onError(p)
		end

		self.stopped = true
	end
end

function object:onCompleted()
	if not self.stopped then
		for i = #self.observers, 1, -1 do
			self.observers[i]:onCompleted()
		end

		self.stopped = true
	end
end

object.__call = object.onNext

local object2 = setmetatable({}, class3)
object2.__index = object2
object2.__tostring = util.constant("AsyncSubject")

function object2.create()
	return (setmetatable({ observers = {}, stopped = false, value = nil, errorMessage = nil }, object2))
end

function object2.subscribe(data, object3, p, p2)
	if not util.isa(object3, class2) then
		object3 = class2.create(object3, p, p2)
	end

	if data.value then
		object3:onNext(util.unpack(data.value))
		object3:onCompleted()
	else
		if not data.errorMessage then
			table.insert(data.observers, object3)

			return class.create(function()
				for i = 1, #data.observers do
					if data.observers[i] == object3 then
						table.remove(data.observers, i)
						break
					end
				end
			end)
		end

		object3:onError(data.errorMessage)
	end
end

function object2:onNext(...)
	if not self.stopped then
		self.value = util.pack(...)
	end
end

function object2:onError(errorMessage)
	if not self.stopped then
		self.errorMessage = errorMessage

		for i = 1, #self.observers do
			self.observers[i]:onError(self.errorMessage)
		end

		self.stopped = true
	end
end

function object2:onCompleted()
	if not self.stopped then
		for i = 1, #self.observers do
			if self.value then
				self.observers[i]:onNext(util.unpack(self.value))
			end

			self.observers[i]:onCompleted()
		end

		self.stopped = true
	end
end

object2.__call = object2.onNext

local object3 = setmetatable({}, object)
object3.__index = object3
object3.__tostring = util.constant("BehaviorSubject")

function object3.create(...)
	local v = { observers = {}, stopped = false }

	if select("#", ...) > 0 then
		v.value = util.pack(...)
	end

	return (setmetatable(v, object3))
end

function object3.subscribe(p, object4, p2, p3)
	if not util.isa(object4, class2) then
		object4 = class2.create(object4, p2, p3)
	end

	local v = object.subscribe(p, object4)

	if p.value then
		object4:onNext(util.unpack(p.value))
	end

	return v
end

function object3:onNext(...)
	self.value = util.pack(...)
	return object.onNext(self, ...)
end

function object3.getValue(p)
	if p.value == nil then
		return
	end

	return util.unpack(p.value)
end

object3.__call = object3.onNext

local object4 = setmetatable({}, object)
object4.__index = object4
object4.__tostring = util.constant("ReplaySubject")

function object4.create(bufferSize)
	return (setmetatable({ observers = {}, stopped = false, buffer = {}, bufferSize = bufferSize }, object4))
end

function object4.subscribe(p, object5, p2, p3)
	if not util.isa(object5, class2) then
		object5 = class2.create(object5, p2, p3)
	end

	local v = object.subscribe(p, object5)

	for i = 1, #p.buffer do
		object5:onNext(util.unpack(p.buffer[i]))
	end

	return v
end

function object4.onNext(p, ...)
	table.insert(p.buffer, util.pack(...))

	if p.bufferSize and #p.buffer > p.bufferSize then
		table.remove(p.buffer, 1)
	end

	return object.onNext(p, ...)
end

object4.__call = object4.onNext

class3.wrap = class3.buffer
class3["repeat"] = class3.replicate

return {
	util = util,
	Subscription = class,
	Observer = class2,
	Observable = class3,
	ImmediateScheduler = class4,
	CooperativeScheduler = class5,
	TimeoutScheduler = class6,
	Subject = object,
	AsyncSubject = object2,
	BehaviorSubject = object3,
	ReplaySubject = object4
}