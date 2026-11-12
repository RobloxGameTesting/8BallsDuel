local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolTables = ReplicatedStorage.Assets.Skins.PoolTables

local function itemModule(p)
	local moduleScript = p.itemName and PoolTables:FindFirstChild(p.itemName)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, moduleScript)
	return if success then result else nil
end

local function resolve(callback, p, p2)
	if typeof(callback) ~= "function" then
		return callback
	end

	local success, result = pcall(callback, p, p2)
	return if success then result else nil
end

local function itemModel(p)
	local moduleScript = p.itemName and PoolTables:FindFirstChild(p.itemName)
	local result

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success
		success, result = pcall(require, moduleScript)

		if not success then
			result = nil
		end
	end

	local modelFolder = result and result.modelFolder

	if typeof(modelFolder) ~= "table" or typeof(result.modelName) ~= "string" then
		return nil
	end

	local child = ReplicatedStorage

	for _, childName in modelFolder do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	local model = child:FindFirstChild(result.modelName)

	return if model and model:IsA("Model") then model else nil
end

local PoolTable = {}
PoolTable.name = "PoolTable"
PoolTable.itemType = "PoolTable"

function PoolTable.image(p, _)
	local moduleScript = p.itemName and PoolTables:FindFirstChild(p.itemName)
	local result

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success
		success, result = pcall(require, moduleScript)

		if not success then
			result = nil
		end
	end

	local result2

	if result then
		result2 = result.image

		if typeof(result2) == "function" then
			local success
			success, result2 = pcall(result2, p, result)

			if not success then
				result2 = nil
			end
		end
	else
		result2 = result
	end

	return if typeof(result2) == "string" then result2 else ""
end

function PoolTable.labelTop(p, _)
	local moduleScript = p.itemName and PoolTables:FindFirstChild(p.itemName)
	local result

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success
		success, result = pcall(require, moduleScript)

		if not success then
			result = nil
		end
	end

	return result and result.name or tostring(p.itemName)
end

function PoolTable.labelBottom(_, _): string
	return "Table"
end

function PoolTable.rarity(p, _)
	local moduleScript = p.itemName and PoolTables:FindFirstChild(p.itemName)
	local result

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success
		success, result = pcall(require, moduleScript)

		if not success then
			result = nil
		end
	end

	local result2

	if result then
		result2 = result.rarity

		if typeof(result2) == "function" then
			local success
			success, result2 = pcall(result2, p, result)

			if not success then
				result2 = nil
			end
		end
	else
		result2 = result
	end

	return if typeof(result2) == "string" then result2 else "Tier3"
end

function PoolTable.model(p, _)
	return itemModel(p)
end

function PoolTable.modelPivot(_, _)
	return CFrame.Angles(0, -0.20943951023931956, 0)
end

PoolTable.viewportOptions = {
	Direction = Vector3.new(0, 0.88294756, 0.46947157),
	Padding = 1.05
}
return PoolTable