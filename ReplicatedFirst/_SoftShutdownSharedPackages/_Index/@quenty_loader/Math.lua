local Math = {}

function Math.map(p: number, p2: number, p3: number, p4: number, p5: number)
	if p3 == p2 then
		error("Range of zero")
	end

	return (p - p2) * (p5 - p4) / (p3 - p2) + p4
end

function Math.jitter(p: number, p2: number?, p3: number?)
	local v = p3 or math.random()
	local v2 = p2 or p * 0.5

	return p - 0.5 * v2 + v * v2
end

function Math.isNaN(p: number): boolean
	return p ~= p
end

function Math.isFinite(p: number): boolean
	return p > -1e999 and p < 1e999
end

function Math.lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function Math.lawOfCosines(p: number, p2: number, p3: number)
	local v = math.acos((p * p + p2 * p2 - p3 * p3) / (p * 2 * p2))
	return if v == v then v else nil
end

function Math.round(p: number, p2: number?)
	if p2 then
		return math.floor(p / p2 + 0.5) * p2
	end

	return (math.floor(p + 0.5))
end

function Math.roundUp(p: number, p2: number)
	return math.ceil(p / p2) * p2
end

function Math.roundDown(p: number, p2: number)
	return math.floor(p / p2) * p2
end

return Math