local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolButtonSkin = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolButtonSkin)

local v = {}

local function add(image)
	if v[image] or not image:IsA("ImageLabel") then
		return
	end

	v[image] = PoolButtonSkin.Bind(image)
end

local function remove(p)
	local v2 = v[p]

	if v2 then
		v[p] = nil
		v2()
	end
end

CollectionService:GetInstanceAddedSignal(PoolButtonSkin.Tag):Connect(add)
CollectionService:GetInstanceRemovedSignal(PoolButtonSkin.Tag):Connect(remove)

for _, image in CollectionService:GetTagged(PoolButtonSkin.Tag) do
	if v[image] or not image:IsA("ImageLabel") then
		continue
	end

	v[image] = PoolButtonSkin.Bind(image)
end