local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolEffects = ReplicatedStorage.Assets.Skins.PoolEffects

local function itemModule(p)
	local moduleScript = p.itemName and PoolEffects:FindFirstChild(p.itemName)

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

local PoolEffect = {}
PoolEffect.name = "PoolEffect"
PoolEffect.itemType = "PoolEffect"

function PoolEffect.image(p, _)
	local moduleScript = p.itemName and PoolEffects:FindFirstChild(p.itemName)
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

	if typeof(result2) == "string" and result2 ~= "" then
		return result2
	end

	return "rbxassetid://125421487089411"
end

function PoolEffect.labelTop(p, _)
	local moduleScript = p.itemName and PoolEffects:FindFirstChild(p.itemName)
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

function PoolEffect.labelBottom(_, _): string
	return "VFX"
end

function PoolEffect.rarity(p, _)
	local moduleScript = p.itemName and PoolEffects:FindFirstChild(p.itemName)
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

	return if typeof(result2) == "string" then result2 else "Tier4"
end

return PoolEffect