local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CueSticks = ReplicatedStorage.Assets.Skins.CueSticks

local function itemModule(p)
	local moduleScript = p.itemName and CueSticks:FindFirstChild(p.itemName)

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
	local moduleScript = p.itemName and CueSticks:FindFirstChild(p.itemName)
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

local CueStick = {}
CueStick.name = "CueStick"
CueStick.itemType = "CueStick"

function CueStick.image(p, _)
	local moduleScript = p.itemName and CueSticks:FindFirstChild(p.itemName)
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

function CueStick.labelTop(p, _)
	local moduleScript = p.itemName and CueSticks:FindFirstChild(p.itemName)
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

function CueStick.labelBottom(_, _): string
	return "Cue Stick"
end

function CueStick.rarity(p, _)
	local moduleScript = p.itemName and CueSticks:FindFirstChild(p.itemName)
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

function CueStick.model(p, _)
	return itemModel(p)
end

function CueStick.modelPivot(_, _)
	return CFrame.Angles(0, 0, 0.6632251157578453)
end

CueStick.viewportOptions = {
	Fill = function(p, p2)
		local PoolMenuWidgets = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMenuWidgets)

		PoolMenuWidgets.CuePreview(p, p2)
	end
}
return CueStick