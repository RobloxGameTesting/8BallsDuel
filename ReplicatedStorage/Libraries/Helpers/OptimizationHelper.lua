local OptimizationHelper = {}

function OptimizationHelper.EncodeVector3(data)
	local function encode(value) -- 3 equivalent calls inferred from this helper
		return (math.floor(math.clamp(value, -2048, 2048) / 2048 * 32767))
	end
	return { encode(data.X), encode(data.Y), encode(data.Z) } -- inferred equivalent call
end

function OptimizationHelper.DecodeVector3(list)
	local function decode(p: number) -- 3 equivalent calls inferred from this helper
		return p / 32767 * 2048
	end

	return (Vector3.new(decode(list[1]), decode(list[2]), decode(list[3]))) -- inferred equivalent call
end

return OptimizationHelper