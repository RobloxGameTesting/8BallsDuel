local PoolTrickshotCodes = {}
PoolTrickshotCodes.Length = 8

function PoolTrickshotCodes.Generate(p)
	local v = p or Random.new()
	local v2 = table.create(8)

	for i = 1, 8 do
		local integer = v:NextInteger(1, 32)
		v2[i] = ("0123456789ABCDEFGHJKMNPQRSTVWXYZ"):sub(integer, integer)
	end

	return table.concat(v2)
end

function PoolTrickshotCodes.Normalise(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local v = value:upper():gsub("[%s%-_]", ""):gsub("[IL]", "1"):gsub("O", "0")

	if #v ~= 8 then
		return nil
	end

	for i = 1, 8 do
		if not ("0123456789ABCDEFGHJKMNPQRSTVWXYZ"):find(v:sub(i, i), 1, true) then
			return nil
		end
	end

	return v
end

function PoolTrickshotCodes.Format(value: string)
	if #value == 8 then
		return value:sub(1, 4) .. "-" .. value:sub(5)
	end

	return value
end

function PoolTrickshotCodes.KeyFor(p: string)
	return "TS_" .. p
end

PoolTrickshotCodes.StoreName = "PoolTrickshotShares_V1"
return PoolTrickshotCodes