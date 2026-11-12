local AccelTween = {}

function AccelTween.new(value: number?)
	return (setmetatable({
		_accel = value or 1,
		_t0 = 0,
		_y0 = 0,
		_a0 = 0,
		_t1 = 0,
		_y1 = 0,
		_a1 = 0
	}, AccelTween))
end

function AccelTween:__index(p)
	if AccelTween[p] then
		return AccelTween[p]
	end

	if p == "p" then
		local state, _ = self:_getState(os.clock())
		return state
	elseif p == "v" then
		local _, v = self:_getState(os.clock())
		return v
	elseif p == "a" then
		return self._accel
	elseif p == "t" then
		return self._y1
	end

	if p == "rtime" then
		local now = os.clock()
		return now < self._t1 and self._t1 - now or 0
	end

	error(string.format("Bad index %q", (tostring(p))))
end

function AccelTween:__newindex(p, p2)
	if p == "p" then
		self:_setState(p2, nil, nil, nil)
	elseif p == "v" then
		self:_setState(nil, p2, nil, nil)
	elseif p == "a" then
		self:_setState(nil, nil, p2, nil)
	elseif p == "t" then
		self:_setState(nil, nil, nil, p2)
	elseif p == "pt" then
		self:_setState(p2, 0, nil, p2)
	else
		error(string.format("Bad index %q", (tostring(p))))
	end
end

function AccelTween:_getState(p)
	if p < (self._t0 + self._t1) / 2 then
		local v = p - self._t0
		return self._y0 + v * v / 2 * self._a0, v * self._a0
	end

	if p < self._t1 then
		local v = p - self._t1
		return self._y1 + v * v / 2 * self._a1, v * self._a1
	end

	return self._y1, 0
end

function AccelTween:_setState(p, p2, p3, p4)
	local now = os.clock()
	local state, v = self:_getState(now)
	local y0 = p or state
	local v2 = p2 or v
	self._accel = p3 or self._accel
	local y1 = p4 or self._y1

	if self._accel * self._accel < 1e-8 then
		self._t0 = 0
		self._y0 = y0
		self._a0 = 0
		self._t1 = 1e999
		self._y1 = y1
		self._a1 = 0
	else
		local v3 = y1 < y0
		local v4 = v2 < 0
		local v5 = y0 - v2 * v2 / (2 * self._accel) < y1
		local v6 = y0 + v2 * v2 / (2 * self._accel) < y1

		if v3 and v4 and v5 or not v3 and (v4 or not v4 and v6) then
			self._a0 = self._accel
			self._t1 = now + ((2 * v2 * v2 + 4 * self._accel * (y1 - y0)) ^ 0.5 - v2) / self._accel
		else
			self._a0 = -self._accel
			self._t1 = now + ((2 * v2 * v2 - 4 * self._accel * (y1 - y0)) ^ 0.5 + v2) / self._accel
		end

		self._t0 = now - v2 / self._a0
		self._y0 = y0 - v2 * v2 / (2 * self._a0)
		self._y1 = y1
		self._a1 = -self._a0
	end
end

return AccelTween