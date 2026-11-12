local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("RunService")
require(ReplicatedStorage.Types.DataTypes)

local userId = tostring(Players.LocalPlayer.UserId)
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data
Maid.new()
local lighting = workspace:GetAttribute("Lighting")

local v = nil
local Light = {}

function Light.Set(_, p)
	v = p
end

function Light:Load(p: string, value: number)
	if v == p then
		return
	end

	local v2 = value or 0

	v = p

	local jsonDecode = HttpService:JSONDecode(p or lighting)

	for _, blurEffect in Lighting:GetChildren(), nil, nil do
		if not blurEffect:IsA("BlurEffect") then
			blurEffect:Destroy()
		end
	end

	for className, v3 in jsonDecode do
		if className == "Lighting" then
			for k, v4 in pairs(v3) do
				if typeof(v4) == "table" then
					if v4[1] == "C" then
						TweenService:Create(Lighting, TweenInfo.new(v2), {
							[k] = Color3.new(v4[2], v4[3], v4[4])
						}):Play()
					end
				elseif k ~= "TimeOfDay" then
					TweenService:Create(Lighting, TweenInfo.new(v2), { [k] = v4 }):Play()
				end
			end
		else
			local instance = Instance.new(className)

			for k, v4 in pairs(v3) do
				if typeof(v4) == "table" then
					if v4[1] == "C" then
						instance[k] = Color3.new(v4[2], v4[3], v4[4])
					end
				else
					instance[k] = v4
				end
			end

			instance.Parent = Lighting
		end
	end

	self:SetShadows()
end

function Light:SetShadows()
	Lighting.GlobalShadows = data.configuration.misc.shadows == "On"
end

return Light